function K = covAEiso(ell, alpha_minus, alpha_plus)

fin1_minus = length(alpha_minus)-1;
fin1_plus  = length(alpha_plus)-1;
alpha      = [0.5 - alpha_minus(end:-1:2) 0.5 0.5 + alpha_plus(2:end)];

midpoints = (alpha(1:(end-1)) + alpha(2:end)) / 2;
midpoints = [midpoints(fin1_minus:-1:1) midpoints(fin1_minus+1:fin1_minus+fin1_plus)];

% Check if Deep Learning Toolbox is available, otherwise compute distance manually
% v = ver;
% has_dist = any(strcmp(cellstr(char(v.Name)), 'Deep Learning Toolbox'));
% if ( has_dist )
% C = dist(midpoints);
% else
% end
C = abs(midpoints - midpoints');

K = exp(- (C / ell).^2);

