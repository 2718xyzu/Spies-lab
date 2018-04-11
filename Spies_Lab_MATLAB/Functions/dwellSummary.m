function out = dwellSummary(matrix,timeInterval,channels)
    for k = 1:channels %initialize the fields; each row corresponds to a channel
        out(k).timeBeforeFirst(1) = 0; %the time at ground before the first event
        out(k).timeBeforeFirst(1) = [];
        out(k).timeAfterLast(1) = 0;%the time spent at ground after last event
        out(k).timeAfterLast(1) = [];
        out(k).dwellTimes(1,:) = zeros([1,max(matrix(:))]); 
        %an exhaustive list of all times spent at a given state, where each
        %column corresponds to a different state (column 1 to state 1 etc.)
    end

    for j = 1:size(matrix,2)
        tempList = matrix(1:nnz(matrix(:,j)),j); %extract column, truncate trailing zeros
        if sum(tempList) ~= length(tempList) %if the trajectory is not all ones
            k = mod(j-1,channels)+1; %assign this data to the proper channel
            i = 1;
            state = tempList(i);

            while state == 1 && i<length(tempList)
                i = i+1;
                state = tempList(i);
            end

            if i>1 && i~=tempList(i)
                out(k).timeBeforeFirst(end+1) = i-1; %time spent at ground before first event
            end

            iLast = i-1;
            while i<length(tempList)
                state = tempList(i);
                stateNext = tempList(i+1);
                if state~=stateNext
                    longth = i - iLast; %time spent at this state; append to list in appropriate col
                    out(k).dwellTimes(nnz(out(k).dwellTimes(:,state))+1,state) = longth;
                    iLast = i;
                end
                
                i = i+1;
            end

            if tempList(end) == 1
                longth = i - iLast;
                out(k).timeAfterLast(end+1) = longth; %time after last event spent at ground (if any)
            end
        end
    end
    for k = 1:channels %scale by factor of time interval (converts to seconds)
        out(k).timeBeforeFirst = (out(k).timeBeforeFirst').*timeInterval;
        out(k).timeAfterLast = (out(k).timeAfterLast').*timeInterval;
        out(k).dwellTimes = out(k).dwellTimes.*timeInterval;
    end
end
