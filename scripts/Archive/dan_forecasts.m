% THIS SCRIPT IS USED TO FORECAST CONDITIONAL RETURNS QUANTILES

% check the current working directory
pwd

% go to the correct directory
% cd('scripts/Archive');

% load in the s&p500 returns data in the sp500_interday_returns.xlsx file
data = readtimetable('sp500_interday_returns.xlsx');



%% Set parameters for the MCMC
% number of quantiles, k 
k = 8;

alpha_minus = linspace(0, 0.5, k+2);
alpha_plus  = linspace(0, 0.5, k+2);
% alpha_minus = [0, 0.25, 0.4, 0.45, 0.475,0.49, 0.5];
% alpha_plus = [0, 0.25, 0.4, 0.45, 0.475,0.49, 0.5];

burnin      = 100; % set the burn-in period for the MCMC
numberofits = 100; % set the number of iterations for the MCMC before we get the posterior means
every       = 1; % set a thinning parameter for the MCMC



%% Initial Cleaning
% convert the data to an array
ret_SP500 = table2array(data); 

% drop any Nans and 0 values
ret_SP500 = ret_SP500(~isnan(ret_SP500) & ret_SP500 ~= 0, :);

% return the dimensions of the data
size(ret_SP500)

%return the type of the data
class(ret_SP500)

% Fit the model only on the first 10 years of data (2520 trading days)
end_idx = 2520; % 10 years of trading days

%% Previously sepearated training data outside of the MH function
training_data = ret_SP500(1:end_idx, :);

% Forecast over the last N days of the training data (to start the latent process)
% % + all the remaining data
N = 100; % Set N to the desired number of days
%y = ret_SP500((end_idx+1-N):end, :);
y = ret_SP500((end_idx+1):end, :);

% check if training_data has any NaN values
any(isinf(training_data))

% inspect the first few rows of the training data
training_data(1:5, :)

% Check dimensions of the training data
size(training_data)

% Check dimensions of the y data
size(y) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                               11
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BJSAV 
% start a count of how long this takes
tic

% Without forecasts, just parameters
%[holdbeta_minus_BJSAV_5_norm_SP500, holdbeta_plus_BJSAV_5_norm_SP500, holdq_minus_BJSAV_5_norm_SP500, holdq_plus_BJSAV_5_norm_SP500, holdtheta_minus_BJSAV_5_norm_SP500, holdtheta_plus_BJSAV_5_norm_SP500, holdtheta_minus1_BJSAV_5_norm_SP500, holdtheta_plus1_BJSAV_5_norm_SP500, holdmu_BJSAV_5_norm_SP500, holdsigvar_BJSAV_5_norm_SP500, holdloglike_BJSAV_5_norm_SP500, accept_BJSAV_5_norm_SP500, aveJD_BJSAV_5_norm_SP500, TIME_BJSAV_5_norm_SP500] = MHRWIK_PT(training_data, alpha_minus, alpha_plus, numberofits, burnin, every, 1, exp(linspace(0, -0.1, 3)));


% With Forecasts
[
    holdbeta_minus_BJSAV_5_norm_SP500, holdbeta_plus_BJSAV_5_norm_SP500, ...
    holdq_minus_BJSAV_5_norm_SP500, holdq_plus_BJSAV_5_norm_SP500, ...
    holdtheta_minus_BJSAV_5_norm_SP500, holdtheta_plus_BJSAV_5_norm_SP500, ...
    holdtheta_minus1_BJSAV_5_norm_SP500, holdtheta_plus1_BJSAV_5_norm_SP500, ...
    holdmu_BJSAV_5_norm_SP500, holdsigvar_BJSAV_5_norm_SP500, ...
    holdloglike_BJSAV_5_norm_SP500, holdpredpdf_BJSAV_5_norm_SP500, ...
    holdq_minus_forecast_BJSAV_5_norm_SP500, holdq_plus_forecast_BJSAV_5_norm_SP500, ...
    accept_BJSAV_5_norm_SP500, aveJD_BJSAV_5_norm_SP500, TIME_BJSAV_5_norm_SP500, ...
    holdtheta_minus_forecast_BJSAV_5_norm_SP500, holdtheta_plus_forecast_BJSAV_5_norm_SP500] = ...
    MHRWIK_PT_forecasts(ret_SP500, alpha_minus, alpha_plus, ...
 numberofits, burnin, every, 1, exp(linspace(0, -0.1, 3)), end_idx);
save BJSAV_5_norm_SP500.mat -v7.3 
% stop the timer and display the time taken
toc

%% Check some of the results
size(holdbeta_minus_BJSAV_5_norm_SP500)

size(holdq_minus_forecast_BJSAV_5_norm_SP500)

%% Check Autocorrelations for Beta Parameters
% This is done to tweak the burn-in, iterations and thinning parameters
% close all previous figures
close all

figure(1)
for i = 1:3
    subplot(2,3,i) 
    autocorr(holdbeta_minus_BJSAV_5_norm_SP500(:, i), 'NumLags', 99);
    subplot(2,3,i+3)
    autocorr(holdtheta_minus1_BJSAV_5_norm_SP500(:, i), 'NumLags', 99);
    
