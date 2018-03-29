function out = regExAnalyzer2(expr, input)
    [timeLong, posLong] = timeLengthen(input.timeData,input.letters);
    timeData = (input.timeData);
    letters = input.letters;
    events = (input.nonZeros);
    [starts,ends] = regexp(letters,expr);
    if expr(1) == '_'
        starts = starts+2;
    end
    if expr(end) == '_'
        ends = ends-2;
    end
    if strcmp(expr(1:5),'(?<=(')
        starts = starts-2;
        ends = ends+2;
    end
    bitLengths = ends - starts + 1;
    width = size(events,1); 
    startTimes = arrayfun(@(x) timeLong(x),starts);
    endTimes = arrayfun(@(x) timeLong(x),ends);
    if isfield(input,'names')
        names = input.names;
        names2 = arrayfun(@(x) names(ceil(x/width),1),posLong(starts))'; %Fix naming
    end

    num = length(starts);
    totalTimeLengths = endTimes-startTimes;
    if isempty(starts)
        eventList = {};
    end

    timeList = {0};
    begin = 0;
    last = 0;
    timeDiff = {0};
    for i = 1:length(starts)
        eventList(i,1) = { events(posLong(starts(i)):posLong(ends(i))) } ;
        tempTime =  timeData(posLong(starts(i)):posLong(ends(i))) ;
        tempDiff =  diff(tempTime);
        timeList(i,1) = { tempTime };
        if ~isempty(tempDiff)
        begin(i,1) = tempDiff(1);
        last(i,1) = tempDiff(end);
        timeDiff(i,1) = {tempDiff};
        end
    end

    out.numEvents = num;
    out.timeLengths = totalTimeLengths';
    out.eventList = eventList;
    if exist('names2','var')
        out.names = names2;
    end

    out.bitLengths = bitLengths;
    out.timeList = timeList;
    out.begin = begin;
    out.timeDiff = timeDiff;
    out.last = last;
end
