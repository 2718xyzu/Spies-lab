%Joseph Tibbs
%Last edited 06/27/17

function [data,names] = findPairs(numCol)
%numCol = str2double(strjoin(inputdlg('How many colors are being analyzed?')));
output = questdlg('Next, please select the folder which has all the dwt files you want to analyze',...
    'Instructions','OK','Quit','OK');
path = uigetdir;
if ismac
    slash = '/';
elseif ispc
    slash = '\';
else
    slash = '/';
end
dir2 = dir([path slash '*.dwt']);
dir3(1:numel({dir2.name})) = { dir2.name };
%{
go = 1;
i = 1;
while go
    u = unique(cellfun(@(x) x(1:i), dir3, 'UniformOutput', 0));
    if length(u) == 1
        i = i+1;
    else
        go = 0;
    end
end
start = i;
%}

for i = 1:numel(dir3)
    column = str2double(dir3{i}(1));
    match = regexp(strjoin(dir3(i)),'r\d+.+','match');
    suffix = regexp(strjoin(match(1)),'\d[^\d].+','match');
    suffixes(i) = {suffix{1}(2:end)};
    matches{i,column} = match{1}(2:end-length(suffix{1})+1);
    if ~isnan(str2double(matches{i,column}))
        allmatches{i,column} = str2double(matches{i,column});
    else
        disp(['Error: bad filename "' strjoin(dir2(i)) '"']);
    end
end
u = unique(suffixes);

%if not all files have all pairs in set 
output = questdlg(['There are files without matching pairs.  Would you '...
    'like to assume that corresponding files had no events, and remained '...
    'constant in the lowest state (state 1), constant in a user-defined state '...
    'or to ignore and throw out files without matching pairs?'],'Unpaired File Treatment',...
    'Fill with constant state-1 trajectory','Fill with constant trajectory in other state',...
    'Ignore non-matching files','Fill with constant state-1 trajectory');
if output(end) == 'e'
    constantState = inputdlg(['What state number should the missing trajectories be in?'...
        '  Type a number, where 1 is the lowest state']);
    constateState = str2double(constantState{1})-1;
elseif output(end) == 's'
    ignore = 1;
else
    ignore = 0;
    constantState = 0;   
end
 


if length(u) < 20
    for i = 1:length(u)
        letters(i) = inputdlg([ 'What color should files ending in ***' ...
            strjoin(u(i)) ' be assigned to?  Type a number from 1 to ' num2str(numCol)]);
    end
else
    error('Too many distinct filetypes.  Check naming guidelines and sanitize input');
end

% letters = {'1','2','2','2'};


i0 = 1;
for k = 1:size(allmatches,2)

matches = allmatches(:,k);
pairs = zeros(1,numCol);
pairFriends = zeros(1,numCol);
    
for i = 1:numel(matches)
    if ~isempty(matches{i}) && isnumeric(matches{i})
        column = letters(strcmp(u,suffixes{i}));
        column = str2double(column{1});
        index = [];
        for j = 1:numCol-1
            index = max([find(pairs(:,mod(column+j-1,numCol)+1)==matches{i}) index]);
        end
        if ~isempty(index)
            pairs(index,column) = matches{i};
            pairFriends(index,column) = i;
        else
            pairs(end+1,column) = matches{i};
            pairFriends(end+1,column) = i;
        end
    end
end

% mkdir 'temporaryFolder'

for i = 1:size(pairFriends,1)
    if prod(pairFriends(i,:))~=0
        for j= 1:size(pairFriends,2)
            name = strjoin(dir3(pairFriends(i,j)));
            %disp(name);
            fileID = fopen([path slash name]);
            tempData = textscan(fileID,'%s',1,'Delimiter','\t');
            tempData = textscan(fileID,'%f %f');
            tempData = cat(2,tempData{1}, tempData{2});
            fclose(fileID);
%             tempData = importdata([path slash name],'\t',1);
%             tempData = tempData.data;
            data(1:size(tempData,1),1:size(tempData,2),j,i0) = tempData;
            names(i0,j) = {name};

        end
        i0 = i0+1;
    elseif sum(pairFriends(i,:))>0
        for j= 1:size(pairFriends,2)
            if pairFriends(i,j)>0
                name = strjoin(dir3(pairFriends(i,j)));
                %disp(name);
                fileID = fopen([path slash name]);
                tempData = textscan(fileID,'%s',1,'Delimiter','\t');
                tempData = textscan(fileID,'%f %f');
                tempData = cat(2,tempData{1}, tempData{2});
                fclose(fileID);
                data(1:size(tempData,1),1:size(tempData,2),j,i0) = tempData;
                names(i0,j) = {name};
            else
                data(1,1:2,j,i0) = [constantState .5];
            end
        end
        i0 = i0+1;
    end
end

end
maxTime = max(max(sum(squeeze(data(:,2,:,:)),1)));
data(data==.5) = maxTime;

for i = 1:size(names,1)
    if isempty(names{i,1})
        for j = 2:size(names,2)
            if ~isempty(names{i,j})
                names(i,1) = names(i,2);
                continue;
            end
        end
    end
end

% rmdir 'temporaryFolder' s
end