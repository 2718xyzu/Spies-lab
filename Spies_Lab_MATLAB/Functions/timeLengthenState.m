function [timeLong,posLong,rowLong] = timeLengthenState(timeData, letters)
    i = 1;
    row = 1;
    timeLong = [];
    posLong = [];
    rowLong = [];
    iCurr = 0;
    for j=1:length(letters)
        timeLong(end+1) = timeData{row}(i-iCurr);
        posLong(end+1) = i;
        rowLong(end+1) = row;
        if letters(j) == ' ' && letters(j+1) == ' '
            i = i+1;
        elseif letters(j) == ']'
            row = row+1;
            iCurr = i;
            i = i+1;
        end
    end
end
