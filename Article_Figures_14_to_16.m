clear, close all
addpath 'functions'

% For forward projection we used AIRtools (original software) which can be
% obtained at http://www.imm.dtu.dk/~pcha/AIRtoolsII/index.html.
% Alternatively, you can use matlabs build-in radon transfor, follow the
% suggestions in the code below.

air_path = '../AIRtools'; % point to AIRtools folder
if exist(air_path,'dir')
    addpath(air_path)
    has_air = true;
else
    warning('Can''t use AIRtools for forward projection. Changing to matlabs build-in radon transform.')
    has_air = false;
end

% choosing a test image
filenames = {'hand.png','five.png','DART.png','plusplus.png'}; % used in Figure 14
%filenames = {'hand_Q.png','hand_D.png','hand_G.png','hand_H.png'}; % used in Figure 15
%filenames = {'paw.png','puzzle.png'}; % used in Figure 16
filename = filenames{1};

D = 200; % size of the image (in pixels)
I = double(imresize(imread(['test_objects/',filename]),[D,D]))/255;
%%

nr_angles = 15; % number of equaly spaced projection angles
N = 500; % number of curve points
alpha = 0.01; % curve elasticity
beta = 0.01; % curve rigidity
eta = 0.05; %[0.01, 0.05, 0.1]; % relative noise level
max_iter = 500; % number of iterations for curve deformation
w = 0.02; % force weight (time step)

%% common settings
initialization_radius = D/4;
B = regularization_matrix(N,alpha,beta); % regularization matrix
angles = (0:pi/nr_angles:pi-1/nr_angles)-pi/2;

%% forward projection using AIR tools
if has_air
    bins = -(D-1)/2:(D-1)/2;
    A = paralleltomo(D,angles*180/pi,D,(D-1));
    sinogram_gt = reshape(A*I(:),[D,numel(angles)]);
    sinogram_target = add_noise(sinogram_gt,eta);
else
    %% using matlab radon transform -- two possibilities
    % In lack of AIR tools, matlabs own randon can be used to produce
    % sinogram. Howewer, we can not adjust the width of the detector directly.
    % So we either need to adjust the bins, as in approach A), or we need to
    % crop the sinogram, as in approach B)
    
    % % Approach A)
    % sinogram_gt = radon(I,angles*180/pi);
    % bins = linspace(-1,1,size(sinogram_gt,1))*size(sinogram_gt,1)/2;
    % sinogram_target = add_noise(sinogram_gt,eta);
    
    % Approach B)
    sinogram_gt = radon(I,angles*180/pi);
    m = (size(sinogram_gt,1)-D)/2; 
    sinogram_gt = 0.5*(sinogram_gt(1+floor(m):end-ceil(m),:) + sinogram_gt(1+ceil(m):end-floor(m),:));
    bins = -(D-1)/2:(D-1)/2;
    sinogram_target = add_noise(sinogram_gt,eta);
end

%%
figure, imagesc(I), colormap gray
axis square off, title('test image')

figure, imagesc(sinogram_gt), colormap gray
axis square off, title('noise-free sinogram')

figure, imagesc(sinogram_target), colormap gray
axis square off, title('noisy sinogram')

drawnow

% initializing and evolving the curve
current = initialize_circle([0 0],initialization_radius,N); % curve initialization
[current,mu] = evolve_curve(sinogram_target,current,angles,bins,B,max_iter,w,100);

figure, imagesc(0.5+I/2,[0,1]), colormap gray, hold on
plot(current([1:end,1],1)+(D+1)/2,-current([1:end,1],2)+(D+1)/2,'r-','LineWidth',3)
axis square off, title('resulting curve')

figure
fill(D*[0,1,1,0],D*[0,0,1,1],'k'), hold on
fill(current([1:end,1],1)+(D+1)/2,current([1:end,1],2)+(D+1)/2, min(mu,1)*[1 1 1])
axis equal square off, axis(D*[0 1 0 1])
title('resulting reconstruction')