end


%% Check convergence of the parameters

figure(2)
for i = 1:3
    subplot(3,3,i) 
    plot(holdbeta_minus_BJSAV_5_norm_SP500(:, i))
    title(['Beta Minus Parameter ', num2str(i)])
    subplot(3,3,i+3)
    plot(holdtheta_minus1_BJSAV_5_norm_SP500(:, i))
    title(['Theta Minus Initial Value ', num2str(i)])
    subplot(3,3,i+6)
    % Use end instead of -1 for the last index in MATLAB
    plot(squeeze(holdtheta_minus_BJSAV_5_norm_SP500(:,end,i)))
    title(['Theta Minus Final Value ', num2str(i)])
end

%% Check the theta_minus parameters in a plot

size(holdtheta_minus_BJSAV_5_norm_SP500)

% calculate the column means of the theta_minus parameters
% convert the 100x2520x9 matrix into a 2520x9 matrix storing the column means
% for each of the 9 (one for each quantile), 100x2520 matrices.
theta_minus_means = squeeze(mean(holdtheta_minus_BJSAV_5_norm_SP500, 1));
size(theta_minus_means)

figure(3)
plot(theta_minus_means)

%% Calculate the posterior means of the quantiles and plot them across time
% holdq_minus_forecast_BJSAV_5_norm_SP500 is 100 x 3766 x 8
% Take the mean over the first dimension (MCMC samples) to get a 3766 x 8 matrix

q_forecasts = squeeze(mean(holdq_minus_forecast_BJSAV_5_norm_SP500, 1));

% plot the quantiles across time
figure(4)
plot(q_forecasts)

%% Inspect the tail parameter forecasts

% Take the mean over the first dimension (MCMC samples) for the first forecast day
first_end_tail_forecast = squeeze(mean(holdtheta_minus_forecast_BJSAV_5_norm_SP500(:,1,:), 1)); % 1x9 vector

% Take the mean over the first dimension (MCMC samples) for the last estimation day
last_end_tail_estimation = squeeze(mean(holdtheta_minus_BJSAV_5_norm_SP500(:,end,:), 1)); % 1x9 vector

first_end_tail_forecast
last_end_tail_estimation


%% Calculate the posterior means of the tail parameters and plot them across time

theta_forecasts = squeeze(mean(holdtheta_minus_forecast_BJSAV_5_norm_SP500, 1));

% plot the theta_minus parameters across time
figure(5)
plot(theta_forecasts)

%% Calculate the posterior means of each of the parameters
params_long = [holdbeta_minus_BJSAV_5_norm_SP500, holdbeta_plus_BJSAV_5_norm_SP500, holdtheta_minus1_BJSAV_5_norm_SP500, holdtheta_plus1_BJSAV_5_norm_SP500];

% the posterior means are the column means of the parameters
param = mean(params_long, 1);

% create separate parameter vector for forecasting
param_forecast = param; % copy the parameters to a new variable for forecasting

% replace the holdtheta_minus1_BJSAV_5_norm_SP500 posterior means with the last_end_tail_estimation
% these should be the 54th through the 63rd parameters in the param vector
idx_theta_minus1 = 54; % index of the first theta_minus1 parameter in the param vector
param_forecast(idx_theta_minus1 + 1:idx_theta_minus1 + length(last_end_tail_estimation)) = last_end_tail_estimation;

% display the parameters
%disp('Posterior Means of Parameters:');
%disp(param_forecast);

%display these updated theta_minus1 values
disp(['theta_minus1 for forecasting: ' num2str(param_forecast(idx_theta_minus1 + 1:idx_theta_minus1 + length(last_end_tail_estimation)))]);




%% Compute the quantile time series forecasts based upon these parameters
% select the out of sample data to forecast the quantiles
y = ret_SP500((end_idx+1):end, :);

% call the q_norm_BJSAV function to compute the quantile time series
[q_minus, q_plus, theta_minus, theta_plus] = q_norm_BJSAV(y, alpha_minus, alpha_plus, param_forecast);

% eliminate the first N rows or days (these are part of the training data and only used 
% to start iterating the latent processes)
%q_forecasts = q_minus(N+1:end, :);
q_forecasts = q_minus;

%% plot all the q_minus quantiles (each quantile is a column)
% across time (each row is a time point)
figure(6)
plot(q_forecasts)

%%
% Save Out the Forecast Quantiles to a .mat file
save('../../data/q_minus_BJSAV_5_norm_SP500.mat', 'q_forecasts');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Careful to Not Immediately Run the Below: It Could Take a Long Time (20 mins est)
%% REPEAT FOR A 10 YEAR WINDOW THAT MOVES FORWARD EVERY YEAR

% Possibly choose different input parameters for MCMC
burnin      = 100; % set the burn-in period for the MCMC
numberofits = 100; % set the number of iterations for the MCMC before we get the posterior means
every       = 1; % set a thinning parameter for the MCMC

% calculate how many observations we have after the first 10 years
rem_observations = size(ret_SP500, 1) - 2520;

