function [dataCy3,dataCy5] = bulkOpen()
% fprintf(['Please place all traces into folders, one folder for each color. \n  Every trace must have ' ...
%     'a number in it which is unique to that molecule, \n and all traces of different colors from ' ...
%     'that single molecule must share the same number. \n I.e., a folder containing trace16Cy3 and ' ...
%     'trace23Cy3, and a second folder containing tr16Cy5 and 23cytrace is fine. \n The program ' ...
%     'will match the numbers 16 and 23 to their respective files \n']);
numCol = str2double(strjoin(inputdlg('How many colors are being analyzed?')));
directories = cell(1,numCol);
% directories(1) = {input(['Please paste the path of the folder with the first color of traces.  The folder'...
%     ' itself must be in the path. \n  Please end the path with a slash. \n'],'s')};
% 
% 
% 
% color = 1;
% dir2 = dir(strjoin(directories(1)));
% dir3(color,1:numel({dir2.name})) = { dir2.name };
% lengtH = length(dir3);
% dir3 = dir3(:,4:lengtH);
% lengtH = length(dir3);
% names = cell(numCol,lengtH);
% nums = zeros(numCol,lengtH);
% for i=1:lengtH
%     if ~isempty(dir3{color,i})
%     max = [0,0,0];
%     string = strjoin(dir3(color,i));
%     lengthStr = length(string);
%     names(color,i) = cellstr(string);
%     for j = 1:lengthStr
%         for k = j:(lengthStr)
%             y = str2double(string(j:k));
%             if y >= max(1)
%             max(1:3) = [y,j,k];
%             end
%         end
%     end
%     nums(color, i) = max(1);
%     end
% end
% 
% u=unique(nums(color,:));
% n=histc(nums(color,:),u);
% if sum(n) == length(nums);
%     disp('All file ids unique');
% else
%     disp('dupllicate file ids');
% end

dir3 = {0};

for color = 1:numCol
directories(color) = inputdlg(['Please paste the path of the folder with the appropriate color of traces.  The folder'...
    ' itself must be in the path. \n Terminate the path with a slash']);

dir2 = dir([strjoin(directories(color)) '*.dwt']);
dir3(color,1:numel({dir2.name})) = { dir2.name };
lengtH = length(dir3(color,:));
% dir3(color,1:lengtH-3) = dir3(color,4:lengtH);
lengtH = length(dir3(color,:));
startIndex = 3;
endIndex = 0;
for i=1:lengtH
    if ~isempty(dir3{color,i})
    max = [0,0,0];
    string = strjoin(dir3(color,i));
    lengthStr = length(string);
    if endIndex == 0
        endIndex = lengthStr;
    end
    names(color,i) = cellstr(string);
    for j = startIndex:endIndex
        for k = j:(lengthStr)
            y = str2double(string(j:k));
            if y >= max(1)
            max = [y,j,k];
            end
        end
    end
    nums(color, i) = max(1);
    end
end

% u=unique(nums(color,:));
% n=histc(nums(color,:),u);
% if sum(n) == length(nums);
%     disp('All file ids unique');
% else
%     disp('dupllicate file ids');
% end
end

pairs = zeros(length(dir3),numCol);
for i = 1:length(dir3)
    if ~isempty(dir3{1,i})
    %targetNum = nums(1,i);
    for j = 2:size(nums,1)
        for k = 1:length(nums)
            if nums(j,k) == nums(1,i)
                pairs(i,1) = i;
                pairs(i,j) = k;
            end
        end
    end
    end
end

pairs = reshape(nonzeros(pairs),[],numCol);

% flag = 5;
% record = zeros(1);
dataCy3 = zeros(10,2,length(pairs));
dataCy5 = zeros(10,2,length(pairs));
for i = 1:length(pairs);
for j = 1:numCol
    if pairs(i,j) ~= 0
    imported = importdata([strjoin(directories(j)) strjoin(dir3(j,pairs(i,j)))],'\t',1);
    lengtH = size(imported.data,1);
        if j == 1
            dataCy3(1:lengtH,:,i) = imported.data;
        else
            dataCy5(1:lengtH,:,i) = imported.data;
        end
    end
    %disp([strjoin(directories(j)) strjoin(dir3(j,pairs(i,j)))]);
%     timeM = imported.data;
%     j0 = 2^(j-1);
%     binM(j,:) = zeros(1,sum(timeM(:,2))+1,'uint8');
%     count = 1;
%     for i0 = 1:size(timeM,1)
%         binM(j,count:count+timeM(i0,2)) = timeM(i0,1)*j0;
% %         if timeM(i0,2) > 0
% %             record(end+1) = timeM(i0,2);
% %         end
%         count = count + timeM(i0,2);
%     end
%     end
% end
% 
%     transM(1,:) = sum(binM); 
%     transM(2,1:end-2) = flag*(diff(transM(1,2:end)==0)<0);
%     transM(3,2:end) = flag*(diff(transM(1,:)~=0)<0);
%     transM(1,1:end-1) = diff(transM(1,:));
%     transM = sum(transM);
%     [~,timeDataTemp,nonZerosTemp] = find(transM);
%     dataPoints = length(timeDataTemp);
%     [~,timeData(i,1:dataPoints),nonZeros(i,1:dataPoints)] = find(transM);
end
end
end
