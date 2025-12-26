function [q_minus, q_plus, theta_minus, theta_plus] = q_norm_BJSSV(y, alpha_minus, alpha_plus, param)

beta_minus = param(1:(3*(length(alpha_minus)-1)));
tot = 3 * (length(alpha_minus)-1);
beta_plus = param((tot+1):(tot+3*(length(alpha_plus)-1)));
tot = tot + 3 * (length(alpha_plus)-1);
theta_minus1 = param((tot+1):(tot+length(alpha_minus)-1));
tot = tot + length(alpha_minus)-1;
theta_plus1 = param((tot+1):(tot+length(alpha_plus)-1));

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

norminv_minus = norminv(0.5 - alpha_minus);
norminv_plus  = norminv(0.5 + alpha_plus);

for t = 2:size(y, 1)

    theta_minus(t, :) = theta_minus(t - 1, :);
    theta_plus(t, :) = theta_plus(t - 1, :);
        
    for i = 1:(length(alpha_minus)-1)
        theta_minus(t, i) = sqrt(beta_minus(nprmtrs*(i-1)+1) + beta_minus(nprmtrs*(i-1)+2) * theta_minus(t - 1, i).^2 + beta_minus(nprmtrs*i) * (abs(y(t - 1) ./ sqrt(sigmasq(t - 1)))).^2);
    end
        
    for i = 1:(length(alpha_plus)-1)
        theta_plus(t, i) = sqrt(beta_plus(nprmtrs*(i-1)+1) + beta_plus(nprmtrs*(i-1)+2) * theta_plus(t - 1, i).^2 + beta_plus(nprmtrs*i) * (abs(y(t - 1) ./ sqrt(sigmasq(t - 1)))).^2);
    end    
end

q_minuscur = zeros(length(y), 1);
for j = 1: (length(alpha_minus)-2)
    q_minus(:, j) = q_minuscur + theta_minus(:, j) .* (norminv_minus(j + 1) - norminv_minus(j));
    q_minuscur = q_minus(:, j);
end

q_pluscur = zeros(length(y), 1);
for j = 1: (length(alpha_plus)-2)
    q_plus(:, j) = q_pluscur + theta_plus(:, j) .* (norminv_plus(j + 1) - norminv_plus(j));
    q_pluscur = q_plus(:, j);
end