%find the number of years in these observations
n_years = ceil(rem_observations / 252); % 252 trading days in a year,
% round up to include the last, partial year

% find the remaining number of observations in the last year
% which is the remainder after dividing rem_observations by 252
rem_observations_last_year = rem(rem_observations, 252);

% Start by definining the indices to select corresponding to each of these windows
% Each window is 2560 days long, and each moves forward by 1 year (252 trading days)
% yet we only go up to the last trading day of the previous full year for which we have data
% which results in 14 windows, since we go from the window of 2000 through 2009 to the
% window of 2014 through 2023, which is 15 windows in total.

n_windows = n_years; 
%n_windows = 3;

% Create a vector storing the start:end indices for each window, starting 10 years into the data
% have the start indices go from 1 to 253, to 505, to 757, etc until 10 years prior to the last trading
% day of the last year of full data, which is end - rem_observations_last_year
start_indices = 1:252:(1 + 252*(n_windows-1)); % Start indices for each window: 1, 253, 505, ..., 1+252*13
% Create the end indices for each window, which is 2560 days after the start indices
end_indices = start_indices + 2520 - 1 + 252;
% apply a cieling to the end indices to ensure they do not exceed the last trading day of the data
end_indices = min(end_indices, size(ret_SP500, 1));
% Create a starting and ending index matrix
indices = [start_indices; end_indices]';

% display the indices
disp('Indices for each window:');
disp(indices);

% check if the remaining observations in the last year are less than 252
% and is equal to the difference between the last two end indices
disp([end_indices(end) - end_indices(end-1), rem_observations_last_year]);

%%
% Select n_windows of data, each of which is split within the MHRWIK_PT_forecats function
% into a training and testing set, where the training set is the first 2520 days
% and the testing set is the next 252 days.

% Initialise a cell array to store each of these datasets 
% (each of which has 2520 training days and up to 252 testing days)
y_list = cell(n_windows, 1);
for i = 1:n_windows
    % Select the data for the current window
    y_list{i} = ret_SP500(indices(i, 1):indices(i,2), :);
    
    % Display the size of the current window's data
    disp(['Size of window ', num2str(i), ': ', num2str(size(y_list{i}))]);
end

%%
%check is y_list{1} has nans or 0s
any(isnan(y_list{1}))
any(y_list{1} == 0)

%% Fit the model and extract quantile forecasts for each window

% Initialise a n_windows*252 x k matrix array to store the quantile forecasts
q_minus_all = zeros(size(ret_SP500,1), k);


for i = 1:n_windows
    %start timer
    tic

    % Fit the model to the training and forecast data
    % With Forecasts
    [holdbeta_minus_BJSAV_5_norm_SP500, holdbeta_plus_BJSAV_5_norm_SP500, ...
        holdq_minus_BJSAV_5_norm_SP500, holdq_plus_BJSAV_5_norm_SP500, ...
        holdtheta_minus_BJSAV_5_norm_SP500, holdtheta_plus_BJSAV_5_norm_SP500, ...
        holdtheta_minus1_BJSAV_5_norm_SP500, holdtheta_plus1_BJSAV_5_norm_SP500, ...
        holdmu_BJSAV_5_norm_SP500, holdsigvar_BJSAV_5_norm_SP500, ...
        holdloglike_BJSAV_5_norm_SP500, holdpredpdf_BJSAV_5_norm_SP500, ...
        holdq_minus_forecast_BJSAV_5_norm_SP500, holdq_plus_forecast_BJSAV_5_norm_SP500, ...
        accept_BJSAV_5_norm_SP500, aveJD_BJSAV_5_norm_SP500, TIME_BJSAV_5_norm_SP500, ...
        holdtheta_minus_forecast_BJSAV_5_norm_SP500, holdtheta_plus_forecast_BJSAV_5_norm_SP500] = ...
        MHRWIK_PT_forecasts(y_list{i}, alpha_minus, alpha_plus, ...
    numberofits, burnin, every, 1, exp(linspace(0, -0.1, 3)), end_idx);
    
    % stop the timer and display the time taken
    toc

    % store the posterior means of the quantile forecasts
    q_forecasts = squeeze(mean(holdq_minus_forecast_BJSAV_5_norm_SP500, 1));

    % Save the quantile forecasts the year following this window to the q_minus_all matrix
    % this fills in up to 252 rows of the q_minus_all matrix at a time
    q_minus_all((indices(i,1)+end_idx):indices(i,2),:) = q_forecasts;

    % confirm that the quantiles have been saved correctly
    disp(['Quantiles for window ', num2str(i), ' saved.']);
end



%% Plot the quantile forecasts joined for all these windows
size(q_minus_all)

% select everything but the first 2520 rows (the data that was
% only ever used to train)
q_minus_all_select = q_minus_all((end_idx+1):end, :);

figure(7)
plot(q_minus_all_select)

%% Save out the q_minus_all_p matrix to a .mat file
save('../../data/q_minus_all_BJSAV_5_norm_SP500.mat', 'q_minus_all_select');

