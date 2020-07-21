function output = fillRowState(output, i, searchMatrix, condensedStates, timeData, filenames, selection)
        %searchMatrix is a numerical array; see findStateEvents for
        %conventions
        output(i).searchMatrix = searchMatrix;
        output(i).expr = mat2str(searchMatrix);
              
        out = findStateEvents(searchMatrix, condensedStates, timeData, filenames, selection); %function which does the searching

        if length(out.timeDiff(1))==1 
            %if the search term has only one configuration, we have to break a few rules
            %a search for state-1 dwells should really be phrased as [NaN 1 NaN],
            %where the "NaN" any-state wildcards ensure that the dwells
            %being measured are not at the beginning or end of the trace.
            %However, if the user insists on listing their single-state
            %searches in this way, we might as well make it easy for them
            %to get the kinetic data they apparently want
            out.timeLengths = cell2mat(out.timeDiff);
        end
        
        output(i).count = out.numEvents;
        output(i).meanLength = mean(out.timeLengths);
        output(i).eventList = out.eventList;
        output(i).timeLengths = out.timeLengths; %how long was each event
        eventExprList = cellfun(@mat2str, out.eventList,'UniformOutput',false);

        if ~isfield(out,'filenames') %if name data does not exist, fill it in with blank
                                     %this shouldn't happen often, because
                                     %even if actual filenames don't exist
                                     %for the traces, some kind of
                                     %identifying number or something is
                                     %still given to them upon import.
                                     %Usually.
            out.filenames = out.timeLengths.*0;
        end

        if out.numEvents>0 %create a detailed table and store it in its own field
            
            output(i).table = table(output(i).eventList,eventExprList,output(i).timeLengths,...
                out.timeList,out.timeDiff,out.begin,out.last,out.filenames,'VariableNames',...
                {'Events','Expr','Total_Duration','Time_Points','Delta_t','Time_first','Time_last','File'});
            try 
                output(i).excel = cell2mat(out.timeDiff')';
            catch
            end
        end
end
