function out = dwellSummary(matrix,timeInterval,channels)
    for k = 1:channels
        out(k).timeBeforeFirst(1) = 0;
        out(k).timeBeforeFirst(1) = [];
        out(k).timeAfterLast(1) = 0;
        out(k).timeAfterLast(1) = [];
        out(k).dwellTimes(1,:) = 1:max(matrix(:));
    end

    for j = 1:size(matrix,2)
        tempList = matrix(1:nnz(matrix(:,j)),j);
        if sum(tempList) ~= length(tempList)
            k = mod(j-1,channels)+1;
            i = 1;
            state = tempList(i);

            while state == 1 && i<length(tempList)
                i = i+1;
                state = tempList(i);
            end

            if i>1 && i~=tempList(i)
                out(k).timeBeforeFirst(end+1) = i-1;
            end

            iLast = i-1;
            while i<length(tempList)
                state = tempList(i);
                stateNext = tempList(i+1);
                if state~=stateNext
                    longth = i - iLast;
                    out(k).dwellTimes(nnz(out(k).dwellTimes(:,state))+1,state) = longth;
                    iLast = i;
                end
                
                i = i+1;
            end

            if tempList(end) == 1
                longth = i - iLast;
                out(k).timeAfterLast(end+1) = longth;
            end
        end
    end
    for k = 1:channels
        out(k).timeBeforeFirst = (out(k).timeBeforeFirst').*timeInterval;
        out(k).timeAfterLast = (out(k).timeAfterLast').*timeInterval;
        out(k).dwellTimes(2:end,:) = out(k).dwellTimes(2:end,:).*timeInterval;
    end
end
