function [data,names] = findPairs(kera)
%This function is only for QuB data, where the files are imported
%separately and we have to pair them up
%The QuB files of the Spies lab have a strange naming convention. If your lab wants to use
%QuB and have your own naming convention, you might need to dig into the
%below code to make sure it can find your files and pair them correctly.  
%called by Kera.qubImport (inside Kera.m)
    output = questdlg('Select a folder which has the *.dwt files you want to analyze',...
        'Instructions','OK','Quit','OK');
    if ~strcmp(output, 'OK')
        kera.gui.errorMessage('Import Cancelled');
        return
    end
    path = kera.selectFolder();

    if isempty(path)
        kera.gui.errorMessage('Import Cancelled');
        return
    end

    dir2 = dir([path filesep '*.dwt']);

    if isempty(dir2)
        kera.gui.errorMessage('Choose a folder with dwt files within it')
        [data, names] = findPairs(kera);
        return
    end

    dir3(1:numel({dir2.name})) = { dir2.name };
    %the file naming convention is '## tr####Chan.dwt', where the first number
    %is the experiment number, ' tr' means 'trace', the trace number, and
    %the characters which determine the trace's channel.  The experiment
    %number and trace number may be any length (which is annoying), and the
    %channel suffixes are rarely consistent.  For the Spies lab data, if no
    %Chan is given, assume it is channel 1.  But other file endings will
    %look like 'CY5', 'Cy5', and 'cy5', and they expect our program to be
    %able to recognize that all of these suffixes refer to the same
    %channel.  The upshot is the user needs to be presented with all the
    %existent suffixes and asked which channel they would like to place
    %those traces into.
    %the next issue is that there might be a '1 tr12Cy5' and a '2 tr12Cy5',
    %and we need to keep these separate (hence the variable 'column').
    allsuffixes = cell(1,numel(dir3));
    fileNum = cell(1,1);
    nummatches = cell(1,1);
    for i = 1:numel(dir3)
        try
        column = str2double(dir3{i}(1));
        catch
        column = 1; %some file names won't start with a number, probably
        end
        match = regexp(strjoin(dir3(i)),'r\d+.+','match');
        suffix = regexp(strjoin(match(1)),'\d[^\d].+','match');
