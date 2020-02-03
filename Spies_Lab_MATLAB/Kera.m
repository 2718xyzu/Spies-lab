classdef Kera < handle
    properties
        gui
        channels
        states
        stateList
        matrix
        timeInterval
        stateDwellSummary
        savePackage
        transM
        rawM
        output
        dataType
        fitType
        order
        filenames
        histogram
        histogramFit
        histogramRow = 1
        visualizeTrans
        
        stateText
        condensedStates
        stateTimes
    end
    methods
        function kera = Kera()
            kera.gui = keraGUI();
        end

        function getChannelsAndStates(kera)
            %GETCHANNELSANDSTATES Prompts the user for the number of channels
            %   and the number of states their data has
            kera.gui.resetError();

            channelsAndStates = kera.gui.inputdlg('Channels and States', {'Channels', 'States in each channel (comma separated)'}, {'1', '4'});
            try
%                 disp(channelsAndStates);
                channelS = round(str2double(channelsAndStates{1}));
                stateLisT = round(eval(['[' channelsAndStates{2} ']' ]));
                if prod(~isreal(stateLisT)) || ~isreal(channelS) || prod(stateLisT < 0) || prod(channelS < 0)
                    kera.gui.errorMessage('Invalid Channel or State');
                    kera.getChannelsAndStates()
                end
                kera.channels = channelS;
                kera.savePackage.channels = channelS;
                kera.stateList = stateLisT;
                kera.savePackage.stateList = stateLisT;
                if length(stateLisT)~=channelS
                    assert(length(stateLisT)==1,'stateList length must match channels');
                    kera.stateList = repmat(stateLisT, [1 channelS]);
                end
            catch
                if isempty(channelsAndStates)
                    kera.gui.errorMessage('Import Cancelled');
                    return
                end
                kera.gui.errorMessage('Invalid Channel or State');
                kera.getChannelsAndStates()
            end
        end

        function qubAnalyze(kera, hObject, eventData, handles)
            %QUBANALYZE Analyzes QuB data
            %   See also EBFRETANALYZE and PROCESSDATA
            kera.gui.resetError();

            kera.timeInterval = 1E-3; %time unit used in QuB (milliseconds);
            dir3 = {0};
            kera.getChannelsAndStates();
            if kera.gui.error
                kera.gui.resetError();
                return
            end
            [data,names] = findPairs(kera);
            if kera.gui.error
                kera.gui.resetError()
                return
            end

            kera.filenames = names;

            record = zeros(1);
            k=1;
            for i = 1:size(data,4)
                clear binM;
                binM = zeros(kera.channels,sum(data(:,1,1,i))+1);
                for j = 1:kera.channels
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
            kera.matrix = matrix;
            kera.processData()
        end

        function ebfretAnalyze(kera, hObject, eventData, handles)
            %EBFRETANALYZE Analyzes ebFRET data
            %   See also QUBANALYZE and PROCESSDATA
            kera.gui.resetError();

            kera.timeInterval = .1; %time unit used in ebFRET
            kera.getChannelsAndStates()
            if kera.gui.error
                kera.gui.resetError();
                return
            end

            if kera.channels == 1
                [file, path] = kera.selectFile();
                smdImport = load([path filesep file]);
                for i = 1:size(smdImport.data,2)
                    ebfretImport = smdImport.data(i).values(:,4);
                    kera.matrix(1:length(ebfretImport),i) = smdImport.data(i).values(:,4);
                end
            else
                kera.matrix = packagePairsebFRET(kera.channels,'smd');
            end

            kera.filenames = num2cell(1:size(kera.matrix,2))';
            %kera.matrix(kera.matrix==0) = 1;
            kera.processData()
        end

        function rawAnalyze(kera, hObject, eventData, handles)
            %RAWANALYZE Analyzes data stored as column vectors of states in
            %MATLAB matrix variables
            %   See also EBFRETANALYZE and PROCESSDATA
            kera.gui.resetError();

            kera.timeInterval = .1; %time unit used in ebFRET
            kera.getChannelsAndStates()
            if kera.gui.error
                kera.gui.resetError();
                return
            end

            if kera.channels == 1
                [file, path] = kera.selectFile();
                kera.matrix = load([path filesep file]);
            else
                kera.matrix = packagePairsebFRET(kera.channels,'raw');
            end

            kera.filenames = num2cell(1:size(kera.matrix,2))';
            %kera.matrix(kera.matrix==0) = 1;
            kera.processData()
        end
        
        
        function processDataStates(kera)
            c = kera.channels;
            try
                assert(mod(size(kera.matrix,2)/c,1)==0);
            catch
                error('Kera matrix does not contain a full set of trajectories for channels specified.  Check number of channels or input size.');
            end
            
            for i = 1:size(kera.matrix,2)/c
                workingStates = kera.matrix(:,(i-1)*c+1:i*c);
                changeStates = diff(workingStates,1,2);
                changeStates = logical([1 sum(abs(changeStates))]);
                kera.condensedStates{i} = workingStates(:,changeStates)';
                kera.stateTimes{i} = find(changeStates).*kera.timeInterval;
            end
            kera.stateText = '';
            for i = 1:length(condensedStates)
                tempText = mat2str(condensedStates{i});
                kera.stateText = [kera.stateText tempText];
            end
            kera.stateText = regexprep(kera.stateText,' ','  ');
            kera.stateText = regexprep(kera.stateText,';',' ; ');
            kera.stateOutput = 
        end
        
        
        function processData(kera)
            kera.gui.resetError();

            kera.stateDwellSummary = dwellSummary(kera.matrix, kera.timeInterval, kera.channels);
            i = 1;
            insert1 = @(item,vector,index) cat(1, vector(1:index-1), item, vector(index:end));
            baseline = sum(2.^[0 cumsum(kera.stateList(1:end-1))]); %the number corresponding to the "default" state
            bFlag = .15; %to flag the beginning of every event
            eFlag = .05; %to flag the end of each event
            fFlag = .35; %to flag the end of each trajectory
            powerAddition = [0 cumsum(kera.stateList)];
            k = 1;
            while i <= size(kera.matrix,2)+1-kera.channels
                for j = 1:kera.channels
                    state(:,j) = 2.^(powerAddition(j)+kera.matrix(:,i)-1); %all states represented as binary #'s
                    i=i+1; %move to the next row
                end
                transM(:,1) = sum(state,2); %add together all 'digits' of the binary states
                rawM = [diff(transM(:,1)); 0];
                kera.rawM = rawM;
                transM(1:end-2,2) = bFlag*(diff(transM(2:end,1)==baseline)<0); %in a new row, flag every event beginning
                transM(2:end,3) = eFlag*(diff(transM(:,1)~=baseline)<0); %in the third row, flag every event ending
                transM(1:end,1) = [diff(transM(:,1)); 0 ]; %the only non-zero values are now the transition quantities
                kera.transM = transM;
                transM = sum(transM,2); %add all three rows
                [timeDataTemp,~,nonZerosTemp] = find(transM); %isolate only the non-zero values, with timestamps
                timeDataTemp = timeDataTemp * kera.timeInterval;
                [timeRawT, ~, nonZerosRawT] = find(rawM);
                timeDataRawT = timeRawT*kera.timeInterval;
                k = logical(abs(mod(nonZerosTemp,1)-(bFlag+eFlag))<.001); %find locations where events are 2 frames long
                if nnz(k)>0
                    for f = fliplr(find(k)')
                        nonZerosTemp = insert1(eFlag,nonZerosTemp, f); %fix the representation of those events
                        timeDataTemp = insert1(timeDataTemp(f),timeDataTemp,f);
                    end
                end
                k = logical(abs(diff(mod(nonZerosTemp,1))+.1)<.001); %find locations where events are 1 frame long

                if nnz(k)>0
                    for f = fliplr(find(k)')
                        nonZerosTemp(f:f+1) = round(nonZerosTemp(f:f+1)); %fix the representation of those events
                        nonZerosTemp = insert1([eFlag ; bFlag], nonZerosTemp, f+1);
                        timeDataTemp = insert1(timeDataTemp(f).*ones(2,1),timeDataTemp,f+1);
                    end
                end
                dataPoints = length(timeDataTemp);
                timeData(1:dataPoints,(i-1)/kera.channels) = timeDataTemp; %combine into large arrays
                nonZeros(1:dataPoints,(i-1)/kera.channels) = nonZerosTemp;
                dataPoints = length(timeDataRawT);
                timeDataRaw(1:dataPoints,(i-1)/kera.channels) = timeDataRawT;
                nonZerosRaw(1:dataPoints,(i-1)/kera.channels) = nonZerosRawT;
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
            
            nonZerosRaw(end+1,:) = 0;
            timeDataRaw(end+1,:) = 0;
            lettersRaw = mat2str(nonZerosRaw');
            lettersRaw = regexprep(lettersRaw,'[ ;]','  ');
            lettersRaw = regexprep(lettersRaw,' 0 ',' , ');
            lettersRaw = lettersRaw(2:end-1);

            kera.savePackage.filenames = kera.filenames;
            kera.savePackage.channels = kera.channels;
            kera.savePackage.letters = letters;
            kera.savePackage.lettersR = lettersRaw;
            kera.savePackage.timeData = timeData;
            kera.savePackage.timeDataR = timeDataRaw;
            kera.savePackage.nonZeros = nonZeros;
            kera.savePackage.nonZerosR = nonZerosRaw;
            kera.output = defaultAnalyze2(kera.channels, kera.stateList, nonZeros, ...
                timeData, letters, kera.filenames); %analyze the structure to produce output
            kera.stateDwellSummary(1).eventTimes = kera.output(1).timeLengths;

            [~,index] = sortrows([kera.output.count].');
            kera.output = kera.output(index(end:-1:1));
            kera.savePackage.output = kera.output;

            kera.postProcessing()
        end

        function importSPKG(kera, hObject, eventData, handles)
            kera.gui.resetError();

            [filename, path] = uigetfile('*.spkg');
            if filename
                kera.savePackage = jsondecode(char(load([path filesep filename])));
                kera.channels = kera.savePackage.channels;
                kera.stateList = kera.savePackage.stateList;
                kera.output = kera.savePackage.output;
                kera.stateDwellSummary = kera.savePackage.stateDwellSummary;
                assignin('base', 'analyzedData', kera.output);
                assignin('base', 'stateDwellSummary', kera.stateDwellSummary);
                kera.postProcessing();
            else
                kera.gui.errorMessage('Failed to import Save Package file');
            end
        end

        function postProcessing(kera)
            % kera.gui.alert('Processing is done!');
            kera.gui.enable('Export');
            assignin('base', 'analyzedData', kera.output);
            assignin('base', 'stateDwellSummary', kera.stateDwellSummary);
            delete(kera.histogram);
            delete(kera.histogramFit);
            delete(kera.visualizeTrans);
            
            kera.histogramRow = 1;
            kera.histogramData(1, 1, 1);
        end

        function exportSPKG(kera, hObject, eventData, handles)
            kera.gui.resetError();

            savePackageNames = {'channels', 'stateList', 'letters', 'timeData', 'nonZeros', 'lettersR', 'timeDataR', 'nonZerosR', 'stateDwellSummary', 'output'};
            savePackageData = {kera.savePackage.channels, kera.savePackage.stateList, kera.savePackage.letters,...
                kera.savePackage.timeData, kera.savePackage.nonZeros, kera.savePackage.lettersR, kera.savePackage.timeDataR, kera.savePackage.nonZerosR, kera.stateDwellSummary, kera.savePackage.output};

            savePackage = jsonencode(containers.Map(savePackageNames, savePackageData));
            [filename, path] = uiputfile('savePackage.spkg');
            save([path filesep filename], 'savePackage', '-ascii', '-double');
        end

        function exportAnalyzed(kera, hObject, eventData, handles)
            kera.gui.resetError();
            ans = questdlg('Select a folder where you want the csv files to be saved', 'Folder Selection', 'Ok', 'Cancel', 'Ok');
            if ~ans=='Ok'
                return
            end
            path = kera.selectFolder();
            if ~exist(path)
                return
            end

            for row = 2:length(kera.output)
                t1 = kera.output(row).table;
                t2 = table(kera.output(row).timeLengths, 'VariableNames', {'Time_Lengths'});
                t = [t2 t1];
                filename = strcat(path, filesep, 'row_', int2str(row), '.csv');
                writetable(t, filename, 'Delimiter', ',');
            end
        end

        function exportStateDwellSummary(kera, hObject, eventData, handles)
            kera.gui.resetError();
            ans = questdlg('Select a folder where you want the csv files to be saved', 'Folder Selection', 'Ok', 'Cancel', 'Ok');
            if ~ans=='Ok'
                return
            end
            path = kera.selectFolder();
            if ~exist(path)
                return
            end

            t1 = table(kera.stateDwellSummary.dwellTimes);
            t2 = table(kera.stateDwellSummary.eventTimes);
            writetable(t1, [path filesep 'dwellTimes.csv'], 'Delimiter', ',');
            writetable(t2, [path filesep 'eventTimes.csv'], 'Delimiter', ',');
        end

        function histogramDataSetup(kera)
            kera.gui.createText('Data Type:', [0.60 0.2 0.2 0.1]);
            kera.gui.createDropdown('dataType', {'Dwell Times', 'Off Times'}, [0.75 0.2 0.2 0.1], @kera.histogramData);
            kera.dataType = 1;

            kera.gui.createText('Fit Type:', [0.60 0.1 0.2 0.1]);
            kera.gui.createDropdown('fitType', {'Default', 'Logarithmic'}, [0.75 0.1 0.2 0.1], @kera.histogramData);
            kera.fitType = 1;

            kera.gui.createText('Data Order:', [0.60 0 0.2 0.1]);
            kera.gui.createDropdown('order', {'Single', 'Double'}, [0.75 0 0.2 0.1], @kera.histogramData);
            kera.order = 1;

            kera.gui.createText(int2str(kera.histogramRow), [0.2 0.10 0.05 0.07]);
            kera.gui.createButton('<', [0.1 0.11 0.1 0.07], @kera.histogramData);
            kera.gui.createButton('>', [0.25 0.11 0.1 0.07], @kera.histogramData);
            kera.gui.createText('Total', [0.15 0.23 0.17 0.07]);
            kera.gui.createButton('Custom Event Search', [0.1 0.04 0.2 0.05], @kera.customSearch);
            kera.gui.createButton('Generate Fits', [0.4 0.15 0.15 0.05], @kera.generateFits);
            
        end

        function customSearch(kera, hObject, eventData, handles)
            searchWindow = figure('Visible','on','Position',[400 400 300 100]);
            searchWindow.MenuBar = 'none';
            searchWindow.ToolBar = 'none'; 
            [channel, transitionList] = customSearchUi(kera.channels, kera.stateList);
            searchExpr = states2search(kera.stateList, channel, transitionList);
            row2fill = size(kera.output,2)+1;
            kera.output(row2fill).expr = {searchExpr};
            [timeLong, posLong, rowLong] = timeLengthen(kera.savePackage.timeDataR,kera.savePackage.lettersR);
            kera.output = fillRow(kera.output, row2fill, searchExpr, kera.savePackage.nonZerosR, kera.channels, ...
                kera.stateList, kera.savePackage.timeDataR, kera.savePackage.lettersR, timeLong, posLong, rowLong, kera.filenames);
            %fillRow(output, i, expr, channels, stateList, timeData, letters, timeLong, posLong, rowLong, filenames)
            clear timeLong posLong rowLong row2fill searchExpr channel transitionList
            assignin('base','analyzedData',kera.output);
            kera.savePackage.output = kera.output;
        end
        
        function histogramData(kera, hObject, eventData, handles)
            kera.gui.resetError();

            if isempty(kera.savePackage)
                kera.gui.errorMessage('Import data before analyzing');
                return
            end

            if isempty(kera.dataType) || isempty(kera.fitType) || isempty(kera.order)
                kera.histogramDataSetup()
            else
                kera.dataType = get(kera.gui.elements('dataType'), 'Value');
                kera.fitType = get(kera.gui.elements('fitType'), 'Value');
                kera.order = get(kera.gui.elements('order'), 'Value');
            end

            if isprop(hObject, 'Style') && strcmpi(get(hObject, 'Style'),'pushbutton')
                if hObject.String == '<' && kera.histogramRow > 1
                    kera.histogramRow = kera.histogramRow - 1;
                elseif hObject.String == '>' && kera.histogramRow < length(kera.savePackage.output)
                    kera.histogramRow = kera.histogramRow + 1;
                end
            end

            set(kera.gui.elements('1'), 'String', kera.histogramRow);
            row = kera.histogramRow;
            set(kera.gui.elements('Total'), 'String', ['Total: ' int2str(kera.output(kera.histogramRow).count)]);

            if kera.dataType == 1
                out.dataType = 1;
                rawData = kera.savePackage.output(row).timeLengths;
                out.rawData = rawData;
            else
                out.dataType = 2;
                rawData = kera.savePackage.output(row).timeLengths_Gaps;
                out.rawData = rawData;
            end

            if kera.fitType == 1
                out.fitType = 1;
                out.data = rawData;
            else
                out.fitType = 2;
                out.data = log(rawData);
            end

            if kera.order == 1
                out.order = 1;
            else
                out.order = 2;
            end

            delete(kera.histogram);
            delete(kera.histogramFit);
            delete(kera.visualizeTrans);
            hold on;
            out.handle = gcf;
            h1 = subplot('Position', [0.05 0.35 0.4 0.45]);
            kera.histogram = histogram(out.data);
            h3 = subplot('Position', [0.05 0.85 0.9 0.1]);
            set(gca, 'ColorOrderIndex', 1);
            try
                [xList, yList, outText] = visualizeTransition(kera.output(row).expr{:},kera.channels, kera.stateList);
            catch
            end
            if row ~= 1
                kera.visualizeTrans = plot(xList, yList, 'LineWidth', 2);
                disp(outText);
            else
                kera.visualizeTrans = plot([1 2 3 4], [0 0 0 0]);
                disp('Wildcard: any event beginning and ending at baseline');
            end
        end
            
        function generateFits(kera, hObject, eventData, handles)
            if isempty(kera.dataType) || isempty(kera.fitType) || isempty(kera.order)
                kera.histogramDataSetup()
            else
                kera.dataType = get(kera.gui.elements('dataType'), 'Value');
                kera.fitType = get(kera.gui.elements('fitType'), 'Value');
                kera.order = get(kera.gui.elements('order'), 'Value');
            end

            row = kera.histogramRow;

            if kera.dataType == 1
                out.dataType = 1;
                rawData = kera.savePackage.output(row).timeLengths;
                out.rawData = rawData;
            else
                out.dataType = 2;
                rawData = kera.savePackage.output(row).timeLengths_Gaps;
                out.rawData = rawData;
            end

            if kera.fitType == 1
                out.fitType = 1;
                out.data = rawData;
            else
                out.fitType = 2;
                out.data = log(rawData);
            end

            if kera.order == 1
                out.order = 1;
            else
                out.order = 2;
            end

            delete(kera.histogramFit);
            hold on;
            out.handle = gcf;
            
            h2 = subplot('Position', [0.55 0.35 0.4 0.45]);
            try
                fitModel = getFitHistogram(kera.histogram,out.fitType,out.order);
                xList = linspace(kera.histogram.BinEdges(1),kera.histogram.BinEdges(end),500);
                yList = fitModel(xList);
                kera.histogramFit = plot(xList, yList);
            catch
                disp('Fitting failed due to insufficient data');
                kera.histogramFit = plot([0 0],[0 0]);
            end
           
        end

        function path = selectFolder(kera)
            p = uigetdir;
            if isempty(p) || ~exist(p,'dir')
                kera.gui.errorMessage('Folder not found');
                return
            end
            path = p;
        end

        function [filename, path] = selectFile(kera)
            [file, dir] = uigetfile;
            if isempty(dir) || isempty(file) || ~exist([dir filesep file], 'file')
                kera.gui.errorMessage('File not found');
                return
            end
            filename = file;
            path = dir;
        end
    end
end
