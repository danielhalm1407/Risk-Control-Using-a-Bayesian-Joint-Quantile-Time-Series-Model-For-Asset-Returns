function [q_minus, q_plus, theta_minus, theta_plus] = q_norm_BJSAVL(y, alpha_minus, alpha_plus, param)
%**************************************************************************
% 
% Compute the quantile time series.
%
%**************************************************************************
beta_minus = param(1:(3*(length(alpha_minus)-1)));
tot = 3 * (length(alpha_minus)-1);
beta_plus = param((tot+1):(tot+3*(length(alpha_plus)-1)));
tot = tot + 3 * (length(alpha_plus)-1);

theta_minus1 = param((tot+4):(tot+length(alpha_minus)+2));
tot = tot + length(alpha_minus)-1;
theta_plus1 = param((tot+1):(tot+length(alpha_plus)-1));

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
        theta_minus(t, i) = beta_minus(nprmtrs*(i-1)+1)  + beta_minus(nprmtrs*(i-1)+2) * theta_minus(t - 1, i) + beta_minus(nprmtrs*i) *(y(t - 1) < 0) * abs(y(t - 1) / sqrt(sigmasq(t - 1)));
    end
    
    for i = 1:(length(alpha_plus)-1)
        theta_plus(t, i) = beta_plus(nprmtrs*(i-1)+1)  + beta_plus(nprmtrs*(i-1)+2) * theta_plus(t - 1, i) + beta_plus(nprmtrs*i) * (y(t - 1) < 0) * abs(y(t - 1) / sqrt(sigmasq(t - 1)));
    end
end  
norminv_minus = norminv(0.5 - alpha_minus);
norminv_plus  = norminv(0.5 + alpha_plus);

q_minuscur = zeros(size(y, 1), 1);
    for j = 1: (length(alpha_minus)-2)
        q_minus(:, j) = q_minuscur + theta_minus(:, j) .* (norminv_minus(j + 1) - norminv_minus(j));
        q_minuscur = q_minus(:, j);
    end
    
    q_pluscur = 0;
    
    for j = 1: (length(alpha_plus)-2)
        q_plus(:, j) = q_pluscur + theta_plus(:, j) .*  (norminv_plus(j + 1) - norminv_plus(j));
        q_pluscur = q_plus(:, j);
    end


