function out = findStateEvents(stateSearch, condensedStates, timeData, filenames)
starts = zeros([100 2]); %pre-allocating, but of course there may be more or fewer than 100 events
ends = zeros([100 1]);
traceId = zeros([100 1]);
numEv = 0;
N = length(condensedStates);
beginState = stateSearch(1,:);
for i0 = 1:N
    states = condensedStates{i0};
    n = size(states,1);
    for i1 = 1:n-1
        if compareStates(beginState,states(i1,:))
            i2 = i1+1;
            for row = 2:size(stateSearch,1)
                if stateSearch(row,1) == Inf 
                    continue
                end
                if stateSearch(row-1,1) == Inf   
                    while i2<=n
                        if compareStates(stateSearch(row,:),states(i2,:))
                            break
                        end
                        i2 = i2+1;
                    end
                else
                    if ~compareStates(stateSearch(row,:),states(i2,:))
                        break
                    elseif row == size(stateSearch,1)
                        %we found a segment which matches the search pattern through the end
                        traceId(numEv+1) = i0; %keeps track of the trace number
                        starts(numEv+1) = i1;  %starting position of the event
                        ends(numEv+1) = i2; %ending position of the event
                        numEv = numEv + 1;
                    end
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
    startTimes(i) = timeData{traceId(i)}(starts(i));
    endTimes(i) = timeData{traceId(i)}(ends(i));
    out.timeLengths(i) = timeData{traceId(i)}(ends(i))-timeData{traceId(i)}(starts(i)+1); 
    % ^the time length spent away from the base state
    tempTime = timeData{traceId(i)}(starts(i):(ends(i)+1));
    out.timeList{i} = tempTime;
    out.timeDiff{i} = diff(tempTime);
    out.begin(i) = tempTime(2)-tempTime(1);
    out.last(i) = tempTime(end)-tempTime(end-1);
    out.eventList = condensedStates{traceId(i)}(starts(i):ends(i),:);
end


end