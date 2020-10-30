%A wrapper function to guide through data input from raw intensity values
%to "emulated FRET", a normalized version of the signal which can be
%imported to ebFRET, HaMMY, or other programs which assume you will be
%feeding them a FRET signal.
%Contains call to selectTracesEmFret, which allows for trace pre-processing,
%before calling smoothNormalize (if no baselines were selected) or normalizeSelection
%(preferred; uses user input data to help normalize) which smooth and normalize all traces

lastwarn('');
addpath('Functions');
[warnMsg, warnId] = lastwarn;
if ~isempty(warnMsg)
    questdlg(['Functions directory not found; please select the '...
        'sourceCode directory to add it to the search path'],'Select search dir',...
    'Ok','Ok');
    cd(uigetdir);
    addpath('Functions');
end

importOldSession = 1; %set this to 1, open up your old saved analysis, and run the code (don't forget to change it back later)

if ~importOldSession
clear intensity
channels = 2;
low = cell([1 channels]);
high = cell([1 channels]);
selection = cell([1 channels]);
trim = cell([1 channels]);

[intensity,fileNames] = openRawData(channels);

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
[low, high, trim, selectionAll] = selectTracesEmFret(channels, intensity, selectionAll, fileNames, low, high, trim);
if isempty(trim)
    return %an exit switch for the program, accessible by closing out the selection window 
           %and selecting the quit option
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
intensityTrimmed = intensity;
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
    saveEmFret(emFret{c}(selectionAll),c, fileNames(selectionAll));
end
