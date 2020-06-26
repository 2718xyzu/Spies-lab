function out = findCompletedEvents(baseState, condensedStates, timeData, filenames)
starts = zeros([100 2]); %pre-allocating, but of course there may be more or fewer than 100 events
ends = zeros([100 1]);
numEv = 0;
N = length(condensedStates);
for i0 = 1:N
    states = condensedStates{i0};
    n = size(states,1);
    for i1 = 1:n-1
        if all(states(i1,:) == baseState)
            for i2 = i1+1:n
                if all(states(i2,:) == baseState)
                    starts(numEv+1,:) = [i0 i1]; %keeps track of the trace number and starting position of the event
                    ends(numEv+1) = i2; %ending position of the event
                    numEv = numEv + 1;
                    break
                end
            end
        end
    end
end

starts = starts(1:numEv,:);
ends = ends(1:numEv,:);

out.filenames = arrayfun(@(x) filenames(x),starts(:,1))';
startTimes = zeros([numEv 1]);
endTimes = zeros([numEv 1]);
out.timeLengths = zeros([numEv 1]);
out.begin = zeros([numEv 1]);
out.last = zeros([numEv 1]);
out.timeList = cell([numEv 1]);
out.timeDiff = cell([numEv 1]);
out.eventList = cell([numEv 1]);
out.numEvents = numEv;

for i = 1:numEv
    startTimes(i) = timeData{starts(i,1)}(starts(i,2));
    endTimes(i) = timeData{starts(i,1)}(ends(i,2));
    out.timeLengths(i) = timeData{starts(i,1)}(ends(i,2))-timeData{starts(i,1)}(starts(i,2)+1); 
    % ^the time length spent away from the base state
    tempTime = timeData{starts(i,1)}(starts(i,2):(ends(i,2)+1));
    out.timeList{i} = tempTime;
    out.timeDiff{i} = diff(tempTime);
    out.begin(i) = tempTime(3)-tempTime(2);
    out.last(i) = tempTime(end-1)-tempTime(end-2);
    out.eventList = condensedStates{starts(i,1)}(starts(i,2):ends(i,2),:);
end


end