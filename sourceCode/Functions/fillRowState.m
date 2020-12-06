function output = fillRowState(output, i, searchMatrix, condensedStates, timeData, filenames, selection)
    %This is the most important (and most general) search function,
    %which actually calculates all the data which goes into "output"
    %and then puts it there, one row at a time
    %called by defaultStateAnalysis, Kera.customSearch, and Kera.regexSearchUI
    %(the latter two are in Kera.m), which are called when the user selects
    %"Run/Refresh Analysis", "Custom Search", and "Regex Search",
    %respectively.

        
    %searchMatrix is a numerical array; see findStateEvents for
    %conventions
        
        
        output(i).searchMatrix = searchMatrix;
        if searchMatrix(1)~=-1 %interpret searchMatrix like a normal search matrix
            output(i).expr = mat2str(searchMatrix);
            out = findStateEvents(searchMatrix, condensedStates, timeData, filenames, selection); %function which does the searching
        else %interpret the string of numbers as characters and do a special "regular expressions"
             %search of the converted-to-text list of states.  See
             %documentation (or the inside of regexSearch) for details
            output(i).expr = char(searchMatrix(2:end));
            out = regexSearch(output(i).expr, condensedStates, timeData, filenames, selection);
        end
              
        
        if ~isempty(out.timeDiff) && all(cellfun(@length,out.timeDiff)==1) 
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
        tau = out.timeLengths;
        output(i).randomnessParameter = (mean(tau.^2)-mean(tau)^2)./mean(tau)^2;
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
