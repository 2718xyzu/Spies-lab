function output = defaultStateAnalysis(output, condensedStates, timeData, filenames, baseState, stateList, selection)
    
%     [timeLong, posLong, rowLong] = timeLengthenState(timeData,stateText);
%     baseState = repmat(' 1 ',[1,channels]);
%     defaultString = ['(?<=' baseState(1:end-1) ')[^\]]+?(?=' baseState(2:end) ')'];
%     expr2{1} = defaultString;
%     out = regExAnalyzer3(defaultString, condensedStates, stateText, timeLong, posLong, rowLong, filenames);
    channels = length(stateList);
    searchExpr = {};
    baseStateAnalysis = 0;
     %Find out if the user would like to do the (sometimes rather verbose) baseline-event analysis
    anS = questdlg(['Would you like to find all events which occur as departures from the'...
        ' base state of ' mat2str(baseState) '?']);

    if anS(1)=='Y'
        baseStateAnalysis = 1;
    end
        
    if baseStateAnalysis
        out = findCompletedEvents(baseState, condensedStates, selection);
        %the above line searches the transition matrix (nonZeros) for all
        %events matching the 'default' description (typically, all events which
        %are surrounded by state 1 in all channels, which may be interpreted as
        %a lack of any bound species).
        %In other words, the analyzed data will include all unique event
        %classes which start with the baseline configuration (Which can be user
        %defined but is, by default, just state-1 in all channels) and then
        %have some transitions happen before returning to the baseline.
        C = out.eventList;
        nums = cellfun(@(x) mat2str(x),C,'UniformOutput',false);
        %find all unique classifications of a 'completed' event
        searchExpr = unique(nums);
        defaultExpr = baseState;
        defaultExpr(3,:) = baseState;
        defaultExpr(2,:) = Inf;
        searchExpr{end+1} = mat2str(defaultExpr);
    
    end
    
    
    
    for i = 1:size(output,2)
        if ~isempty(output(i).expr)
            searchExpr{end+1} = output(i).expr; 
        end
        %if this dataset has already been analyzed, pull out any event
        %classifications previously found and make sure to look for them
        %again in the new data
    end
    verboseStateOut = 0;
    anS = questdlg(['Would you like to get an output for every unique system configuration and transition'...
        '? There are ' num2str(prod(stateList))*(sum(stateList-1)+1) 'possible configurations and transitions' ]);
    if anS(1)=='Y'
        verboseStateOut = 1;
    end
    if verboseStateOut %but in general, we want to do a search for every individual state, as well as every single-channel change
        subs = cell([1 channels]);
        nans = NaN([1 channels]);
        for i = 1:prod(stateList)
            [subs{:}] = ind2sub(stateList,i);
            mat2Search = cat(1,nans,cell2mat(subs),nans);
            searchExpr{end+1} = mat2str(mat2Search);
            for j = 1:channels
                for i0 = 1:stateList(j)
                    transitionTo = cell2mat(subs);
                    transitionTo(j) = i0;
                    mat2Search = cat(1,nans,cell2mat(subs),transitionTo);
                    searchExpr{end+1} = mat2str(mat2Search);        
                end
            end
        end
    end
    
    searchExpr = unique(searchExpr);
    
    rows = length(searchExpr);
    output = struct();
    f = waitbar(0,'Finding event classifications');
    for i = 1:rows
        waitbar(i/rows,f,'Finding event classifications');
        output = fillRowState(output, i, eval(searchExpr{i}), condensedStates, timeData, filenames, selection);
    end
    close(f);
end