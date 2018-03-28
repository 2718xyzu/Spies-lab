function [timeLong,posLong] = timeLengthen(timeData, letters)
% [~,~,timeData] = find(timeData);
% timeData = timeData';
% letters = letters';
i = 1;
timeLong = [];
posLong = [];
for j=1:length(letters)
    timeLong(end+1) = timeData(i);
    posLong(end+1) = i;
    if letters(j) == ' ' && letters(j+1) == ' '
        i = i+1;
    end
end
% timeLong = timeData;
end