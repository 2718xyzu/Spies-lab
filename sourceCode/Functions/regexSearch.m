function out = regexSearch(expr, condensedStates, timeData, filenames, selection)
%turn the condensed states into a searchable text array and locate all
%instances of expr in it.  Record relevant event details such as file
%location and start time by encoding each position in the long string to
%correspond to a timestamp and file.  Called by fillRowState when the first
%number in the searchMatrix is -1 (a flag directing the code to treat the
%query as a regex search).

    letters = '';
    for i = find(selection)'
        tempText = [letters '[' mat2str(condensedStates{i}) ']'];
        %mat2str already creates strings with brackets, but very rarely in
        %a one-channel study a trace will consist of only one state
        %throughout, and when this happens mat2str returns a single number,
        %like '3', with no brakets.  The double-bracketing is removed in
        %the regexprep below.
        letters = tempText;
    end
    letters = regexprep(letters,'[[','[');
    letters = regexprep(letters,']]',']');
    letters = regexprep(letters,' ','  ');
    letters = regexprep(letters,';',' ; ');
    letters = regexprep(letters,'[','[ ');
    letters = regexprep(letters,']',' ;]');

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
    
    %(?<=(2|3)  \d ; )((1  2 )|(1  1 ; 1  2 ))(; 1  \d )*(?=; (2|3))
    
    %the lookahead and lookbehind are important; we are looking for a
    %region where channel 1 is constantly at state 1, so we don't want to
    %include the preceding (and following) state2 or state3 portions, but
    %we need to make sure they're there so that we know we got the full
    %state1 event.  Lookaheads and lookbehinds are also useful because
    %regex does not allow two string matches to overlap except in the
    %region of a lookahead or lookbehind.  This is probably fine, since
    %the researcher probably isn't looking to double-count any events with
    %an overlapping search.
    
end
    
end