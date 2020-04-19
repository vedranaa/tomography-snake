clear, close all
addpath 'functions'

vertices = ... vertices of the test object (ground truth geometry)
    [-1     4     6  5.9   5     2     1    1.1   4.6     4.8     4     2     1     3    2.5    0    -2    -3;
    4     6     5  4.5   4     3     2    1.6   1.5     0.8     0    -1    -3    -5   -5.8   -6    -4    -2]';
mu_gt = 0.9; % intensity of test object (ground truth intensity)

nr_angles = 15; % number of projection angles
angles = (0:pi/nr_angles:pi-pi/nr_angles)-pi/2; % projection angles

bin_width = 0.1; % width of detector pixels
detector_number = 200; % number of detector pixels on a sensor
bins = ((1:detector_number) - (1+detector_number)/2)*bin_width; % centers of detector pixels

eta = 0.3; % relative noise level

N = 500; % number of curve points
alpha = 1; % curve elasticity
beta = 1; % curve rigidity
initialization_radius = 5; % radius of the initial circular curve

w = 0.02; % defirnation force weight (time step)
max_iter = 500; % max number iterations for curve deformation

%% selected vertices and curve points for to be visualized
vE = [17,18,1,2,3]; % selected vertices
cE = [60 120]; % selected curve points

%% setting up
[sinogram_gt,vertex_coordinates] = parallel_forward(vertices,angles,bins); % forward model for attenuation 1
sinogram_gt = mu_gt*sinogram_gt; % adjusting for attenuation
sinogram_target = add_noise(sinogram_gt,eta); % noisy sinogram
B = regularization_matrix(N,alpha,beta); % for curve smoothing

%% visualizing test set up
figure
fill(bins([1,end,end,1]),bins([1,1,end,end]),'k'), hold on
fill(vertices(:,1),vertices(:,2),mu_gt*[1 1 1]), axis equal square off
axis([bins(1) bins(end) bins(1) bins(end)])
plot(vertices(vE,1),vertices(vE,2),'sm','MarkerSize',8,'MarkerFaceColor','m');
title('test object')

figure
imagesc(sinogram_gt), colormap gray, hold on, axis square off
plot(vertex_coordinates(vE,:)','m','LineWidth',2);
title('noise-free sinogram')

figure
imagesc(sinogram_target), colormap gray, axis square off
title('noisy sinogram')

%% initializing deformable model
current = initialize_circle([0 0],initialization_radius,N); % initial curve
[current_sinogram,curves] = parallel_forward(current,angles,bins); % initial projection
mu = sum(sinogram_target(:).*current_sinogram(:))/sum(current_sinogram(:).^2); % initial attenuation
residual = sinogram_target - mu*current_sinogram; % initial residual

%% visualizing situation before curve evolution
figure
fill(bins([1,end,end,1]),bins([1,1,end,end]),[0.85,0.85,0.85],'EdgeColor',[0.85,0.85,0.85]), hold on
fill(vertices(:,1),vertices(:,2),'w','EdgeColor',[0.85,0.85,0.85]), axis equal square off
axis([bins(1) bins(end) bins(1) bins(end)])
plot(current([1:end,1],1),current([1:end,1],2),'-r','LineWidth',3)
plot(current(cE,1),current(cE,2),'sg','MarkerSize',8,'MarkerFaceColor','g');
title('curve initialization')

figure
imagesc(current_sinogram), colormap gray, hold on, axis square off
plot(curves(cE,:)','g','LineWidth',2);
title('initial projection')

figure
fill(bins([1,end,end,1]),bins([1,1,end,end]),'k'), hold on
fill(current([1:end,1],1),current([1:end,1],2), min(mu,1)*[1 1 1])
plot(current(cE,1),current(cE,2),'sg','MarkerSize',8,'MarkerFaceColor','g');
axis equal square off
axis([bins(1) bins(end) bins(1) bins(end)])
title('initial reconstruction')

figure
bwr_max_abs = max(abs(residual(:)));
bwr_colormap = interp1(linspace(-1,1,5),... % blue-white-red colormap
    [0,0,0.5; 0,0.5,1; 1,1,1; 1,0,0; 0.5,0,0],linspace(-1,1,256));
imagesc(residual,[-bwr_max_abs,bwr_max_abs])
colormap(bwr_colormap), hold on, axis square off
plot(curves(cE,:)','g','LineWidth',2);
title('initial residual')

drawnow

%% curve evolution
figure
fill(bins([1,end,end,1]),bins([1,1,end,end]),[0.85,0.85,0.85],'EdgeColor',[0.85,0.85,0.85]), hold on
fill(vertices(:,1),vertices(:,2),'w','EdgeColor',[0.85,0.85,0.85]), axis equal square off
axis([bins(1) bins(end) bins(1) bins(end)])
plot(current([1:end,1],1),current([1:end,1],2),'-r','LineWidth',1.5)
title('evolution')
chunk = 25; % taking iters in chunks for visualization
cEvolx = [current(cE,1),zeros(numel(cE),floor(max_iter/chunk))];
cEvoly = [current(cE,2),zeros(numel(cE),floor(max_iter/chunk))];
for bigiter  = 1:max_iter/chunk
    [current,mu] = evolve_curve(sinogram_target,current,angles,bins,B,chunk,w);
    plot(current([1:end,1],1),current([1:end,1],2),'-r','LineWidth',1.5)
    drawnow
    cEvolx(:,bigiter+1) = current(cE,1);
    cEvoly(:,bigiter+1) = current(cE,2);
end
plot(cEvolx',cEvoly','g','LineWidth',3);
drawnow

%% visualizing situation after curve evolution
figure
fill(bins([1,end,end,1]),bins([1,1,end,end]),[0.85,0.85,0.85],'EdgeColor',[0.85,0.85,0.85]), hold on
fill(vertices(:,1),vertices(:,2),'w','EdgeColor',[0.85,0.85,0.85]), axis equal square off
axis([bins(1) bins(end) bins(1) bins(end)])
plot(current([1:end,1],1),current([1:end,1],2),'-r','LineWidth',3)
plot(current(cE,1),current(cE,2),'sg','MarkerSize',8,'MarkerFaceColor','g');
title('resulting curve')

figure
fill(bins([1,end,end,1]),bins([1,1,end,end]),'k'), hold on
fill(current([1:end,1],1),current([1:end,1],2), min(mu,1)*[1 1 1])
plot(current(cE,1),current(cE,2),'sm','MarkerSize',8,'MarkerFaceColor','m');
axis equal square off
axis([bins(1) bins(end) bins(1) bins(end)])
title('resulting reconstruction')

figure
imagesc(current_sinogram), colormap gray, hold on, axis square off
plot(curves(cE,:)','g','LineWidth',2);
title('resulting predicted sinogram')

figure
bwr_max = max(abs(residual(:)));
imagesc(residual,[-bwr_max,bwr_max]), colormap(bwr_colormap), hold on, axis square off
plot(curves(cE,:)','g','LineWidth',2);
title('resulting residual')


