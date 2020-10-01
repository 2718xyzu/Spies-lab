function out = findStateEvents(stateSearch, condensedStates, timeData, filenames, selection)
%stateSearch is a numerical array, with each row being a system state (the
%number of columns equals the number of channels)
%the wildcard "NaN" can appear in that array and stand in for any state,
%and a row of "Inf" means a multi-line wildcard; i.e.

%[ 1  1 ]    matches both  [ 1  1 ]   and   [ 1  1 ]
%[ Inf Inf ]               [ 1  2 ]         [ 2  1 ]
%[ 1  1 ]                  [ 1  1 ]         [ 2  2 ]
%                                           [ 1  2 ] 
%                                           [ 1  1 ]

%called by fillRowState when the search matrix is not in regex form


starts = zeros([100 1]); %pre-allocating, but of course there may be more or fewer than 100 events
ends = zeros([100 1]);
traceId = zeros([100 1]);
numEv = 0;

beginState = stateSearch(1,:);
for i0 = find(selection)'
    states = condensedStates{i0};
    n = size(states,1);
    for i1 = 1:n-1
        if compareStates(beginState,states(i1,:))
            i2 = i1+1;
            if size(stateSearch,1)==1 %should *really* not be inputting searches which are only one state long, but whatever                               
                traceId(numEv+1) = i0;
                starts(numEv+1) = i1;  %the start is the end
                ends(numEv+1) = i1; 
                numEv = numEv + 1;
                continue 
            end
            for row = 2:size(stateSearch,1)
                if stateSearch(row,1) == Inf 
%                     i2 = i2-1;
                    continue
                end
                if stateSearch(row-1,1) == Inf   
                    while i2<=n
                        if compareStates(stateSearch(row,:),states(i2,:))
                            if row == size(stateSearch,1)
                                %we found a segment which matches the search pattern through the end
                                traceId(numEv+1) = i0; %keeps track of the trace number
                                starts(numEv+1) = i1;  %starting position of the event
                                ends(numEv+1) = i2; %ending position of the event
                                numEv = numEv + 1;
                                break %remove this to make Inf wildcards "greedy"
                            else
                                break %get out of the Inf-directed loop to check the next search term
                            end
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
                    i2 = i2+1;
                    if i2>size(states,1)
                        break
                    end
                end
            end
        end
    end
end

starts = starts(1:numEv);
ends = ends(1:numEv);
traceId = traceId(1:numEv);

out.filenames = arrayfun(@(x) filenames(x),traceId)';
out.filenames = reshape(out.filenames,[length(out.filenames) 1]);
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
    % ^the time length spent away from the base state (the time of the
    % event excluding the first and last state of the specified search
    tempTime = timeData{traceId(i)}(starts(i):(ends(i)+1));
    out.timeList{i} = tempTime;
    out.timeDiff{i} = diff(tempTime);
    out.begin(i) = tempTime(2)-tempTime(1);
    out.last(i) = tempTime(end)-tempTime(end-1);
    out.eventList{i} = condensedStates{traceId(i)}(starts(i):ends(i),:);
    %convention: timeLengths should not include, in the total event time,
    %the length of the beginning or ending state, since they could be at
    %the beginning or end of the trace (and therefore be of indeterminate
    %length).  Therefore, when doing a default search, the amount of time
    %noted by timeLengths is only the time spent away from the default
    %state.  When doing a custom search, it is best practice to specify an
    %unknown system state at the beginning and end of the search: 
%   [any any; 1 2 ; 2 2; any any] 
    %would provide a timeLengths variable that only contained the length of
    %time spent at the [1 2] state and [2 2] state; this also guarantees that
    %the states searched for do not occur at the beginning or end of a
    %trace.  However, timeList and timeDiff do include the time points for 
    %the edge events, because that information might still be useful to the
    %user.
end


end