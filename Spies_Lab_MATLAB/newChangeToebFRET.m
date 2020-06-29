
%A wrapper function to guide through data input from raw intensity values;
%contains call to "emulateFRET", which allows for trace pre-processing,
%before calling smoothNormalize which smooths and normalizes all traces,
%with or without baselines specified.

lastwarn('');
addpath('Functions');
[warnMsg, warnId] = lastwarn;
if ~isempty(warnMsg)
    questdlg(['Functions directory not found; please select the Spies-lab '...
        'scripts directory to add it to the search path'],'Select search dir',...
    'Ok','Ok');
    cd(uigetdir);
    addpath('Functions');
end

importOldSession = 1; %set this to 1, open up your old saved analysis, and run the code

if ~importOldSession
clear intensity
channels = 2;
intensity = cell([1 channels]);
low = cell([1 channels]);
high = cell([1 channels]);
selection = cell([1 channels]);
trim = cell([1 channels]);
for c = 1:channels

blank = questdlg(['Are your traces for channel ' num2str(c) ...
    ' in a .traces file or saved individually in txt, csv, or dat?'],...
    'Select format','.traces','Individual','Individual');


if blank(2) == 't'
    [donors, acceptors] = extractTracesFiles();
    blank = questdlg(['Would you like channel ' num2str(c)...
        ' to be the donors or acceptors?'],...
        'Select data','Donors', 'Acceptors', 'Donors'); 
    if blank(1) == 'D'
        intensity{c} = donors;
    else
        intensity{c} = acceptors;
    end
    fileNames = cell([length(donors); 1]);
    for i = 1:length(donors)
        fileNames{i} = [ 'trace' num2str(i)];
    end
else
    blank = questdlg(['Select the folder which contains all data for channel ' num2str(c)],...
        'Select folder','Ok','Ok');

    path = uigetdir;


    format = questdlg('Which format are the traces in?','Select format','.csv','.txt','.dat','.dat');

    if format(2) == 'c'
        dir2 = dir([path filesep '*.csv']);
        clear dir3;
        dir3 = { dir2.name };
        A = importdata([ path filesep dir3{1}]);
        meanA = mean(A.data);
    elseif format(2) == 't'
        dir2 = dir([path filesep '*.txt']);
        clear dir3;
        dir3 = { dir2.name };
        A = importdata([ path filesep dir3{1}]);
        meanA = mean(A);

    else
        dir2 = dir([path filesep '*.dat']);
        clear dir3;
        dir3 = { dir2.name };
        A = importdata([ path filesep dir3{1}]);
        meanA = mean(A);

    end

    column = inputdlg(['Which column of the data would you like to assign to channel '...
        num2str(c) '? If it helps, the mean of each column is, in order: ' mat2str(meanA,5) ]);

    column = str2double(column{1});
    intensity{c} = cell(length(dir3),1);
    fileNames = dir3;
    for q = 1:length(dir3)
        A = importdata([ path filesep dir3{q}]);
        if isstruct(A)
            A = A.data;
        end
        intensity{c}(q) = {A(:,column)'};
    end
end
end
N = length(intensity{c});
selectionAll = ones(N,1,'logical');
%keeps track of whether a trace set has passed all criteria for
%being included in the final export:
%must be selected during trace viewing/selection, the corresponding
%trace in all other channels must be selected, must be selected
%for saving during normalization, along with all corresponding traces in
%the other channels
for c = 1:channels
    low{c} = cell([N 1]);
    high{c} = cell([N 1]);
    trim{c} = zeros([N 2]);
end
end
%if you imported old data, this is where you can start:
for c = 1:channels
    [low{c}, high{c}, trim{c}, selection{c}] = selectTracesEmFret(c,intensity, selectionAll, fileNames, low{c}, high{c}, trim{c});
    assert(length(selectionAll)==length(selection{c}),'Multichannel datasets must have same number of traces in all channels');
    %make sure the channels have an equal number of traces
    selectionAll = and(selectionAll,selection{c});
    if isempty(trim{c})
        return %an exit switch for the program, accessible by closing out the selection window 
               %and selecting the quit option
    end
end

[~] = questdlg(['Please select a directory (or make a new one) in'...
    'which to save the backup file'], 'Select Directory','Ok','Ok');
saveDir = uigetdir;
if ~isfolder(saveDir)
    errordlg('Directory not found.  Using default directory');
    saveDir = [];
end
save([saveDir filesep 'Analysis_Save_' mat2str(fix(clock)) ], 'low', 'high', 'trim', 'selection', 'selectionAll', 'intensity','fileNames','channels');
%in case we need to come back to this point and make different decisions

emFret = cell([1 channels]);
saveList = cell([1 channels]);
% intensityTrimmed = intensity;
N = length(intensity{1});
finalTrim = [zeros(N,1) ones(N,1)*1E10];
intensityTrimmed = cell(size(intensity));
%each set of traces must be trimmed, eventually, to the same indices
for c = 1:channels
    for i = 1:N
        finalTrim(i,1) = max(trim{c}(i,1),finalTrim(i,1));
        finalTrim(i,2) = min(trim{c}(i,2),finalTrim(i,2));
    end
end
for c = 1:channels
    for i = 1:N
        intensityTrimmed{c}{i} = intensity{c}{i}(finalTrim(i,1):finalTrim(i,2));
    end
end

for c = 1:channels
    saveList{c} = ones(length(intensityTrimmed{c}),1,'logical');
    emFret{c} = cell([1 N]);
    if isempty(low{c})
        [emFret{c}(selectionAll),saveList{c}(selectionAll)] = smoothNormalize(intensityTrimmed{c}(selectionAll));
    else
        [emFret{c}(selectionAll),saveList{c}(selectionAll)] = normalizeSelection(intensityTrimmed{c}(selectionAll),low{c}(selectionAll,:), high{c}(selectionAll,:)); %normalize selected traces
    end
    selectionAll = and(selectionAll,saveList{c});
end

% for c = 1:channels
%     for i = find(selectionAll)'
% %         emFret{c}{i} = emFret{c}{i}((finalTrim(i,1)-trim{c}(i,1)+1):(finalTrim(i,2)-trim{c}(i,1)+1));
%         %realign all traces, even if they were trimmed differently earlier
%     end
% end

for c = 1:channels
    saveEmFret(emFret{c}(selectionAll),c, fileNames);
end
