function output = fillRowState(output, i, expr, condensedStates, filenames)
        
        output(i).expr = expr;
        searchMatrix = eval(expr);
        output(i).searchMatrix = eval(expr);      
        out = findStateEvents(searchMatrix, condensedStates, timeData, filenames); %function which does the searching
%         [~,output(i).interpretation] = parseTransitionState(expr, channels, stateList);
        try
%             [output(i).statesSummary,~] = parseTransition(expr, channels, stateList);
            output(i).searchState = eval(expr);
        catch
        end
        output(i).count = out.numEvents;
        output(i).meanLength = mean(out.timeLengths);
        output(i).eventList = out.eventList;
        output(i).timeLengths = out.timeLengths; %how long was each event

        if ~isfield(out,'filenames') %if name data exists
            out.filenames = out.timeLengths.*0;
        end

        if out.numEvents>0 %create a detailed table and store it in its own field
            
        output(i).table = table(output(i).eventList,output(i).timeLengths,...
            out.timeList,out.timeDiff,out.begin,out.last,out.filenames,'VariableNames',...
            {'Events','Total_Duration','Time_Points','Delta_t','Time_first','Time_last','File'});
            try 
                output(i).excel = cell2mat(out.timeDiff);
            catch
            end
        end

end
