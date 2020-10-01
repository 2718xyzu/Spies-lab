function out = dwellSummary(dataCell,timeInterval,channels,baseState)
%Generates the dwellSummary from the dwell and time information; this code
%may be easily changed to add more information to the eventual output.
%dwellSummary is a structure, so just add a field to it.  See documentation
%for more details, but in brief, the structure is organized first by
%channel, then by states within the channel.  The dwells *with* edges
%include the states which are on the edge of the trace (beginning or end);
%in the dwellTimes field it discards those times because we don't know how
%long they lasted.  For determining the propoprtion of time your system
%spent at a given state, though, definitely use the dwellTimesWithEdges so
%you aren't biased by any state being more likely to happen at the
%beginning or end.  Multiplying the meanDwellsWithEdges values by the
%length of the respective dwellTimesWithEdges is a fast way to figure out
%how long your system was at those states.
%called by Kera.preProcessing in the Kera.m file




    out = struct();
    %baseState is passed in as a vector with "channels" elements

    for j = 1:channels %initialize the fields; each row corresponds to a channel
        out(j).dwellTimes = cell([1,max(dataCell{1,j,2})]);
        %an exhaustive list of all times spent at a given state, where each
        %column corresponds to a different state (column 1 to state 1 etc.)
        out(j).meanDwells = zeros([1,max(dataCell{1,j,2})]); 
        %the mean of the columns in the previous (excluding zero padding)
        out(j).dwellTimesWithEdges = cell([1,max(dataCell{1,j,2})]);
        %dwellTimes but allowing those states which were cut off by the
        %edge of the trajectory
        out(j).meanDwellsWithEdges = zeros([1,max(dataCell{1,j,2})]);
        %the mean of the previous
        out(j).timeBeforeFirst = []; %the time at ground before the first event
        out(j).timeAfterLast = []; %the time spent at ground after last event
    end
    
    for j = 1:channels
        for i = 1:size(dataCell,1)
            tempList = dataCell{i,j,2}; %extract single trace
            tempList = reshape(tempList,[1 length(tempList)]);
            diffList = [1 diff(tempList) 1];
            foundDiff = find(diffList); %the position of all state changes (and the borders of the trace)
            
            %run analysis on trace's first state
            state = tempList(1);
            if state == baseState(j) && length(foundDiff)>2 %this isn't valid if it's all one state for the whole trace
                out(j).timeBeforeFirst(end+1) = (foundDiff(2)-foundDiff(1))*timeInterval;
            end
            if length(foundDiff)>2 %handling traces that are all a single state; this time gets recorded later, so it's not double-counted
                out(j).dwellTimesWithEdges{state}(end+1) = (foundDiff(2)-foundDiff(1))*timeInterval;
            end
            
            for i0 = 2:(length(foundDiff)-2)
                state = tempList(foundDiff(i0));
                out(j).dwellTimesWithEdges{state}(end+1) = (foundDiff(i0+1)-foundDiff(i0))*timeInterval;
                out(j).dwellTimes{state}(end+1) = (foundDiff(i0+1)-foundDiff(i0))*timeInterval;
            end
            
            %run analysis on trace's last state
            state = tempList(end);
            if state == baseState(j) && length(foundDiff)>2
                out(j).timeAfterLast(end+1) = (foundDiff(end)-foundDiff(end-1))*timeInterval;
            end
            out(j).dwellTimesWithEdges{state}(end+1) = (foundDiff(end)-foundDiff(end-1))*timeInterval;
        end
        
        for i=1:length(out(j).dwellTimes)
            out(j).meanDwells(i) = mean(out(j).dwellTimes{i});
        end
        for i=1:length(out(j).dwellTimesWithEdges)
            out(j).meanDwellsWithEdges(i) = mean(out(j).dwellTimesWithEdges{i});
        end
        
        
    end
    
end