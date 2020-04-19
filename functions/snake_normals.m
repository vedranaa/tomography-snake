function N = snake_normals(S)
%SNAKE_NORMALS   Normals for a closed snake
%   N = SNAKE_NORMALS(S)
%   Outward pointing for a positively oriented snake
%   Author: vand@dtu.dk

X = S([end,1:end,1],:); % extended S
dX = X(1:end-1,:)-X(2:end,:); % dX
Ne = normalize([dX(:,2),-dX(:,1)]); % edge normals orthogonal to dX
N = normalize(0.5*(Ne(1:end-1,:)+Ne(2:end,:))); % vertices normals

function n = normalize(n)
d = sum(n.^2,2).^0.5;
nonzero = d~=0;
n(nonzero,:) = n(nonzero,:)./d(nonzero,[1 1]);


