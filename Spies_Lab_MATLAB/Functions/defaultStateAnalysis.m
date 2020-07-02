function output = defaultStateAnalysis(output, condensedStates, timeData, filenames, baseState, stateList)
    
%     [timeLong, posLong, rowLong] = timeLengthenState(timeData,stateText);
%     baseState = repmat(' 1 ',[1,channels]);
%     defaultString = ['(?<=' baseState(1:end-1) ')[^\]]+?(?=' baseState(2:end) ')'];
%     expr2{1} = defaultString;
%     out = regExAnalyzer3(defaultString, condensedStates, stateText, timeLong, posLong, rowLong, filenames);
    out = findCompletedEvents(baseState, condensedStates);
    %the above line searches the transition matrix (nonZeros) for all
    %events matching the 'default' description (typically, all events which
    %are surrounded by state 1 in all channels, which may be interpreted as
    %a lack of any bound species).
    C = out.eventList;
    nums = cellfun(@(x) mat2str(x),C,'UniformOutput',false);
    %find all unique classifications of a 'completed' event
    searchExpr = unique(nums);
    defaultExpr = baseState;
    defaultExpr(3,:) = baseState;
    defaultExpr(2,:) = Inf;
    searchExpr{end+1} = mat2str(defaultExpr);
    
    
    for i = 1:size(output,2)
        if ~isempty(output(i).expr)
            searchExpr{end+1} = output(i).expr; 
        end
        %if this dataset has already been analyzed, pull out any event
        %classifications previously found and make sure to look for them
        %again in the new data
    end
    verboseStateOut = 0;
    if prod(stateList)<=256 %there should be a backdoor in case the number of possible configurations is very high
        verboseStateOut = 1;
    else
        anS = questdlg(['Would you like to get an output for every unique system configuration'...
            '? There are ' num2str(prod(stateList)) 'possible configurations']);
        if anS(1)=='Y'
            verboseStateOut = 1;
        end
    end
    if verboseStateOut %but in general, we want to do a search for every individual state
        subs = cell([1 length(stateList)]);
        nans = NaN([1 length(stateList)]);
        for i = 1:prod(stateList)
            [subs{:}] = ind2sub(stateList,i);
            mat2Search = cat(1,nans,cell2mat(subs),nans);
            searchExpr{end+1} = mat2str(mat2Search);
        end
    end
    
    searchExpr = unique(searchExpr);
    
    rows = length(searchExpr);
    output = struct();
    f = waitbar(0,'Finding event classifications');
    for i = 1:rows
        waitbar(i/rows,f,'Finding event classifications');
        output = fillRowState(output, i, eval(searchExpr{i}), condensedStates, timeData, filenames);
    end
    close(f);
end