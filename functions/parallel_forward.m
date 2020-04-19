function [sinogram,vertex_coordinates] = parallel_forward(vertices,angles,bins)
%FORWARD_PROJECT   Forward projection given a polygon and a geometry
%   [SINOGRAM,VERTEX_COORDINATES] = FORWARD_PROJECT(VERTICES,ANGLES,BINS)
%   Inputs:
%   VERTICES is a curve (snake, polygon) given as N-by-2 vector.
%   ANGLES are projection angles in radians.
%   BINS center location of detector pixels (centered on a sensor).
%   SINOGRAM is a forward projection of the snake on the detector, with the
%       size of numel(BINS)-by-numel(ANGLES)
%   VERTEX_COORDINATES are coordinates of projection of each vertex on the
%       detector given as N-by-numel(ANGLES) matrix
%   Author: vand@dtu.dk
%
% PARALLEL_FORWARD gives the same result as algorithm 1 from our paper, but
% the implementation is slightly different. Here, we first project a whole
% curve on a detector, and then discretize. In the paper we describe an 
% algorithm where contributions of each line segment are discretized on the
% fly.


N = size(vertices,1); 
indices = 1:N;
sinogram = zeros(numel(bins),numel(angles)); 
vertex_coordinates = zeros(N,numel(angles)); 
position = zeros(N,1); % pre-allocating

for k = 1:numel(angles)
    
    angle = angles(k);
    projection = [cos(angle);sin(angle)]; % projection direction (along with detector)
    normal = [-projection(2);projection(1)]; % normal direction (along with rays)
    
    % preparing for work
    vertex_coordinates(:,k) = vertices*projection; % vertex coordinates in projection
    distance = vertices*normal;% distances from vertex to projection
    
    % ordering everything according to coordinates
    [coordinates_ordered,ordering] = sort(vertex_coordinates(:,k)); % ordering(x) gives index to point at position x
    distances_ordered = distance(ordering);
    position(ordering) = indices; % position(x) gives position of the point x in ordereding
    
    % initializing a a placeholder for adding up edge contributions to points
    heights = zeros(N,1);
    
    for i = 1:N
        % considering edge from vertex i to vertex i+1, to close the region
        % by connecting the last vertex with the first vertex I use mod(i,N)+1)
        
        % I could figure ordering of edge edpoints by looking at elements of coordinates,
        % insted I consider elements of ordering which are always unique
        if position(i)<position(mod(i,N)+1)
            A = position(i); % position of edge endpoint with a smaller coordinate
            B = position(mod(i,N)+1); % position of edge endpoint with a larger coordinate
            reverse = 1; % direction of the edge
        else
            A = position(mod(i,N)+1);
            B = position(i);
            reverse = -1;
        end
        
        % linear contribution to points from A to B
        if abs(coordinates_ordered(B)-coordinates_ordered(A))>eps % taking care for points landing on top of eachother
            contribution = ((distances_ordered(B)-distances_ordered(A))*coordinates_ordered(A:B) - ...
                distances_ordered(B)*coordinates_ordered(A)+distances_ordered(A)*coordinates_ordered(B))/...
                (coordinates_ordered(B)-coordinates_ordered(A));
            % endpoints recieve only half from this edge (half from other)
            % contribution([1,end]) = 0.5*contribution([1,end]);
            % instead of adjusting endpoints contributions here, I overwrite after loop
            % this is to avoid numerical problems when A and B are almost on
            % top of eachother
        else
            contribution = zeros(B-A+1,1); % zero contribution as nothing should be in between
        end
        contribution([1,end]) = 0.5*[distances_ordered(A),distances_ordered(B)]; % endpoint contribution
        % updating with the contribution of this edge
        heights(A:B) = heights(A:B) + reverse*contribution;
    end
    
    % interpolating in  1D 
    % matlabs interpolation expects coordinates_orderet to be strictly increasing
    % so I first remove if more than 2 coordinates are equal, and then 
    % slightly perturbe if 2 coordinates are equal
    sensitivity = 10^-14;
    increase = diff(coordinates_ordered);
    to_remove = [false; increase(1:end-1)+increase(2:end) < 2*sensitivity; false];
    coordinates_ordered(to_remove) = [];
    heights(to_remove) = [];    
    to_perturbe = diff(coordinates_ordered)<sensitivity;
    coordinates_ordered([to_perturbe;false]) = coordinates_ordered([to_perturbe;false]) - sensitivity;
    coordinates_ordered([false;to_perturbe]) = coordinates_ordered([to_perturbe;false]) + sensitivity;
    F = griddedInterpolant(coordinates_ordered,heights,'linear','nearest');
    sinogram(:,k) = F(bins);
    %sinogram(:,k) = interp1([bins(1),coordinates_ordered,bins(end)],[0,heights,0],bins);
end

if nargout>1
    % expressing vertex coordinates as coordinates in sinogram (pixel coordinates, not spatial)
    a = (numel(bins)-1)/(bins(end)-bins(1)); % slope
    b = 1-a*bins(1); % intercept
    vertex_coordinates = a*vertex_coordinates + b;
end