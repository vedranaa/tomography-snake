function [current,mu,current_sinogram] = evolve_curve(sinogram_target,current,angles,bins,B,max_iter,w,display)
%EVOLVE_CURVE   Deformes snake to fit sinogram
%   [C,MU,S] = EVOLVE_CURVE(T,C,ANGLES,BINS,B,ITER,W,DISPLAY)
%
%   Inputs:
%   T is a target (noisy) sinogram of size length(ANGLES)-by-length(BINS).
%   C is an initial (input) snake given as N-by-2 vector.
%   ANGLES are projection angles in radians.
%   BINS are center location of detector pixels (centered on a sensor).
%   B is a regularization matrix for a snake, size N-by-N.
%   ITER is a number of deformation iterations.
%   W is deformation step weight (time step).
%   DISPLAY optional period for progress tracking by writing iteration number.
%   Outputs:
%   C is evolved (resulting) snake, the same size as input.
%   MU is resulting attenuation.
%   S is predicted sinogram, the same size as T.
%   Author: vand@dtu.dk

[current_sinogram,curves] = parallel_forward(current,angles,bins);
mu = sum(sinogram_target(:).*current_sinogram(:))/sum(current_sinogram(:).^2);
residual = sinogram_target - mu*current_sinogram;
N = size(current,1);

if nargin>7
    disp('Starting curve evolution')
end

for iter  = 1:max_iter
    if nargin>7 && ~mod(iter,display)
        disp(['Iteration ',num2str(iter),'/',num2str(max_iter)])
    end
    F = griddedInterpolant(residual,'linear','none');
    force = mean(F(curves,repmat((1:numel(angles)),[N,1])),2,'omitnan');
    current = current + w*force(:,[1,1]).*snake_normals(current);
    current = distribute_points(remove_crossings(B*current));
    [current_sinogram,curves] = parallel_forward(current,angles,bins);
    mu = sum(sinogram_target(:).*current_sinogram(:))/sum(current_sinogram(:).^2);
    residual = sinogram_target - mu*current_sinogram;
end


