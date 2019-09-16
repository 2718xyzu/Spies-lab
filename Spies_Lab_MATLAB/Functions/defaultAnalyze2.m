function output = defaultAnalyze2(results)
    [timeLong, posLong, rowLong] = timeLengthen(results.timeData,results.letters);
    out = regExAnalyzer2('_[^_,]{3,}_',results, timeLong, posLong, rowLong);
    %the above line searches the transition matrix (nonZeros) for all
    %'completed' events
    C = out.eventList;
    nums = cellfun(@(x) mat2str(x),C,'UniformOutput',false);
    u = unique(nums);
    %find all unique classifications of a 'completed' event

    for i = 2:numel(u)+1 %turn each event found into the text-search form
        expr2 = regexprep(u{i-1},'[ ;]','  ');
        expr2 = expr2(2:end-1); %remove the brackets from the string
        output(i).expr = {['_  ' expr2 '  _']}; %underscores signal the ground state
    end

    output(1).expr = {'_[^_,]{3,}_'}; %again, the expression which searches for all
    %completed events
    rows = size(output,2);

    for i = 1:rows
        expr = output(i).expr{:}; %the text to search for
        output = fillRow(output, i, expr, results, timeLong, posLong, rowLong);

    end
end
