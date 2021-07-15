clc
close all

% This is plotting the density of a beta distribution with parameters a and
% b. Values of a beta distribution are in [0,1].
figure;
a = 6; b = 1.11;
% 70% within last 30 min
%a = 6; b = 1.61
x = 0:0.01:1.02;
y = 125*betapdf(x, a, b);

plot(x,y)

% GENERAL COMMENTS
% For the density to be skewed towards the right, you must have a>b. 
% For it not to be too narrow, a and b should not be very high.

% We would like to choose parameters a and b, such that 
% betainv(0.3, a, b) = 0.75: 
% - The 0.3 is 1 - 70%. 
% - The 0.75 corresponds to the last half an hour in a range of two hours.

% Among many choices, decent parameters could be (feel free to play with others): 
% 1) a=7, b=2
% 2) a=6, b=1.7

%b =[1.7:0.01:1.8];

120*betainv(0.3, a,b)
% Note that they yield a betainv(0.3, a,b) slightly lower than 0.75, 
% but that looks reasonable to me to allow for someone arriving after the
% game.

t =1 - 30/120;

array = 120*betarnd(a,b,[10000]);
mean(array,'all')
median(array,'all')








