%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script simulates the arrival of people at a match, who join one of
% n_queues lines to access the stadium. The code below uses the function
% Queue_simulation (see the latter for more details on the simulation of
% the arrival and queuing process) to produce and save graphical statistics
% concerning average waiting time in the queue, length of queues etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
close all;

%% General variables
ticket_rate = 1/4;   % average time to process a ticket at check-in (minutes)
n_total = 700;       % total number of people to enter the stadium (some may be pre-checked)
n_queues = 3;        % number of independent lines to enter the stadium
a = 6; b = 1.61;     % parameters of beta distribution (arrival times distribution)
folder = 'Pictures'; % folder where plots will be saved

%% Produce plot of Beta Density (check parameters in the script)
Beta_Density_Plot;

%% Run the experiment with no pre-checking, and save corresponding plots
pre_checking = 0;    % number of people to be pre-checked
plotting = true;     % plots will be generated when calling Queue_simulation()
n_people = n_total - pre_checking; % people who will go through standard check-in
Queue_simulation(n_people, n_queues, ticket_rate, a, b, plotting, folder);


%% Now simulate the fans' check-ins into the stadium when different amounts
% of fans are pre-checked, compute average waiting time in each case
% (through several Monte Carlo simulations), and produce corresponding plot

plotting = false;
pre_checking_values = linspace(0, 650, 14);                  % vector with different proportions of pre-checked fans (out of 700)
mean_waiting_times = zeros(length(pre_checking_values), 1);  % will contain average waiting time in the queue
n_tests = 100;                                               % # of MC samples for each element in pre_checking_values

for i = 1:length(pre_checking_values)
    n_people = n_total - pre_checking_values(i);   % number of fans who will do standard check-in
    aggregate_waiting_time = 0;
    for j = 1:n_tests
        aggregate_waiting_time = aggregate_waiting_time + ...
            Queue_simulation(n_people, n_queues, ticket_rate, a, b, plotting); % add mean waiting time for one sample
    end
    mean_waiting_times(i) = aggregate_waiting_time/n_tests;  % store average MWT of the n_test samples
end

%% Produce plot of average waiting time against proportion of pre-checked
font = 'Century Schoolbook';
width=650; height=420;
figure;
set(gcf,'units','points','position',[0,0,width,height]);
scatter(pre_checking_values, mean_waiting_times, 90, 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1)
box on
g=gca;
set(g, 'Linewidth', 1, 'FontSize', 18, 'FontName', font);
xlabel( ['Number of pre checking visitors (out of ', num2str(n_total), ')'])
ylabel('Average waiting time in queue [min]', 'FontSize', 16)
g.YAxis.MinorTick = 'on';
g.YAxis.MinorTickValues = 0:2.5:25;
file = fullfile(folder, 'Effect_of_prechecking.png');
saveas(gcf, file);
close;