function [q_minus, q_plus, theta_minus, theta_plus] = q_stud_BJSAV(y, alpha_minus, alpha_plus, param)

beta_minus = param(1:(3*(length(alpha_minus)-1)));
tot = 3 * (length(alpha_minus)-1);
beta_plus = param((tot+1):(tot+3*(length(alpha_plus)-1)));
tot = tot + 3 * (length(alpha_plus)-1);
theta_minus1 = param((tot+1):(tot+length(alpha_minus)-1));
tot = tot + length(alpha_minus)-1;
theta_plus1 = param((tot+1):(tot+length(alpha_plus)-1));
nu = param((tot+length(alpha_plus)-1)+1);
%**************************************************************************
% 
% Compute the quantile time series.
%
%**************************************************************************
nprmtrs = 3;
q_minus = zeros(length(y), length(alpha_minus)-2);
q_plus  = zeros(length(y), length(alpha_plus)-2);

sigmasq    = ones(length(y), 1);
theta_minus= zeros(length(y), length(alpha_minus)-1);
theta_plus = zeros(length(y), length(alpha_plus)-1);

theta_minus(1, :) = theta_minus1;
theta_plus(1, :)  = theta_plus1;

for t = 2:size(y, 1)
        
    for i = 1:(length(alpha_minus)-1)
        theta_minus(t, i) = beta_minus(nprmtrs*(i-1)+1) + beta_minus(nprmtrs*(i-1)+2) * theta_minus(t - 1, i) + beta_minus(nprmtrs*i) * abs(y(t - 1) / sqrt(sigmasq(t - 1)));
    end
    
    for i = 1:(length(alpha_plus)-1)
        theta_plus(t, i) = beta_plus(nprmtrs*(i-1)+1) + beta_plus(nprmtrs*(i-1)+2) * theta_plus(t - 1, i) + beta_plus(nprmtrs*i) * abs(y(t - 1) / sqrt(sigmasq(t - 1)));
    end
    
end

tinv_minus = tinv(0.5 - alpha_minus, nu);
tinv_plus  = tinv(0.5 + alpha_plus, nu);

q_minuscur = zeros(size(y, 1), 1);
for j = 1: (length(alpha_minus)-2)
    q_minus(:, j) = q_minuscur + theta_minus(:, j) .* (tinv_minus(j + 1) - tinv_minus(j));
    q_minuscur = q_minus(:, j);
end

q_pluscur = 0;
for j = 1: (length(alpha_plus)-2)
    q_plus(:, j) = q_pluscur + theta_plus(:, j) .* (tinv_plus(j + 1) - tinv_plus(j));
    q_pluscur = q_plus(:, j);
end