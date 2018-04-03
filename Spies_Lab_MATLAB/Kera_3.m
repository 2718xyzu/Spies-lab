addpath('Functions');
clear nonZeros;
clear timeData;
clear names;
inputMethod = 'ebFRET';

loading = 1;
i = questdlg('Do you have a SavePackage to upload?  If so, you will be prompted to select it',...
     'Input Method', 'Select SavePackage', 'Import new data files', 'Import new data files');

initialSettings = inputdlg({['Which input method would you like to use?'...
    '  Type ebFRET or QuB'], 'How many channels (colors) are you analyzing?',...
    'How many states does your model have?'}, 'Settings',3,{'ebFRET','1','4'});
inputMethod = initialSettings{1};
channels = round(str2double(initialSettings{2})); %i.e. a channel for cy3 and one for cy5
states = round(str2double(initialSettings{3}));
stateList = double(repmat(states,channels)); %i.e. [2 2] for two states in each of two channels

if ismac
    slash = '/';
elseif ispc
    slash = '\';
else
    slash = '/';
end

if i(1) == 'S'
    uiopen; %open savePackage and unload data
        loading = 0;
        if exist('savePackage','var')
            fields = fieldnames(savePackage);
            for i = 1:numel(fields)
                eval([fields{i} ' = savePackage.' fields{i} ';' ]);
            end

        else
            error('Not a valid SavePackage; variable name in workspace must be savePackage');
        end
end


if loading
if inputMethod(1) == 'q' || inputMethod(1) == 'Q' %Determine the method of analysis: QuB or ebFRET
    timeInterval = 1E-3; %time unit used in QuB (milliseconds);
    dir3 = {0};
        clear data;
        clear names;
        [data,names] = findPairs(channels);

        record = zeros(1);
        clear matrix; %location to store all QuB data in form parseable by the program
        k=1;
        for i = 1:size(data,4);
            clear binM;
            clear transM;
            for j = 1:channels
                timeM = squeeze(data(:,:,j,i));
                count = 1;
                for i0 = 1:size(timeM,1)
                    binM(count:count+timeM(i0,2),j) = timeM(i0,1)+1;
                    count = count + timeM(i0,2);
                end
                matrix(1:size(binM,1),k) = binM(:,j);
                k = k+1;
            end

        end

elseif inputMethod(1) == 'e' || inputMethod(1) == 'E' %ebFRET ordered traces
         timeInterval = .1; %time unit used in ebFRET
         [file, path, ~] = uigetfile;
         smdImport = load([path slash file]);
         clear matrix;
         for i = 1:size(smdImport.data,2)
            import = smdImport.data(i).values(:,4);
            matrix(1:length(import),i) = smdImport.data(i).values(:,4);
         end
         matrix(matrix==0) = 1;
else
    error('Not a valid input method.  String must be either qub or ebfret.');
end

stateDwellSummary = dwellSummary(matrix,timeInterval, channels);
i = 1;
insert1 = @(item,vector,index) cat(1, vector(1:index-1), item, vector(index:end));
baseline = sum(2.^[0 cumsum(stateList(1:end-1))]); %the number corresponding to the "default" state
bFlag = .15; %to flag the beginning of every event
eFlag = .05; %to flag the end of each event
powerAddition = [0 cumsum(stateList)];

while i <= size(matrix,2);
    clear transM; %transM will hold, in three columns, the states and event flags
    clear state;
    for j = 1:channels
        state(:,j) = 2.^(powerAddition(j)+matrix(:,i)-1); %all states represented as binary #'s
        i=i+1; %move to the next row
    end
    transM(:,1) = sum(state,2); %add together all 'digits' of the binary states
    transM(1:end-2,2) = bFlag*(diff(transM(2:end,1)==baseline)<0); %in a new row, flag every event beginning
    transM(2:end,3) = eFlag*(diff(transM(:,1)~=baseline)<0); %in the third row, flag every event ending
    transM(1:end-1,1) = diff(transM(:,1)); %the only non-zero values are now the transition quantities
    transMStore = transM;
    transM = sum(transM,2); %add all three rows
    [timeDataTemp,~,nonZerosTemp] = find(transM); %isolate only the non-zero values, with timestamps
    timeDataTemp = timeDataTemp * timeInterval;
    k = logical(abs(mod(nonZerosTemp,1)-(bFlag+eFlag))<.01); %find locations where events are 2 frames long
    if nnz(k)>0
        for f = fliplr(find(k)')
            nonZerosTemp = insert1(eFlag,nonZerosTemp, f); %fix the representation of those events
            timeDataTemp = insert1(timeDataTemp(f),timeDataTemp,f);
        end
    end
    k = logical(abs(diff(mod(nonZerosTemp,1))+.1)<.01); %find locations where events are 1 frame long

    if nnz(k)>0
        for f = fliplr(find(k)')
            nonZerosTemp(f:f+1) = round(nonZerosTemp(f:f+1)); %fix the representation of those events
            nonZerosTemp = insert1([eFlag ; bFlag], nonZerosTemp, f+1);
            timeDataTemp = insert1(timeDataTemp(f).*ones(2,1),timeDataTemp,f+1);
        end
    end
    dataPoints = length(timeDataTemp);
    timeData(1:dataPoints,(i-1)/channels) = timeDataTemp; %combine into large arrays
    nonZeros(1:dataPoints,(i-1)/channels) = nonZerosTemp;
    end
    nonZeros(nonZeros == bFlag+eFlag) = bFlag; %consolidate event markers
    nonZeros(end+1,:) = 0;
    timeData(end+1,:) = 0;
    letters = mat2str(nonZeros'); %create text array from the nonZero matrix
    letters = regexprep(letters,'0\.05','_');
    letters = regexprep(letters,'0\.15','_');
    letters = regexprep(letters,'[ ;]','  ');
    letters = regexprep(letters,' 0 ',' , ');
    letters = letters(2:end-1);

    savePackage.channels = channels;
    savePackage.letters = letters;
    savePackage.timeData = timeData;
    savePackage.nonZeros = nonZeros;
    if exist('names','var')
        savePackage.names = names;
    end
    %store data, including 'names' if that information was given

    output = defaultAnalyze2(savePackage); %analyze the structure to produce output
    stateDwellSummary.eventTimes = output(1).timeLengths;

    [~,index] = sortrows([output.count].');
    output = output(index(end:-1:1));
    clear index;
    %Sort events by most common
    savePackage.stateDwellSummary = stateDwellSummary;
    savePackage.output = output;
    %save the output, and save the savePackage to computer
    uisave('savePackage');
end

msgbox(['You may view the data by opening the variables named "output" and "stateDwellSummary".  '...
    'Use the command line to execute further analyses; the commands '...
    '"out = eventSearch(savePackage);" and "out = histogramData(savePackage" '...
    'are supported']);
fprintf(['You may view the data by opening the variable named "output" and "stateDwellSummary". \n '...
    'Use the command line to execute further analyses; the commands '...
     '\n out = eventSearch(savePackage); \n  and \n out = histogramData(savePackage); \n '...
    'are supported \n']);
