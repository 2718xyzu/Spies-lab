function output = defaultStateAnalysis(output, condensedStates, timeData, filenames, baseState)
    
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
        searchExpr{end+1} = output.expr(i); 
        %if this dataset has already been analyzed, pull out any event
        %classifications previously found and make sure to look for them
        %again in the new data
    end
    searchExpr = unique(searchExpr);
    
    rows = length(searchExpr);

    for i = 1:rows
        output = fillRowState(output, i, eval(searchExpr{i}), condensedStates, timeData, filenames);
    end
end