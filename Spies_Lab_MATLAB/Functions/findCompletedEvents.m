function out = findCompletedEvents(baseState, condensedStates)

starts = zeros([100 2]); %pre-allocating, but of course there may be more or fewer than 100 events
ends = zeros([100 1]);
traceId = zeros([100 1]);
numEv = 0;
N = length(condensedStates);
for i0 = 1:N
    states = condensedStates{i0};
    n = size(states,1);
    for i1 = 1:n-1
        if all(states(i1,:) == baseState)
            for i2 = i1+1:n
                if all(states(i2,:) == baseState)
                    traceId(numEv+1) = i0; %keeps track of the trace number
                    starts(numEv+1) = i1;  %starting position of the event
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

out.eventList = cell([numEv 1]);
out.numEvents = numEv;

for i = 1:numEv
    out.eventList = condensedStates{traceId(i)}(starts(i):ends(i),:); 
    %output just the event classifications (including the base state on
    %either side)
end


end