function [q_minus, q_plus, theta_minus, theta_plus] = q_norm_BJSAV(y, alpha_minus, alpha_plus, param)
% Computes quantile time series for a BJSAV model using normal innovations.
% INPUTS:
%   y           - observed data (time series)
%   alpha_minus - vector of lower quantile levels
%   alpha_plus  - vector of upper quantile levels
%   param       - parameter vector (contains all model parameters)
% OUTPUTS:
%   q_minus     - lower quantile time series
%   q_plus      - upper quantile time series
%   theta_minus - latent process for lower quantiles
%   theta_plus  - latent process for upper quantiles

% Extract beta parameters for lower quantiles from the parameter vector
% The first 3*(length(alpha_minus)-1) parameters correspond to the lower quantiles
% since the parameters are specidic to each quantile level.
% The first 3 parameters are for the first quantile, the next 3 for the second, and so on.
beta_minus = param(1:(3*(length(alpha_minus)-1)));
tot = 3 * (length(alpha_minus)-1);

% Extract beta parameters for upper quantiles from the big boy parameter vector
beta_plus = param((tot+1):(tot+3*(length(alpha_plus)-1)));
tot = tot + 3 * (length(alpha_plus)-1);

% Extract initial values for theta_minus and theta_plus - the local tail parameters
% The next (length(alpha_minus)-1) parameters are for the initial values of theta_minus (lower quantiles)
% The next (length(alpha_plus)-1) parameters are for the initial values of theta_plus (upper quantiles)
theta_minus1 = param((tot+1):(tot+length(alpha_minus)-1));

% someone had the above line of code as:
% theta_minus1 = param((tot+4):(tot+length(alpha_minus)+2)); why? what the heck were you thinking?
tot = tot + length(alpha_minus)-1;
theta_plus1 = param((tot+1):(tot+length(alpha_plus)-1));

% Display the initial values for theta_minus1
%disp('Initial values for theta_minus1:');
%disp(theta_minus1);

%**************************************************************************
% 
% Compute the quantile time series.
%
%**************************************************************************

nprmtrs = 3; % Number of parameters per quantile
q_minus = zeros(length(y), length(alpha_minus)-2); % Preallocate lower quantile output
q_plus  = zeros(length(y), length(alpha_plus)-2);  % Preallocate upper quantile output

sigmasq    = ones(length(y), 1); % Placeholder for conditional variance (not updated here)
theta_minus= zeros(length(y), length(alpha_minus)-1); % Latent process for lower quantiles
theta_plus = zeros(length(y), length(alpha_plus)-1);  % Latent process for upper quantiles

% Set initial values for latent processes
theta_minus(1, :) = theta_minus1;
theta_plus(1, :)  = theta_plus1;



% Recursively update latent processes for each time step
for t = 2:size(y, 1)
    % Update theta_minus for each lower quantile
    for i = 1:(length(alpha_minus)-1)
        theta_minus(t, i) = beta_minus(nprmtrs*(i-1)+1) + ... % the first mu parameter or intercept
                            beta_minus(nprmtrs*(i-1)+2) * theta_minus(t - 1, i) + ... % the second beta parameter that  multiplies the lag of theta for that quantile
                            beta_minus(nprmtrs*i) * abs(y(t - 1) / sqrt(sigmasq(t - 1))); % the third gamma parameter that multplies the lag of the abs normalised returns
    end
    
    % Update theta_plus for each upper quantile
    for i = 1:(length(alpha_plus)-1)
        theta_plus(t, i) = beta_plus(nprmtrs*(i-1)+1) + ...
                           beta_plus(nprmtrs*(i-1)+2) * theta_plus(t - 1, i) + ...
                           beta_plus(nprmtrs*i) * abs(y(t - 1) / sqrt(sigmasq(t - 1)));
    end
end


% Compute normal quantile values for minus and plus sides
norminv_minus = norminv(0.5 - alpha_minus);
norminv_plus  = norminv(0.5 + alpha_plus);

% Construct lower quantile time series from latent process
q_minuscur = zeros(size(y, 1), 1);
for j = 1: (length(alpha_minus)-2)
    q_minus(:, j) = q_minuscur + theta_minus(:, j) .* (norminv_minus(j + 1) - norminv_minus(j));
    q_minuscur = q_minus(:, j);
end

% Construct upper quantile time series from latent process
q_pluscur = 0;
for j = 1: (length(alpha_plus)-2)
    q_plus(:, j) = q_pluscur + theta_plus(:, j) .* (norminv_plus(j + 1) - norminv_plus(j));
    q_pluscur = q_plus(:, j);
end