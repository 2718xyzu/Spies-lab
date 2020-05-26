
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

clear intensity
channels = 2;
intensity = cell([1 channels]);
baseline = cell([1 channels]);
selection = cell([1 channels]);
trim = cell([1 channels]);
for c = 1:channels

blank = questdlg('Are your traces in a .traces file or saved individually in txt, csv, or dat?',...
    'Select format','.traces','Individual','Individual');


if blank(2) == 't'
    [donors, acceptors] = extractTracesFiles();
    blank = questdlg('Would you like to run emFRET on the donors or acceptors?','Select data','Donors', 'Acceptors', 'Donors'); 
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
    blank = questdlg('Select the folder which contains all traces to normalize',...
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

    column = inputdlg(['Which column of the data would you like extracted?  If you want each column extracted, type "all".' ...
        ' If it helps, the mean of each column is, in order: ' mat2str(meanA,5) ]);

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
for c = 1:channels
    if c == 1
        selectionAll = ones(length(intensity{c}),1,'logical');
        %keeps track of whether a trace set has passed all criteria for
        %being included in the final export:
        %must be selected during trace viewing/selection, the corresponding
        %trace in all other channels must be selected, must be selected
        %for saving during normalization, along with all corresponding traces in
        %the other channels 
    else
        assert(length(selectionAll)==length(selection{c-1}),'Multichannel datasets must have same number of traces in all channels');
        %make sure the corresponding traces have the same number of time points
        selectionAll = and(selectionAll,selection{c-1});
    end
    [baseline{c}, trim{c}, selection{c}] = selectTracesEmFret(intensity{c}, selectionAll, fileNames);
    if isempty(trim{c})
        return
    end
end

selectionAll = and(selectionAll,selection{end});
emFret = cell([1 channels]);
saveList = cell([1 channels]);
% intensityTrimmed = intensity;
N = length(intensity{1});
finalTrim = zeros(N,2);
%each set of traces must be trimmed, eventually, to the same indices
for c = 1:channels
    saveList{c} = ones(length(intensity{c}),1,'logical');
    emFret{c} = cell([1 N]);
    for i = 1:N
        intensity{c}{i} = intensity{c}{i}(trim{c}(i,1):trim{c}(i,2)); %Fix this
        finalTrim(i,1) = max(trim{c}(i,1),finalTrim(i,1));
        finalTrim(i,2) = min(trim{c}(i,2),finalTrim(i,2));
    end
    if isempty(baseline{c})
        [emFret{c}(selection{c}),saveList{c}(selection{c})] = smoothNormalize(intensity{c}(selection{c}));
    else
        [emFret{c}(selection{c}),saveList{c}(selection{c})] = smoothNormalize(intensity{c}(selection{c}),baseline{c}(selection{c},:)); %normalize selected traces
    end
    selectionAll = and(selectionAll,saveList{c});
end

for c = 1:channels
    for i = 1:N
        emFret{c}{i} = emFret{c}{i}((finalTrim(i,1)-trim{c}(i,1)+1):(finalTrim(i,2)-trim{c}(i,1)+1));
        %realign all traces, even if they were trimmed differently earlier
    end
    saveEmFret(emFret{c}(selectionAll),c);

end
