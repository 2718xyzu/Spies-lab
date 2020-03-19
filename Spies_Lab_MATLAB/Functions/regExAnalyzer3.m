function out = regExAnalyzer3(expr, events, letters, timeLong, posLong, rowLong, filenames)

    [starts,ends] = regexp(letters,expr);

    bitLengths = ends - starts + 1;
    startTimes = arrayfun(@(x) timeLong(x),starts);
    endTimes = arrayfun(@(x) timeLong(x),ends);
    if iscell(filenames)
        names = filenames;
        names2 = arrayfun(@(x) names(x,1),rowLong(starts))'; 
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
        tempTime =  unique(timeLong(starts(i):ends(i)));
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
        out.filenames = names2;
    end

    out.bitLengths = bitLengths;
    out.timeList = timeList;
    out.begin = begin;
    out.timeDiff = timeDiff;
    out.last = last;
end