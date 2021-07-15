function [TicketerRisk,QueueRisk] = RunQueueModel(N_total,Gates, Groups, QueueSpace, TicketRate, Ticketers, OpenEarly, Start, ArrivalSd, Prevalence)
% N_Total = total number of people at the event; 5000
% Gates = number of gates 5
% Groups =  number of time slots 1
% QueueSpace = Proportion of people using gate which can queue at once 10
N = N_total/Gates; % Total entering each gate
Spaces = N/QueueSpace;

% TicketRate = 1/4; % time taken to process ticket in min
% Ticketers = 4; % number of ticket processors
% OpenEarly = 15; % venue opens x minutes before first ticket time
% Start = 60; %Time before event of first ticket

% ArrivalSd = 15; 
% Prevalence = 0.02;

SlotGaps = Start/Groups;
GroupTimes = 0:SlotGaps:Start-SlotGaps;
IndivGroup = randi(Groups,1,N);
ArrivalMean = GroupTimes(IndivGroup);

ArrivalTimes = normrnd(ArrivalMean,ArrivalSd); 
Open = min(ArrivalMean) - OpenEarly;

%attendees
Infected = zeros(1,N);
seeds = binornd(N,Prevalence); %Number of positives: should also be based off testing
InfectedInd = randsample(N,seeds); % select positives randomly
Infected(InfectedInd) = 1; % 1 if infected 0 ow
%Ticketers
InfectedTicketers_N = binornd(Ticketers,Prevalence);
InfectedTicketers = randsample(Ticketers,InfectedTicketers_N);

TicketerRisk = zeros(1,N);
QueueRisk = zeros(1,N);
QueueLength = [];
Queue = [];
Ts = [];
Tmin = floor(min(ArrivalTimes));

figure(1)
hist(ArrivalTimes)
hold on;
line([Open, Open], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','--');
line([0, 0], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','-.');
line([Start, Start], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','-');
%% simulation
Time = Tmin;
while sum(isnan(ArrivalTimes)) < N
    Time = Time + 1;
    Ts = [Ts Time];
    % arrivals
    NewQueue = find(ArrivalTimes <= Time); % number there upon opening
    ArrivalTimes(NewQueue) = NaN;
    NewQueue = NewQueue(randperm(length(NewQueue)));
    Queue = [Queue NewQueue];
    % removals
    if Time >= Open
        OldQueue = poissrnd((1/TicketRate)*Ticketers);
        Remove = min(OldQueue,length(Queue));
        Ticketer_Removed = randi(Ticketers,1,Remove);
        N_infectedTicketer = find(Ticketer_Removed == InfectedTicketers);
        TicketerRisk(Queue(N_infectedTicketer)) = 1;
        if Remove == length(Queue)
            Queue = [];
        else
            Queue = Queue(Remove+1:end);
        end
    end
    QueueLength = [QueueLength length(Queue)]; %maybe used later to determine crowding
end

figure(2)
plot(Ts,QueueLength)


end

