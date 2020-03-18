function [timeLong,posLong,rowLong] = timeLengthenState(timeData, letters)
    i = 1;
    row = 1;
    timeLong = [];
    posLong = [];
    rowLong = [];
    for j=1:length(letters)
        timeLong(end+1) = timeData(i);
        posLong(end+1) = i;
        rowLong(end+1) = row;
        if letters(j) == ' ' && letters(j+1) == ' '
            i = i+1;
        elseif j<length(letters)-3 && strcmp(letters(j:j+2),',  ') &&...
                letters(j+3)~=','
            row = row+1;
        end
    end
end