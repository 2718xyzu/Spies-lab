function plotCell = setThresholdingOnPlotCell(threshold, stateSet, boundDirection, channel, method, states2Set, plotCell)
j = channel;
for i = 1:size(plotCell,1)
    rawTrace = plotCell{i,j,1};
    if method == 2
        rawTrace = rawTrace-prctile(rawTrace,1)/(prctile(rawTrace,99)-prctile(rawTrace,1));
        %comparing each segment to its relative placement within the larger trace,
        %not simply looking at the absolute value
    end
    discTrace = plotCell{i,j,2};
    diffDisc = diff(discTrace);
    foundChanges = [1 reshape(find(diffDisc)+1,[1 length(find(diffDisc))]) length(discTrace)+1];
    for index = 1:length(foundChanges)-1 %split the trace into the discrete segments corresponding with each
                                         %state dwell
        if discTrace(foundChanges(index)) == states2Set || states2Set == 0
        meanSegment = mean(rawTrace(foundChanges(index):foundChanges(index+1)-1));
            switch boundDirection
                case 1
                    if meanSegment>threshold(1)
                        discTrace(foundChanges(index):foundChanges(index+1)-1) = stateSet;
                    end
                case 2
                    if meanSegment<threshold(1)
                        discTrace(foundChanges(index):foundChanges(index+1)-1) = stateSet;
                    end
                case 3
                    if meanSegment>threshold(1) && meanSegment<threshold(1)
                        discTrace(foundChanges(index):foundChanges(index+1)-1) = stateSet;
                    end
            end
        end
        plotCell{i,j,2} = discTrace;
    end
    
end




end