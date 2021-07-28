%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script plots the density of a beta distribution with parameters a&b.
% Values of a beta distribution are in [0,1].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GENERAL COMMENTS
% For the density to be skewed towards the right, we must have a>b. 
% For it not to be too narrow, a and b should not be very high.

% We would like to choose a and b so that about 70% of the mass is in the
% last quarter of the support (ie, the last 30 mins in a 2h period):
% betainv(1-0.7, a, b) \approx 0.75: 

% Beta parameters
a = 6; b = 1.61
betainv(1-0.7, a, b) % check this is approx 0.75


%% Density plot
x = 0:0.01:1;
y = betapdf(x, a, b);

font = 'Century Schoolbook';
width=650; height=420;

figure;
set(gcf,'units','points','position',[0,0,width,height]); % figure dimensions
xtime = 120*(x-1);                                       % x-axis from -120 to 0
% x2 and y2 needed to define closed area to be shaded 
x2 = [xtime, fliplr(xtime)];
y2 = [0*x,   fliplr(y)]; 
hold on;
fill(x2, y2, 'g', 'FaceAlpha', 0.3);                     % fill inside the curves
plot(xtime, y, 'LineWidth', 2, 'Color', '#77AC30');      % line plot of density
g=gca;
set(g, 'Linewidth', 1, 'FontSize', 20, 'FontName', font);
xlabel('times [mins]');
ylabel('Beta PDF');

file = fullfile(folder, 'BetaPDF')
print(file, '-dpng');
close

