function y = logSt(X, v)
% Compute log pdf of a Student's t distribution.
% Input:
%   X: data 
%   v: degrees of freedom
% Output:
%   y: log probability density, y=log p(x)
d=1;
y = gammaln((v+d)/2)-gammaln(v/2)-0.5 *log(v*pi)-((v+d)/2)*log(1+(X.^2/v));
