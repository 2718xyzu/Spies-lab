function out = dwellSummary(dataCell,timeInterval,channels,baseState)
    out = struct();
    %baseState is passed in as a vector with "channels" elements

    for j = 1:channels %initialize the fields; each row corresponds to a channel
        out(j).timeBeforeFirst(1) = 0; %the time at ground before the first event
        out(j).timeBeforeFirst(1) = [];
        out(j).timeAfterLast(1) = 0;%the time spent at ground after last event
        out(j).timeAfterLast(1) = [];
        out(j).dwellTimes(1,:) = zeros([1,max(dataCell{1,j,2})]); 
        %an exhaustive list of all times spent at a given state, where each
        %column corresponds to a different state (column 1 to state 1 etc.)
        out(j).meanDwells = zeros([1,max(dataCell{1,j,2})]); 
        %the mean of the columns in the previous (excluding zero padding)
    end

    for i = 1:size(dataCell,1)
        for j = 1:channels
        tempList = dataCell{i,j,2}; %extract single trace
        if any(tempList ~= baseState(j)) %if the trajectory is not all base
            i0 = find(tempList~=baseState(j),1);
            if i0>1 && i0~=tempList(i0)
                out(j).timeBeforeFirst(end+1) = i0-1; %time spent at ground before first event
            end

            iLast = i0-1;
            while i0<length(tempList) %this block of code is one reason no state can be named "0" or any negative number
                state = tempList(i0);
                stateNext = tempList(i0+1);
                if state~=stateNext
                    longth = i0 - iLast; %time spent at this state; append to list in appropriate col
                    out(j).dwellTimes(nnz(out(j).dwellTimes(:,state))+1,state) = longth;
                    iLast = i0;
                end
                
                i0 = i0+1;
            end

            if tempList(end) == baseState(j)
                longth = i0 - iLast;
                out(j).timeAfterLast(end+1) = longth; %time after last event spent at ground (if any)
            end
        end
            for state = 1:size(out(j).dwellTimes,2)
                nnzState = nnz(out(j).dwellTimes(:,state));
                out(j).meanDwells(state) = mean(out(j).dwellTimes(1:nnzState,state));
            end
        end
    end
    for j = 1:channels %scale by factor of time interval (converts to seconds, generally)
        out(j).timeBeforeFirst = (out(j).timeBeforeFirst').*timeInterval;
        out(j).timeAfterLast = (out(j).timeAfterLast').*timeInterval;
        out(j).dwellTimes = out(j).dwellTimes.*timeInterval;
        out(j).meanDwells = out(j).meanDwells.*timeInterval;
    end
end
