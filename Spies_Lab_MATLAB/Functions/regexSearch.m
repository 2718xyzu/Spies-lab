function out = regexSearch(expr, condensedStates, timeData, filenames, selection)


    letters = '';
    for i = find(selection)'
        tempText = [letters mat2str(condensedStates{i})];
        letters = tempText;
    end
    
    letters = regexprep(letters,' ','  ');
    letters = regexprep(letters,';',' ; ');
    letters = regexprep(letters,'[','[ ');
    letters = regexprep(letters,']',' ]');

    %The above turns the condensedStates variable into a long text string
    %of the following form:
    %

    i = 1;
    row = 1;
    selectedTraces = find(selection);
    timeLong = zeros([numel(letters) 1]);
    posLong = zeros([numel(letters) 1]);
    rowLong = zeros([numel(letters) 1]);
    iCurr = 0;
    for j=1:length(letters)
        timeLong(j) = timeData{row}(i-iCurr);
        posLong(j) = i-iCurr;
        rowLong(j) = selectedTraces(row);
        if letters(j) == ';' && letters(j+1) == ' '
            i = i+1;
        elseif letters(j) == ']'
            row = row+1;
            iCurr = i;
            i = i+1;
        end
    end

    [starts,ends] = regexp(letters,expr);
    numEv = length(starts);
    
%     startTimes = arrayfun(@(x) timeLong(x),starts);
%     endTimes = arrayfun(@(x) timeLong(x),ends);
    
    traceId = arrayfun(@(x) rowLong(x),starts);
    out.filenames = arrayfun(@(x) filenames(x),traceId)';    
    out.filenames = reshape(out.filenames,[length(out.filenames) 1]);
    out.timeLengths = zeros([numEv 1]);
    out.begin = zeros([numEv 1]);
    out.last = zeros([numEv 1]);
    out.timeList = cell([numEv 1]);
    out.timeDiff = cell([numEv 1]);
    out.eventList = cell([numEv 1]);
    out.numEvents = numEv;

for i = 1:numEv
    out.timeLengths(i) = timeData{traceId(i)}(posLong(ends(i))+1)-timeData{traceId(i)}(posLong(starts(i))); 
    % ^the time length spent at all of the states matched by the main
    % expression (including the first and last states); this is different
    % from the convention in findStateEvents, see below 
    tempTime = timeData{traceId(i)}(posLong(starts(i)):(posLong(ends(i))+1));
    out.timeList{i} = tempTime;
    out.timeDiff{i} = diff(tempTime);
    out.begin(i) = tempTime(2)-tempTime(1);
    out.last(i) = tempTime(end)-tempTime(end-1);
    out.eventList{i} = condensedStates{traceId(i)}(posLong(starts(i)):posLong(ends(i)),:);
    %convention note: this search works differently from the
    %"findStateEvents" strategy.  If the user is brave enough (and
    %competent enough) to attempt the regex search, it is best to give them
    %back explicitly what they asked for, nothing more, and nothing less.
    %Especially since, with the power of regex, they can specify lookahead
    %sequences which must be present for the match to be counted but which
    %are not included in the final match.  For example:
    
    
    
end
    
end