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

%% FIGURE 8, changing relative noise level
% eta = 0.4; % CHANGE TO VALUES 0.05, 0.2, 0.3, 0.4

%% FIGURE 9, changing number of angles
% nr_angles = 7; % CHANGE TO VALUES 30, 10, 7, 5
% angles = (0:pi/nr_angles:pi-pi/nr_angles)-pi/2; % projection angles

%% FIGURE 10, changing direction for limited angle reconstruction
% nr_angles = 10; % as used in figure 10
% initialization_radius = 8; % as used in figure 10
% width = pi/3; % width of the narrow angle
% angles_centered = (0:width/(nr_angles-1):width)-width/2; % angles without direction
% direction = pi/2; % CHANGE TO VALUES -pi/4, 0, pi/4, pi/2
% angles = angles_centered + direction;
% figure % showing projection angles
% fill([0 1 1 0],[0 0 1 1],[1 1 1],'EdgeColor',[1,1,1]), hold on 
% plot([repmat(0.5,[1,nr_angles]);0.48*sin(angles)+0.5],[repmat(0.5,[1,nr_angles]);0.48*cos(angles)+0.5],'Color','k','LineWidth',3)
% axis equal off, axis([0 1 0 1])
% title('directions of projection angles')

%% FIGURE 11, changing the size of the detector
% D = 6; % width of the detector, CHANGE TO VALUES 8,6,4,2
% nr_bins = 200;
% bins = linspace(-D,D,nr_bins);
% figure % showing illustration of detector width
% fill(10*[-1 1 1 -1],10*[-1 -1 1 1],[1 1 1],'EdgeColor',[1,1,1]), hold on 
% fill(10*[-1 1 1 -1],D*[-1 -1 1 1],0.75*[1 1 1],'EdgeColor',0.75*[1,1,1])
% fill(D*[-1 1 1 -1],10*[-1 -1 1 1],0.75*[1 1 1],'EdgeColor',0.75*[1,1,1])
% fill(D*[-1 1 1 -1],D*[-1 -1 1 1],0.5*[1 1 1],'EdgeColor',0.5*[1,1,1])
% a90 = 0:pi/90:2*pi;
% fill(D*sin(a90),D*cos(a90),0.25*[1 1 1],'EdgeColor',0.25*[1,1,1])
% axis equal off, axis(10*[-1 1 -1 1])
% title('illustration showing detector width')

%% FIGURE 12, changing regularization
% alpha = 0; % elasticity, CHANGE TO VALUE 0.001, 0.01 0.1 1;
% beta = 0.1; % rigidity,, CHANGE TO VALUE 0.001, 0.01 0.1 1; 

%% initialization, evolution and visualization

[sinogram_gt,vertex_coordinates] = parallel_forward(vertices,angles,bins); % noise-free sinogram
sinogram_target = add_noise(sinogram_gt,eta); % noisy sinogram
B = regularization_matrix(N,alpha,beta); % for curve smoothing

figure, imagesc(sinogram_target), axis square off, colormap gray
title(['sinogram with relative noise level ',num2str(eta)])

current = initialize_circle([0 0],initialization_radius,N);
current = evolve_curve(sinogram_target,current,angles,bins,B,max_iter,w,100);

figure
fill(10*[-1,1,1,-1],10*[-1,-1,1,1],[0.85,0.85,0.85],'EdgeColor',[0.85,0.85,0.85]), hold on
fill(vertices(:,1),vertices(:,2),'w','EdgeColor',[0.85,0.85,0.85]), axis equal square off
axis(10*[-1 1 -1 1])
plot(current([1:end,1],1),current([1:end,1],2),'-r','LineWidth',3)
title('resulting curve')




