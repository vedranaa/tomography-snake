clear
close all
addpath 'functions' 

% Requres astra toolbox which can be obtained at https://www.astra-toolbox.com/
astra_path = '../ASTRA'; % point to astra folder
if exist(astra_path,'dir')
    addpath(genpath([astra_phath,'/tools']))
    addpath(genpath([astra_phath,'/ASTRA/mex']))
    addpath(genpath([astra_phath,'/DART']))
else
    warning('This script requres astra toolbox, https://www.astra-toolbox.com/')
end

load('test_objects/dino_polygonized.mat'); % test geometry

nr_angles = 15; % CHANGE TO VALUES 5, 15. For some reason, I need to restart matlab when changing the number of angles.
eta = 0.1; % CHANGE TO VALUES 0, 0.05, 0.1;

%% creating rasterized images: I_big, I_small
% (I want to use a fine resolution image for forward projection, but then 
% reconstruct a lower resolution, that's why big and small)
angles = (0:pi/nr_angles:pi-1/nr_angles)-pi/2;
bin_width = 0.1;
detector_width = 20; % width of the detector
bins = -(detector_width-bin_width)/2:bin_width:(detector_width-bin_width)/2; % centers of detector pixels 
J = numel(bins); % image will have as many rows/colums as detector bins
a = (J-1)/(bins(end)-bins(1));
b = (J+1)/2;
s = 5; % upscaling factor
as = (s*J-1)/( bins(end)-bins(1)+bin_width-bin_width/s);
bs = (s*J+1)/2;
I_small = flip(double(poly2mask(a*vertices(:,1)+b,a*vertices(:,2)+b,J,J)))/a;
I_big = flip(double(poly2mask(as*vertices(:,1)+bs,as*vertices(:,2)+bs,s*J,s*J)))/as;
%figure, imagesc(I_small), axis image, colormap gray
%figure, imagesc(I_big), axis image, colormap gray

%% NEXT: FORWARD PROJECTION USING ASTRA TOOLBOX
% create projectors
proj_geom = astra_create_proj_geom('parallel',bin_width*a, J, angles);
proj_id_small = astra_create_projector('line', proj_geom,...
    astra_create_vol_geom(J,J));

proj_id_big = astra_create_projector('line', ...
    astra_create_proj_geom('parallel', bin_width*a*s, J, angles),...
    astra_create_vol_geom(size(I_big,1),size(I_big,2)));

% create forward projection
% (I don't know how to circumvent creating and then overwritting small sinogram)
[sinogram_id_small, sinogram_small] = astra_create_sino(I_small, proj_id_small);
[sinogram_id_big, sinogram_big] = astra_create_sino(I_big, proj_id_big);
rng(0); e = randn(J,nr_angles); % realization of noise
noise = norm(sinogram_big(:))*e/norm(e(:)); % final additive noise

% overwritting sinogram values
target = sinogram_big+eta*noise'; % this is the sinogram we use as input
astra_mex_data2d('set', sinogram_id_small, target);

figure, imagesc(target'), axis square off, colormap gray
title('noisy sinogram'), drawnow

%% NEXT: SART RECONSTRUCTION USING ASTRA TOOLBOX
recon_id = astra_mex_data2d('create', '-vol', astra_create_vol_geom(J,J), 0);
cfg = astra_struct('SART');
cfg.option.MinConstraint = 0;
cfg.ProjectorId = proj_id_small;
cfg.ProjectionDataId = sinogram_id_small;
cfg.ReconstructionDataId = recon_id;
sart_id = astra_mex_algorithm('create', cfg);
astra_mex_algorithm('iterate', sart_id, 500);
result_SART = astra_mex_data2d('get', recon_id);

figure, imagesc(result_SART), axis image off, colormap gray, title('SART')


%% NEXT: DART RECONSTRUCTION USING ASTRA TOOLBOX

% DART configuration
proj_count		= size(sinogram_big,2);
dart_iterations = 200;
rho				= [0, 1]/10;
tau				= 0.5/10;
proj_type       = 'line';

% DART
D						= DARTalgorithm(target,proj_geom);
D.t0					= 100;  % ARM iterations at DART initialization
D.t						= 5;  % ARM iterations for each DART iteration
D.tomography.method		= 'SART';
D.tomography.proj_type   = proj_type;
D.tomography.gpu	    = 'no';
D.tomography.use_minc	= 'yes'; % use minimum constraint
D.smoothing.gpu         = 'no';
D.masking.gpu           = 'no';
D.segmentation.rho		= rho;
D.segmentation.tau		= tau;
D.initialize();
D.iterate(dart_iterations);
result_DART = D.S;

figure, imagesc(result_DART), axis image off, colormap gray, title('DART'), drawnow

% garbage disposal
astra_mex_data2d('delete', sinogram_id_small,sinogram_id_big,recon_id);
astra_mex_data2d('delete', sinogram_small,sinogram_big);
astra_mex_projector('delete', proj_id_small, proj_id_big);
astra_mex_algorithm('delete', sart_id);

%% NEXT: OUR RECONSTRUCTION

N = 500; % number of curve points
w = 0.02; % force weight (time step)
max_iter = 1000; % number of iters
alpha = 0.01; % elasticity
beta = 0.01; % rigidity
initialization_radius = 5;
B = regularization_matrix(N,alpha,beta); % regularization matrix
sinogram_target = target'; % we use transposed data

current = initialize_circle([0 0],initialization_radius,N);
[current,mu] = evolve_curve(sinogram_target,current,angles,bins,B,max_iter,w,100);

figure
fill(bins([1,end,end,1]),bins([1,1,end,end]),[0.85,0.85,0.85],'EdgeColor',[0.85,0.85,0.85]), hold on
fill(vertices(:,1),vertices(:,2),'w','EdgeColor',[0.85,0.85,0.85])
axis equal square off, axis([bins(1) bins(end) bins(1) bins(end)])
plot(current([1:end,1],1),current([1:end,1],2),'r-','LineWidth',3)
title('our resulting curve')

figure
fill(bins([1,end,end,1]),bins([1,1,end,end]),'k'), hold on
fill(current([1:end,1],1),current([1:end,1],2), min(mu,1)*[1 1 1])
axis equal square off, axis([bins(1) bins(end) bins(1) bins(end)])
title('our reconstruction')



