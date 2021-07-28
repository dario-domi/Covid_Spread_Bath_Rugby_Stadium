clc;
close all;

preChecking = 0;
N_Total = 700 - preChecking; % Total
N_Lines = 3;
N = N_Total / N_Lines; % Total entering each gate
Groups = 1; 

Queues = cell([N_Lines, 1]);

%TicketRate = 1/10 ;%+ normrnd(0,1); % time taken to process ticket in min
TicketRate = 1/5;
Ticketers = 1; % number of ticket processors
OpenEarly = 30;
Start = 120;

Prevalence = 0.02;

if Groups>1
SlotGaps = (Start-60)/Groups;
GroupTimes = 0:SlotGaps:Start-SlotGaps;
IndivGroup = randi(Groups,1,N);
ArrivalMean = GroupTimes(IndivGroup);
ArrivalSd = 15; 
ArrivalTimes = normrnd(ArrivalMean,ArrivalSd); 
Open = min(ArrivalMean) - OpenEarly;

histogram(ArrivalTimes, 20);
hold on
line([Open, Open], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','--');
line([0, 0], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','-.');
line([Start, Start], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','-');
hold off

else
a = 6;b = 1.61;
%a = 6,b=1.11
ArrivalTimes =130*betarnd(a*ones(1,N_Total),b*ones(1,N_Total))-5; 
Open = min(ArrivalTimes) - OpenEarly;
%figure;
%histogram(ArrivalTimes,20);
end
disp(median(ArrivalTimes));

QueueLength = [];

Ts = [];
Tmin = floor(min(ArrivalTimes));
disp('Tmim')
disp(Tmin)

%figure(1)
%histogram(ArrivalTimes);
%hold on
%line([Open, Open], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','--');
%line([0, 0], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','-.');
%line([Start, Start], ylim, 'LineWidth', 2, 'Color', 'r', 'LineStyle','-');
%hold off
%% simulation
Time = Tmin;

for i = 1:N_Lines
    Queues{i} = [];
end

time_to_checkin = 1000 * ones(N_Lines, 1);
ArrivalTimes = sort(ArrivalTimes);
length_data = zeros(2 * length(ArrivalTimes) + 1, 4);
records = 2;
n_people = 0;

while records < 2 * length(ArrivalTimes) + 1
    arrival_time = ArrivalTimes(n_people + 1);
    queue_length = zeros(N_Lines,1);
    for i = 1:N_Lines
        queue_length(i) = length(Queues{i});
    end
    queue_id = find(queue_length==min(queue_length), 1);
    Queues{queue_id} = [Queues{queue_id}, person];
    if length(Queues{queue_id}) == 1
        time_to_checkin(queue_id) = arrival_time + exprnd(TicketRate);
        shortest_time_to_checkin = min(shortest_time_to_checkin, time_to_checkin(queue_id));
    end
    n_people = n_people + 1;

    length_data(records, 1) = arrival_time;
    for i = 1:N_Lines
        length_data(records, i+1) = length(Queues{i});
    end
    records = records + 1;
    
    if n_people + 1 > length(ArrivalTimes)
        arrival_time = 900;
    end
    shortest_time_to_checkin = min(time_to_checkin);
    while shortest_time_to_checkin < arrival_time
        time = shortest_time_to_checkin;
        queue_id = find(time_to_checkin == shortest_time_to_checkin, 1);
        fprintf('queue_id=%d\n', queue_id);
        temp = Queues{queue_id};
        Queues{queue_id} = temp(2:end);
        if isempty(Queues{queue_id})
            time_to_checkin(queue_id) = 1000;
        else
            time_to_checkin(queue_id) = shortest_time_to_checkin + exprnd(TicketRate);
        end
        length_data(records, 1) = shortest_time_to_checkin;
        for i = 1:N_Lines
            length_data(records, i+1) = length(Queues{i});
        end
        records = records + 1;
        shortest_time_to_checkin = min(time_to_checkin);
    end
end

figure
hold on
for i = 1:N_Lines
    plot(length_data(:, 1), length_data(:, i+1));
end
hold off
xlabel('time')
ylabel('length of a queue')

labels = cell(N_Lines, 1);
for i = 1:N_Lines
    labels{i} = strcat('queue ', num2str(i));
end
legend(labels);

