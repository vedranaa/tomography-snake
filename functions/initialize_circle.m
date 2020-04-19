function S = initialize_circle(c,r,N)
%INITIALIZE_CIRCLE   Initializes circular snake
%   INITIALIZE_CIRCLE(C,R,N)
%   Inputs: C center, R radius, N number of snake points.
%   Circle starts in (max(x),mean(y)) and is positively oriented.
%   Author: vand@dtu.dk

alpha = (0:N)*2*pi/N; % N+1 point
alpha(end) = []; % removing last

x = c(1) + r*cos(alpha);
y = c(2) + -r*sin(alpha); 
S = [x(:),y(:)]; 
