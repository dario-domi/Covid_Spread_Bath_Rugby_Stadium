%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function simulating n_people individuals arriving at a match and joining 
% the shortest among n_queues queues to enter. Individuals are checked-in
% into the stadium at an exponential rate of mean ticket_rate. 
% a and b are parameters of the beta distribution used to draw random
% arrival times of the n_people individuals. If plotting=true, two plots
% are generated and saved (details inside function body). 
% pic_folder is the folder where pictures will be saved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mean_waiting_time, queue_length_records, time_spent_in_queue] = ...
          Queue_simulation(n_people, n_queues, ticket_rate, a, b, plotting, pic_folder)

    arrival_times = 130*betarnd(a*ones(1,n_people),b*ones(1,n_people))-5; % random arrival times of individuals 
    arrival_times = sort(arrival_times);
    
    queues = cell(n_queues, 1); % at each time step, queues{i} will contain the ID of all the people currently in queue i

    checkin_time = nan(n_queues, 1);          % time of completing next checkin in each queue
    % First column of queue_length_records: time of an event (either a new arrival or a person checking in).
    % Further cols:                         length of each line immediately after the event.
    queue_length_records = zeros(2*n_people + 1, 1 + n_queues);
    event = 2;                                % event=1 is the gate opening at time 0, all queues empty
    people_id = 1;
    time_spent_in_queue = zeros(n_people, 2); % row i: time of joining the queue and entering the stadium for person i

    % This is the main loop: an event is either a new arrival or a person
    % checking in into the stadium
    while event < 2 * n_people + 1
        % Person arrives and joins shortest queue
        arrival_time = arrival_times(people_id);
        time_spent_in_queue(people_id, 1) = arrival_time;
        queue_length = queue_length_records(event-1, 2:end); % length of each queue just before person arrives
        queue_id = find(queue_length==min(queue_length), 1); % index of shortest queue
        queues{queue_id} = [queues{queue_id}, people_id];    % insert new person in the shortest queue
        if length(queues{queue_id}) == 1         
            checkin_time(queue_id) = arrival_time + exprnd(ticket_rate); % compute check-in time of only person in the queue
        end
        % Note: if queue was not empty before latest arrival, check-in time
        % of first person in that queue will have been computed already
        % inside the followin while loop (see later).

        % Record info just after last arrival (arrival time and new queue lengths)
        queue_length_records(event, 1)       = arrival_time;
        for i=1:n_queues
            queue_length_records(event, i+1) = length(queues{i});
        end

        % See when next person arrives
        people_id = people_id + 1;
        if people_id > n_people
            arrival_time = Inf;
        else
            arrival_time = arrival_times(people_id);
        end
        next_checkin = min(checkin_time);   % time of next check-in, minimum among all queues
        event = event + 1;                  % next event will either be a new arrival or a check-in
        
        % The following loop checks in all the people up to the time of latest arrival
        while ~isnan(next_checkin) & (next_checkin < arrival_time)
            queue_id = find(checkin_time == next_checkin, 1);  % queue where next check-in happens
            temp = queues{queue_id};                           % list of all people in that queue
            time_spent_in_queue(temp(1), 2) = next_checkin;    % store check-in time of first person in the queue
            queues{queue_id} = temp(2:end);                    % remove person from the queue...
            if ~isempty(queues{queue_id})                      % ...and compute next check-in time in that queue
                checkin_time(queue_id) = next_checkin + exprnd(ticket_rate); 
            else
                checkin_time(queue_id) = nan;                  % if queue is empty, next check-in is unknown
            end
            % Store time of last check-in and updated queue lengths
            queue_length_records(event, 1)       = next_checkin;
            for i=1:n_queues
                queue_length_records(event, i+1) = length(queues{i});
            end
            
            next_checkin = min(checkin_time);  % compute the time of next check-in (if any)
            event = event + 1;
        end
    end

    mean_waiting_time = mean(diff(time_spent_in_queue,1,2)); % average time a person has spent queueing
    
    %% If plotting==true, produce the following plots
    if plotting
        font = 'Century Schoolbook';
        width=650; height=420;
        
        % FIGURE: LENGTH OF QUEUES AS FUNCTION OF TIME
        figure;
        set(gcf,'units','points','position',[0,0,width,height]);
        hold on
        for i = 1:n_queues % time shift of 2 hours, so that 0 becomes starting time of the match
            stairs(queue_length_records(:, 1)-120, ...
                   queue_length_records(:, i+1), 'LineWidth', 1.5);
        end
        hold off
        % Fancier graphical specifications
        box on
        M = max(max(queue_length_records(:, 2:end))); % max # of people in a queue
        ylim([0, M+1]);
        g=gca;
        set(g, 'Linewidth', 1, 'FontSize', 18, 'FontName', font);
        %    set(g, 'Position', [0.1, 0.15, 0.87, 0.75]);
        xlabel('time [mins]')
        ylabel('queue length')
        g.XAxis.TickValues = -140:20:140;      % specify position of x-ticks
        g.XAxis.MinorTick = 'on';
        g.XAxis.MinorTickValues = -140:10:140; % speficy position of x minor-ticks
        g.YAxis.MinorTick = 'on';
        g.YAxis.MinorTickValues = 0:100;       % speficy position of x minor-ticks
        % Legend
        labels = cell(n_queues, 1);
        for i = 1:n_queues
            labels{i} = [' Queue ', num2str(i)];
        end
        legend(labels, 'Position', [0.18, 0.72, 0.15, 0.14], 'FontSize', 14);
        file = fullfile(pic_folder, 'Queues_length.png');
        saveas(gcf, file)
        close

        % FIGURE: 2 PLOTS, one histogram of individuals' waiting times in
        % the queue, and the latter against time of joining the queue
        figure;
        width=800; height=420;
        set(gcf,'units','points','position',[0,0,width,height]);

        subplot(1,2,1) % histogram of queue waiting times
        histogram(diff(time_spent_in_queue,1,2), 20, 'LineWidth', 0.7)
        set(gca, 'Linewidth', 0.8, 'FontSize', 15, 'FontName', font);
        box on;
        xlabel('time spent waiting in queue [min]')
        ylabel('number of people')

        subplot(1,2,2)
        scatter(time_spent_in_queue(:,1), diff(time_spent_in_queue,1,2), 30, ...
            'MarkerEdgeColor','k', 'MarkerFaceColor', [0 .5 .2], ...
            'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5,  'LineWidth',0.7);
        set(gca, 'Linewidth', 0.8, 'FontSize', 15, 'FontName', font);
        box on;
        xticks(0:20:160);
        xl = xlim;
        xlim([0.8*xl(1), 1.03*xl(2)])
        xlabel('time of joining the queue [min]')
        ylabel('time spent waiting in queue [min]')
        file = fullfile(pic_folder, 'Waiting_time_statistics.png');
        saveas(gcf, file);
        close
    end
end