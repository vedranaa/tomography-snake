function sinogram_target = add_noise(sinogram_gt,eta)
%ADD_NOISE   Adds Gaussian noise to a sinogram
%   T = ADD_NOISE(S,ETA)
%   S is a sinogram, ETA is a relative noise level, T is noisy sinogram.
%   Author: vand@dtu.dk

% rng(0); - removing randomness for experiments
e = randn(size(sinogram_gt)); % realization of noise
noise = norm(sinogram_gt(:))*e/norm(e(:)); % final additive noise
sinogram_target = sinogram_gt + eta*noise; % noisy sinogram