%         suffixes{column}(i) = {lower(suffix{1}(2:end))};
        allsuffixes(i) = {lower(suffix{1}(2:end))};
        fileNum{column}{i} = match{1}(2:end-length(suffix{1})+1);
        if ~isnan(str2double(fileNum{column}{i}))
            nummatches{column}(i) = str2double(fileNum{column}{i});
        else
            disp(['Error: bad filename "' strjoin(dir2(i)) '"']);
        end
    end
    u = unique(lower(allsuffixes));
    
    channelAssign = cell(1,length(u));
    if length(u) < 20
        for i = 1:length(u)
            channelAssign(i) = inputdlg([ 'What color should files ending in ***' ...
                u{i} ' be assigned to?  Type a number from 1 to ' num2str(kera.channels)]);
        end
    else
        kera.gui.errorMessage('Too many distinct filetypes.  Check naming guidelines and sanitize input');
        return
    end
    
    
    
    %In a given dataset, there are supposed to be matching traces for each
    %channel (e.g. '1 tr1' goes with '1 tr1Cy5', where the first file would
    %go in channel 1 and the second would go in channel 2, but these are
    %'pairs' because they are colocalized on the microscope slide.
    %In other words, any traces which have the same experiment number and
    %same trace number must somehow be linked.  That's what the mess of
    %code in the next for loop is doing.
    unpairedChannels = [];
    pairs = cell(1,length(nummatches));
    pairFriends = cell(1,length(nummatches));
    for k = 1:length(nummatches)

        fileNum = nummatches{k};
        pairs{k} = zeros(1,kera.channels);
        pairFriends{k} = zeros(1,kera.channels);

        for i = 1:numel(fileNum)
            if ~isempty(fileNum(i)) && isnumeric(fileNum(i))
                column = channelAssign(strcmp(u,allsuffixes{i}));
                %column now refers to channel
                column = str2double(column{1});
                index = [];
                for j = 1:kera.channels-1
                    index = max([find(pairs{k}(:,mod(column+j-1,kera.channels)+1)==fileNum(i)) index]);
                end
                if ~isempty(index)
                    pairs{k}(index,column) = fileNum(i);
                    pairFriends{k}(index,column) = i;
                else
                    pairs{k}(end+1,column) = fileNum(i);
                    pairFriends{k}(end+1,column) = i;
                end
            end
        end
        unpairedRows = logical(any(pairs{k},2).*~all(pairs{k},2));
        unpaired = any(unpairedRows);
        if unpaired
            unpairedChannels = unique([~all(pairs{k}(unpairedRows,:),1) unpairedChannels]);
        end
    end
unpairedChannels = reshape(unpairedChannels,1,[]);
%     if not all files have all pairs in set -- note, this needs to be fixed
if ~isempty(unpairedChannels)
    missingPair = questdlg(['There are files without matching pairs.  Would you '...
        'like to assume that corresponding files had no events, and remained '...
        'constant in the lowest state (state 1), constant in a user-defined state '...
        'or to ignore and throw out files without matching pairs?'],'Unpaired File Treatment',...
        'Fill with constant state-1 trajectory','Fill with constant trajectory in other state',...
        'Ignore non-matching files','Fill with constant state-1 trajectory');

    if contains(missingPair, 'constant trajectory')
        constantState = zeros(1,kera.channels);
        for j = unpairedChannels
            constantState = inputdlg(['What state number should the missing trajectories for channel ' ...
            num2str(j) ' be in?  Type a number, where 1 is the lowest state']);
            constantState(j) = str2double(constantState{1})-1;
            %in raw form, QuB data has the lowest state at 0, hence the -1
        end
        ignore = 0;
    elseif contains(missingPair, 'Ignore')
        ignore = 1;
    else
        ignore = 0;
        constantState = zeros(1,kera.channels);
    end
end

    
    i0 = 1; 
    for k = 1:size(nummatches,2)
        data = cell(size(pairFriends{k}));
        names = cell(size(pairFriends{k}));
        %import them, and record the names of each file
        for i = 1:size(pairFriends{k},1)
            if all(pairFriends{k}(i,:))
                for j= 1:size(pairFriends{k},2)
                    if pairFriends{k}(i,j)>0
                        name = strjoin(dir3(pairFriends{k}(i,j)));
                        fileID = fopen([path filesep name]);
                        tempData = textscan(fileID,'%f %f');
                        if isempty(tempData{1})
                            fileID = fopen([path filesep name]);
                            [~] = textscan(fileID,'%s',1,'Delimiter','\t');
                            %read the header
                            tempData = textscan(fileID,'%f %f');
                        end
                        tempData = cat(2,tempData{1}, tempData{2});
                        fclose(fileID);
                        data{i0,j} = tempData;
                        names{i0,j} = name;
                    end
                end
                i0 = i0+1;
            elseif ~ignore && any(pairFriends{k}(i,:))
                maxTime = 0;
                maxTimeNeeded = zeros(1,size(pairFriends{k},2));
                for j= 1:size(pairFriends{k},2)
                    if pairFriends{k}(i,j)>0
                        name = strjoin(dir3(pairFriends{k}(i,j)));
                        fileID = fopen([path filesep name]);
                        tempData = textscan(fileID,'%f %f');
                        if isempty(tempData{1})
                            fileID = fopen([path filesep name]);
                            [~] = textscan(fileID,'%s',1,'Delimiter','\t');
                            %read the header
                            tempData = textscan(fileID,'%f %f');
                        end
                        tempData = cat(2,tempData{1}, tempData{2});
                        fclose(fileID);
                        data{i0,j} = tempData;
                        names{i0,j} = name;
                        maxTime = max(maxTime,sum(tempData(:,2)));
                    else
                        data{i0,j} = [constantState(j) .5];
                        maxTimeNeeded(j) = 1;
                    end
                end
                for j = find(maxTimeNeeded)
                    data{i0,j}(1,2) = maxTime;
                end
                i0 = i0+1;
            end
        end
    end
    data = data(1:i0-1,:);
    names = names(1:i0-1,:);
    
    
    for i = 1:size(names,1)
        if isempty(names{i,1})
            for j = 2:size(names,2)
                if ~isempty(names{i,j})
                    names(i,1) = names(i,j);
                end
            end
        end
    end
    
    
end
