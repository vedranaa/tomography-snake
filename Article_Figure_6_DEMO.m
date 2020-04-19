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
alpha = 0.1; % curve elasticity
beta = 0.1; % curve rigidity
initialization_radius = 5; % radius of the initial circular curve

w = 0.02; % defirnation force weight (time step)
max_iter = 500; % max number iterations for curve deformation

%% setting up
[sinogram_gt,vertex_coordinates] = parallel_forward(vertices,angles,bins); % forward model for attenuation 1
sinogram_gt = mu_gt*sinogram_gt; % adjusting for attenuation
sinogram_target = add_noise(sinogram_gt,eta); % noisy sinogram
B = regularization_matrix(N,alpha,beta); % for curve smoothing

%% initializing deformable model
current = initialize_circle([0 0],initialization_radius,N); % initial curve
[current_sinogram,curves] = parallel_forward(current,angles,bins); % initial projection
mu = sum(sinogram_target(:).*current_sinogram(:))/sum(current_sinogram(:).^2); % initial attenuation
residual = sinogram_target - mu*current_sinogram; % initial residual
error = sinogram_gt - mu*current_sinogram; % initial error

%% visualizing situation before curve evolution
clim = [min(min(sinogram_target(:)),0), max(sinogram_target(:))];
bwr_colormap = interp1(linspace(-1,1,5),... % blue-white-red colormap
    [0,0,0.5; 0,0.5,1; 1,1,1; 1,0,0; 0.5,0,0],linspace(-1,1,256));
bwr_max_abs = max(abs(residual(:)));

figure
subplot(231)
fill(bins([1,end,end,1]),bins([1,1,end,end]),[0.5,0.5,0.5],'EdgeColor',[0.5,0.5,0.5]), hold on
fill(vertices(:,1),vertices(:,2),'w','EdgeColor',[0.5,0.5,0.5]), axis equal square off
axis([bins(1) bins(end) bins(1) bins(end)])
P = plot(current([1:end,1],1),current([1:end,1],2),'-r','LineWidth',1);
T1 = title({'ground truth and current curve','initialization'});

subplot(232)
imagesc(ind2rgb(uint8(255*(sinogram_gt-clim(1))/diff(clim)),gray(256)))
axis square off, title('noise-free sinogram')

subplot(233)
imagesc(ind2rgb(uint8(255*(sinogram_target-clim(1))/diff(clim)),gray(256)))
axis square off, title('noisy sinogram')

subplot(234)
S = imagesc(ind2rgb(uint8(255*(current_sinogram-clim(1))/diff(clim)),gray(256)));
axis square off, title('current predicted sinogram')

subplot(235)
E = imagesc(ind2rgb(uint8(255/2*(error+bwr_max_abs)/bwr_max_abs),bwr_colormap));
axis square off, T2 = title({'current error','initialization'});

subplot(236)
R = imagesc(ind2rgb(uint8(255/2*(residual+bwr_max_abs)/bwr_max_abs),bwr_colormap));
axis square off, T3 = title({'current residual','initialization'});

ssr = [sum(residual(:).^2); zeros(max_iter,1)];
sse = [sum(error(:).^2); zeros(max_iter,1)];
sd = zeros(max_iter,1);

%% visualizing curve evolution
for iter  = 1:max_iter
    old = current;
    [current,mu,current_sinogram] = evolve_curve(sinogram_target,current,angles,bins,B,1,w);
    d = sqrt(sum(current-old,2).^2);
    residual = sinogram_target - mu*current_sinogram; % initial residual
    error = sinogram_gt - mu*current_sinogram; % initial error
    ssr(iter+1) = sum(residual(:).^2);
    sse(iter+1) = sum(error(:).^2);
    sd(iter) = sum(d);
    set(P,'XData',current(:,1),'YData',current(:,2))
    set(S,'CData',ind2rgb(uint8(255*(current_sinogram-clim(1))/diff(clim)),gray(256)));
    set(E,'CData',ind2rgb(uint8(255/2*(error+bwr_max_abs)/bwr_max_abs),bwr_colormap));
    set(R,'CData',ind2rgb(uint8(255/2*(residual+bwr_max_abs)/bwr_max_abs),bwr_colormap));
    set(T1,'String',{'ground truth and current curve',['iteration ',num2str(iter),'/',num2str(max_iter)]})
    set(T2,'String',{'current error',['sum squared ',num2str(round(sse(iter+1)))]})
    set(T3,'String',{'current residual',['sum squared ',num2str(round(ssr(iter+1)))]})
    drawnow
end

%% convergence
figure
subplot(121), plot(0:iter,ssr,'b-',0:iter,sse,'r--')
xlabel('iteration'), ylabel('sum squared'), legend('residual','error')
a = gca; a.YLim(1)=0; a.XLim=[0 max_iter]; axis square

subplot(122), plot(1:iter,sd,'Color',[0 0.7 0])
xlabel('iteration'), ylabel('sum of absolute'), legend('displacement')
a = gca; a.YLim(1)=0; a.XLim=[0 max_iter]; axis square

