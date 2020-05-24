addpath('Functions');
%A wrapper function to guide through data input from raw intensity values;
%contains call to "emulateFRET", which allows for trace pre-processing,
%before calling smoothNormalize which smooths and normalizes all traces,
%with or without baselines specified.

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
    for q = 1:length(dir3)
        A = importdata([ path filesep dir3{q}]);
        if isstruct(A)
            A = A.data;
        end
        intensity{c}(q) = {A(:,column)'};
    end
end
    if c == 1
        selectionAll = ones(length(intensity{c}),1,'logical');
    else
        assert(length(selectionAll)==length(selection{c-1}),'Multichannel datasets must have same number of traces in all channels');
        selectionAll = and(selectionAll,selection{c-1});
    end
    [baseline{c}, trim{c}, selection{c}] = selectTracesEmFret(intensity{c}, selectionAll);
    if isempty(trim{c})
        return
    end
end
emFret = cell([1 channels]);
saveList = cell([1 channels]);
for c = 1:channels
    N = length(intensity{c});
    saveList{c} = ones(length(intensity{c}),1,'logical');
    emFret{c} = cell([1 N]);
    for i = 1:N
        intensity{c}{i} = intensity{c}{i}(trim{c}(i,1):trim{c}(i,2));
    end
    if isempty(baseline{c})
        [emFret{c}(selection{c}),saveList{c}(selection{c})] = smoothNormalize(intensity{c}(selection{c}));
    else
        [emFret{c}(selection{c}),saveList{c}(selection{c})] = smoothNormalize(intensity{c}(selection{c}),baseline{c}(selection{c},:)); %normalize selected traces

    end
    selectionAll = and(selectionAll,saveList{c});
end

    plotCut3(emFret{c}(selectionAll),length(intensity{c}{1}),timeUnit);


