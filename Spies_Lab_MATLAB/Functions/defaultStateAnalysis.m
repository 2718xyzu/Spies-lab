function output = defaultStateAnalysis(channels, stateList, condensedStates, ...
    timeData, stateText, filenames)
    
    [timeLong, posLong, rowLong] = timeLengthenState(timeData,letters);
    default_state = repmat(' 1 ',[1,channels]);
    defaultString = ['(?<=' default_state(1:end-1) ')[^\]]+?(?=' default_state(2:end) ')'];
    out = regExAnalyzer3(defaultString, nonZeros, letters, timeLong, posLong, rowLong, filenames);
    %the above line searches the transition matrix (nonZeros) for all
    %events matching the 'default' description (typically, all events which
    %are surrounded by state 1 in all channels, which may be interpreted as
    %a lack of any bound species).
    C = out.eventList;
    nums = cellfun(@(x) mat2str(x),C,'UniformOutput',false);
    u = unique(nums);
    %find all unique classifications of a 'completed' event
    for i = 2:numel(u)+1 %turn each event found into the text-search form
        expr2 = ['(?<=' default_state(1:end-1) ')' u{i-1}  '(?=' default_state(2:end) ')'];
        output(i).expr = {default_state(1:end-1) u{i-1} default_state(2:end)}; %for display purposes
    end
    output(1).expr = {defaultString};
        rows = size(output,2);

    for i = 1:rows
        expr = output(i).expr{:}; %the text to search for
        output = fillRowState(output, i, expr, nonZeros, channels, stateList, letters, timeLong, posLong, rowLong, filenames);
    end
end