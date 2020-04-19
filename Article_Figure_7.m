clear, close all
addpath 'functions'

load('test_objects/dino_polygonized.mat'); % test geometry

nr_angles = 15; % number of projection angles
angles = (0:pi/nr_angles:pi-pi/nr_angles)-pi/2; % projection angles

bin_width = 0.1; % width of detector pixels
detector_number = 200; % number of detector pixels on a sensor
bins = ((1:detector_number) - (1+detector_number)/2)*bin_width; % centers of detector pixels 

eta = 0.1; % relative noise level

N = 500; % number of curve points
alpha = 0.01; % curve elasticity
beta = 0.01; % curve rigidity
initialization_radius = 5; % radius of the initial circular curve

w = 0.02; % deformation force weight (time step)
max_iter = 500; % max number iterations for curve deformation

% setting up
[sinogram_gt,vertex_coordinates] = parallel_forward(vertices,angles,bins); % noise-free sinogram
sinogram_target = add_noise(sinogram_gt,eta); % noisy sinogram
B = regularization_matrix(N,alpha,beta); % for curve smoothing

% visualizing situation before curve evolution
figure
fill(bins([1,end,end,1]),bins([1,1,end,end]),'k'), hold on
fill(vertices(:,1),vertices(:,2),'w'), axis equal square off
axis([bins(1) bins(end) bins(1) bins(end)])
title('test object')

figure
imagesc(sinogram_gt), colormap gray, axis square off
title('noise-free sinogram')

figure
imagesc(sinogram_target), colormap gray, axis square off
title('noisy sinogram')

% curve evolution
current = initialize_circle([0 0],initialization_radius,N); % initializing deformable model
figure
fill(bins([1,end,end,1]),bins([1,1,end,end]),[0.85,0.85,0.85],'EdgeColor',[0.85,0.85,0.85]), hold on
fill(vertices(:,1),vertices(:,2),'w','EdgeColor',[0.85,0.85,0.85]), axis equal square off
axis([bins(1) bins(end) bins(1) bins(end)])
plot(current([1:end,1],1),current([1:end,1],2),'-r','LineWidth',1.5)
title('evolution')
chunk = 25; % taking iters in chunks for visualization
for bigiter  = 1:max_iter/chunk % taking iters in chunks for visualization
    [current,mu] = evolve_curve(sinogram_target,current,angles,bins,B,chunk,w);
    plot(current([1:end,1],1),current([1:end,1],2),'-r','LineWidth',1.5)
end

% producing predicted sinogram for visualization 
[current_sinogram,curves] = parallel_forward(current,angles,bins);
residual = sinogram_target - mu*current_sinogram;

% visualizing situation after curve evolution
figure
fill(bins([1,end,end,1]),bins([1,1,end,end]),[0.85,0.85,0.85],'EdgeColor',[0.85,0.85,0.85]), hold on
fill(vertices(:,1),vertices(:,2),'w','EdgeColor',[0.85,0.85,0.85]), axis equal square off
axis([bins(1) bins(end) bins(1) bins(end)])
plot(current([1:end,1],1),current([1:end,1],2),'-r','LineWidth',3)
title('resulting curve')

figure
imagesc(current_sinogram), colormap gray, axis square off
title('resulting predicted sinogram')

figure
bwr_max = max(abs(residual(:)));
imagesc(residual,[-bwr_max,bwr_max])
colormap(interp1(linspace(-1,1,5),... % blue-white-red colormap
    [0,0,0.5; 0,0.5,1; 1,1,1; 1,0,0; 0.5,0,0],linspace(-1,1,256)))
axis square off
title('resulting residual')

figure
fill(bins([1,end,end,1]),bins([1,1,end,end]),'k'), hold on
fill(current([1:end,1],1),current([1:end,1],2), min(mu,1)*[1 1 1])
axis equal square off
axis([bins(1) bins(end) bins(1) bins(end)])
title('resulting reconstruction')



