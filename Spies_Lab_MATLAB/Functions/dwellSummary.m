function out = dwellSummary(matrix,timeInterval,channels)
    for k = 1:channels
        out(k).timeBeforeFirst(1) = 0;
        out(k).timeBeforeFirst(1) = [];
        out(k).timeAfterLast(1) = 0;
        out(k).timeAfterLast(1) = [];
        out(k).dwellTimes(1,:) = 1:max(matrix(:));
    end

    for j = 1:size(matrix,2)
        if matrix(:,j) ~= ones(size(matrix(:,j)))
            k = mod(j-1,channels)+1;
            i = 1;
            state = matrix(i,j);

            while state == 1 && i<size(matrix,1)
                i = i+1;
                state = matrix(i,j);
            end

            if i>1 && i~=matrix(i,j)
                out(k).timeBeforeFirst(end+1) = i-1;
            end

            iLast = i-1;
            while i<size(matrix,1)
                state = matrix(i,j);
                stateNext = matrix(i+1,j);
                if state~=stateNext
                    length = i - iLast;
                    out(k).dwellTimes(nnz(out(k).dwellTimes(:,state))+1,state) = length;
                    iLast = i;
                end
                
                i = i+1;
            end

            if matrix(end,j) == 1
                length = i - iLast;
                out(k).timeAfterLast(end+1) = length;
            end
        end
    end
    for k = 1:channels
        out(k).timeBeforeFirst = (out(k).timeBeforeFirst').*timeInterval;
        out(k).timeAfterLast = (out(k).timeAfterLast').*timeInterval;
        out(k).dwellTimes = out(k).dwellTimes.*timeInterval;
    end
end
