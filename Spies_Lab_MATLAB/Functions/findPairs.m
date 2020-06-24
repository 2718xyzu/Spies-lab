function [data,names] = findPairs(kera)
%This function is only for QuB data, where the files are imported
%separately and we have to pair them up
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
    for i = 1:numel(dir3)
        column = str2double(dir3{i}(1));
        match = regexp(strjoin(dir3(i)),'r\d+.+','match');
        suffix = regexp(strjoin(match(1)),'\d[^\d].+','match');
        suffixes(i) = {lower(suffix{1}(2:end))};
        matches{i,column} = match{1}(2:end-length(suffix{1})+1);
        if ~isnan(str2double(matches{i,column}))
            allmatches{i,column} = str2double(matches{i,column});
        else
            disp(['Error: bad filename "' strjoin(dir2(i)) '"']);
        end
    end
    u = unique(lower(suffixes));

    %if not all files have all pairs in set -- note, this needs to be fixed
    if mod(numel(dir3),kera.channels)
    missingPair = questdlg(['There are files without matching pairs.  Would you '...
        'like to assume that corresponding files had no events, and remained '...
        'constant in the lowest state (state 1), constant in a user-defined state '...
        'or to ignore and throw out files without matching pairs?'],'Unpaired File Treatment',...
        'Fill with constant state-1 trajectory','Fill with constant trajectory in other state',...
        'Ignore non-matching files','Fill with constant state-1 trajectory');

    if contains(missingPair, 'constant trajectory')
        constantState = inputdlg(['What state number should the missing trajectories be in?'...
            '  Type a number, where 1 is the lowest state']);
        constateState = str2double(constantState{1})-1;

    elseif contains(missingPair, 'Ignore')
        ignore = 1;

    else
        ignore = 0;
        constantState = 0;
    end
    end

    if length(u) < 20
        for i = 1:length(u)
            letters(i) = inputdlg([ 'What color should files ending in ***' ...
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
    i0 = 1;
    for k = 1:size(allmatches,2)

        matches = allmatches(:,k);
        pairs = zeros(1,kera.channels);
        pairFriends = zeros(1,kera.channels);

        for i = 1:numel(matches)
            if ~isempty(matches{i}) && isnumeric(matches{i})
                column = letters(strcmp(u,suffixes{i}));
                column = str2double(column{1});
                index = [];
                for j = 1:kera.channels-1
                    index = max([find(pairs(:,mod(column+j-1,kera.channels)+1)==matches{i}) index]);
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
        %import them, and record the names of each file
        for i = 1:size(pairFriends,1)
            if prod(pairFriends(i,:))~=0
                for j= 1:size(pairFriends,2)
                    name = strjoin(dir3(pairFriends(i,j)));
                    fileID = fopen([path '/' name]);
                    tempData = textscan(fileID,'%f %f');
                    if isempty(tempData{1})
                        fileID = fopen([path '/' name]);
                        [~] = textscan(fileID,'%s',1,'Delimiter','\t');
                        tempData = textscan(fileID,'%f %f');
                    end
                    tempData = cat(2,tempData{1}, tempData{2});
                    fclose(fileID);
                    data(1:size(tempData,1),1:size(tempData,2),j,i0) = tempData;
                    names(i0,j) = {name};
                end
                i0 = i0+1;
            elseif sum(pairFriends(i,:))>0
                for j= 1:size(pairFriends,2)
                    if pairFriends(i,j)>0
                        name = strjoin(dir3(pairFriends(i,j)));
                        fileID = fopen([path filesep name]);
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
                end
            end
        end
    end
end
