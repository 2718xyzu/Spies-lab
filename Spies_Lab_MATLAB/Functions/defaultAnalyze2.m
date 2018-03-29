function output = defaultAnalyze2(results)
    out = regExAnalyzer2('_[^_,]{3,}_',results);
    C = out.eventList;
    nums = cellfun(@(x) mat2str(x),C,'UniformOutput',false);  
    u = unique(nums);

    for i = 2:numel(u)+1
        expr1 = eval(u{i-1});
        expr2 = mat2str(expr1);
        expr2 = regexprep(expr2,'[ ;]','  ');
        expr2 = expr2(2:end-1);
        output(i).expr = {['_  ' expr2 '  _']};
    end

    output(1).expr = {'_[^_,]{3,}_'};
    rows = size(output,2);

    for i = 1:rows
        expr = output(i).expr{:};
        out = regExAnalyzer2(expr,results);
        output(i).count = out.numEvents;
        output(i).meanLength = mean(out.timeLengths);
        output(i).eventList = out.eventList;
        output(i).timeLengths = out.timeLengths;

        if ~isfield(out,'names')
            out.names = out.timeLengths.*0;
        end

        if out.numEvents>0
        output(i).table = table(output(i).eventList,output(i).timeLengths,...
            out.timeList,out.timeDiff,out.begin,out.last,out.names,'VariableNames',...
            {'Events','Total_Duration','Time_Points','Delta_t','Time_first','Time_last','File'});
        end

        expr2 = ['(?<=(' output(i).expr{:}(2:end-1) '))_  _(?=' output(i).expr{:}(2:end-1) ')'];
        out = regExAnalyzer2(expr2,results);
        output(i).count_Gaps = out.numEvents;
        output(i).meanLength_Gaps = mean(out.timeLengths);
        output(i).timeLengths_Gaps = out.timeLengths;

        if ~isfield(out,'names')
            out.names = out.timeLengths.*0;
        end

        if out.numEvents>0
            output(i).table_Gaps = table(output(i).timeLengths_Gaps,...
                out.timeList,out.timeDiff,out.begin,out.last,out.names,'VariableNames',...
                {'Total_Duration','Time_Points','Delta_t','Time_first','Time_last','File'});
        end
    end
end
