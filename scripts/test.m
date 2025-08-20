
% MAKE SOME SAMPLE DATA

% Create a 3x2 matrix
matrix = [1, 2; 3, 4; 5, 6];

% Define the file path
filePath = "data/matrix.csv";

% Save the matrix as a CSV file
writematrix(matrix, filePath);

%% RE-IMPORT DATA
% Get the filepath for the data
filePath = "data/matrix.csv";

% Load the data
data = readmatrix(filePath);
   
% Display the loaded data
disp(data);



%% GENERAL PRACTICE

% Define a new double (numeric) variable
x=10;

% Define a char variable
w = 'New';

% Define a new string variable
z = "York";

% Display the current variables and classes
whos

% add multiple commands on one line
you = 25; me = 10;

%% MATRICES AND VECTORS
clc, clearvars

% Create a row vector from 1 to 10 and transpose it
x = 1:10;
% Get the transpose of the row vector
x = x';
% Generate 31 (default 10) values in this interval  from 20 through 50
x = linspace(20,50,31);

% 
A = [1,2;2,10];

% Element-wise operations
% Perform element-wise multiplication of matrix A with itself
result = A .* A;

% Index an element from A
% Access the element in the first row and second column of A
element = A(1, 2);

%% Functions

x = linspace(0,5)
y = ((-(x-3).^2)) + 10

%plot(x,y,'*');

[MaxVal, I] = max(y)



%% Plots
clc, clearvars


% Set up y as an anonymous function
yFunc = @(x) ((-(x-3).^2)) + 10; % Define the anonymous function

x = linspace(-10,10)
y1 = yFunc(x); % Evaluate the anonymous function at the specified x values
y2 = yFunc(x) + 15
y3 = yFunc(x-2) + 10

% Create a new figure for plotting
figure(1)

% Plot the first set of data (y1) with blue diamond markers
plot(x,y1,'d','MarkerFaceColor','b','MarkerSize',4) % note that unlike in python and r,
% arguments are passed in the form of 'argument',value as opposed to
% argument = value.
xlabel('x'),ylabel('y'),title('Y vs. X') % Label the axes and set the title
grid on % Enable the grid for better visualization

hold on % Retain the current plot when adding new plots

% Plot the second set of data (y3) with magenta square markers
plot(x,y3,'ms')

hold on % Retain the current plot again

% Plot the third set of data (y2) with green circle markers
plot(x,y2,'go')

% Add a legend to differentiate the plots
legend('Y1','Y2','Y3')

%% Logic
clc, clearvars, close all

x = linspace(0,10);
y = sin(x);
thresh = 0.8;

plot(x,y,'.'), hold on, plot([0 10],[thresh thresh],'-r') %plot the horizontal line at 0.8 as a dashed red line

% Count how many y values are above 0.8
countAboveThreshold = sum(y > thresh);

% get the proportion above 
proportionAbove = countAboveThreshold / numel(y);

%% For Loops and Computation time

% vectorised version
clc, clearvars

A = randi(5,1,10e6);

tic
num3_if = sum(A==3);

if num3_if >= 0.2*length(A)
    disp("Yes")
end

Time_if = toc

% For loop version

tic
num3_for = 0;
for i = 1:length(A)
    if A(i) == 3;
        num3_for = num3_for + 1;
    end
end

if num3_for >=  0.2*length(A)
    disp("Yes")
end
Time_for = toc

% Display the computation times for both methods
disp(['Time taken for vectorized method: ', num2str(Time_if), ' seconds']);
disp(['Time taken for for loop method: ', num2str(Time_for), ' seconds']);


%% While Loops and Custom Functions

clc, clearvars
z = 100

reduce_z(z)