function p_new = distribute_points(p,type,value)
% DISTRIBUTE_POINTS   Distributes snakes points equidistantly
%
%   DISTRIBUTE_POINTS(P) keeps the number of points
%   DISTRIBUTE_POINTS(P,'number',N) returns N points
%   DISTRIBUTE_POINTS(P,'ael',d) returns average edge length d
%   Author: vand@dtu.dk


p = p([1:end,1],:); % closing the curve
N = size(p,1); % number of points (+ 1, due to closing)
dist = sqrt(sum(diff(p).^2,2)); % edge segment lengths
t = [0;cumsum(dist)]; % current positions
% if we want the fixed edge length then the new N could be computed 
% from the total length of the curve which is t(end)

if nargin<2 
    N_new = N;
else
    switch lower(type)
        case 'number'
            N_new = value+1;
        case 'ael'
           N_new = round(t(end)/value+1); 
    end    
end

tq = linspace(0,t(end),N_new)'; % equidistant positions
p_new(:,1) = interp1(t,p(:,1),tq); % distributed x
p_new(:,2) = interp1(t,p(:,2),tq); % distributed y
p_new = p_new(1:end-1,:); % opening the curve again
