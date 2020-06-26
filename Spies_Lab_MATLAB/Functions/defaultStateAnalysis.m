function output = defaultStateAnalysis(channels, stateList, condensedStates, ...
    timeData, filenames, baseState)
    
%     [timeLong, posLong, rowLong] = timeLengthenState(timeData,stateText);
%     baseState = repmat(' 1 ',[1,channels]);
%     defaultString = ['(?<=' baseState(1:end-1) ')[^\]]+?(?=' baseState(2:end) ')'];
%     expr2{1} = defaultString;
%     out = regExAnalyzer3(defaultString, condensedStates, stateText, timeLong, posLong, rowLong, filenames);
    out = findCompletedEvents(baseState, condensedStates, timeData, filenames);
    %the above line searches the transition matrix (nonZeros) for all
    %events matching the 'default' description (typically, all events which
    %are surrounded by state 1 in all channels, which may be interpreted as
    %a lack of any bound species).
    C = out.eventsNoEnds;
%     nums = cellfun(@(x) mat2str(x),C,'UniformOutput',false);
    u = unique(C);
    %find all unique classifications of a 'completed' event
    for i = 2:numel(u)+1 %turn each event found into the text-search form
        expr2{i} = ['(?<=' baseState(1:end-1) ')' u{i-1}  '(?=' baseState(2:end) ')']; %%What is the best way to do this?
        output(i).expr = {[baseState(1:end-1) u{i-1} baseState(2:end)]}; %for display purposes
    end
    output(1).expr = {defaultString};
        rows = size(output,2);

    for i = 1:rows
        output = fillRowState(output, i, expr2{i}, condensedStates, channels, stateList, stateText, timeLong, posLong, rowLong, filenames);
    end
end