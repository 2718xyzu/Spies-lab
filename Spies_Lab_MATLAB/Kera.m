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
        output
    end
    methods
        function kera = Kera()
            kera.gui = keraGUI()
        end

        function getChannelsAndStates(kera)
            prompts = {'Channels', 'States'};
            title = 'Channel and States';
            dims = [1 10];
            default = {'1', '4'};
            channelsAndStates = inputdlg(prompts, title, dims, default);
            kera.channels = round(str2double(channelsAndStates{1}));
            kera.states = round(str2double(channelsAndStates{2}));
            kera.stateList = double(repmat(kera.states, [1 kera.channels]));
        end

        function qubAnalyze(kera, hObject, eventData, handles)
            kera.timeInterval = 1E-3; %time unit used in QuB (milliseconds);
            dir3 = {0};
            kera.getChannelsAndStates()
            [data,names] = findPairs(kera.channels);
            record = zeros(1);
            k=1;
            for i = 1:size(data,4)
                for j = 1:kera.channels
                    timeM = squeeze(data(:,:,j,i));
                    count = 1;
                    for i0 = 1:size(timeM,1)
                        binM(count:count+timeM(i0,2),j) = timeM(i0,1)+1;
                        count = count + timeM(i0,2);
                    end
                    kera.matrix(1:size(binM,1),k) = binM(:,j);
                    k = k+1;
                end
            end
        end

        function ebfretAnalyze(kera, hObject, eventData, handles)
            kera.timeInterval = .1; %time unit used in ebFRET
            [file, path] = uigetfile;
            smdImport = load([path '/' file]);
            kera.getChannelsAndStates()
            for i = 1:size(smdImport.data,2)
                ebfretImport = smdImport.data(i).values(:,4);
                kera.matrix(1:length(ebfretImport),i) = smdImport.data(i).values(:,4);
            end
            kera.matrix(kera.matrix==0) = 1;
            kera.processData()
        end

        function processData(kera)
            kera.stateDwellSummary = dwellSummary(kera.matrix, kera.timeInterval, kera.channels);
            i = 1;
            insert1 = @(item,vector,index) cat(1, vector(1:index-1), item, vector(index:end));
            baseline = sum(2.^[0 cumsum(kera.stateList(1:end-1))]); %the number corresponding to the "default" state
            bFlag = .15; %to flag the beginning of every event
            eFlag = .05; %to flag the end of each event
            powerAddition = [0 cumsum(kera.stateList)];

            while i <= size(kera.matrix,2)
                for j = 1:kera.channels
                    state(:,j) = 2.^(powerAddition(j)+kera.matrix(:,i)-1); %all states represented as binary #'s
                    i=i+1; %move to the next row
                end
                transM(:,1) = sum(state,2); %add together all 'digits' of the binary states
                transM(1:end-2,2) = bFlag*(diff(transM(2:end,1)==baseline)<0); %in a new row, flag every event beginning
                transM(2:end,3) = eFlag*(diff(transM(:,1)~=baseline)<0); %in the third row, flag every event ending
                transM(1:end-1,1) = diff(transM(:,1)); %the only non-zero values are now the transition quantities
                kera.transM = transM;
                transM = sum(transM,2); %add all three rows
                [timeDataTemp,~,nonZerosTemp] = find(transM); %isolate only the non-zero values, with timestamps
                imeDataTemp = timeDataTemp * kera.timeInterval;
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
                timeData(1:dataPoints,(i-1)/kera.channels) = timeDataTemp; %combine into large arrays
                nonZeros(1:dataPoints,(i-1)/kera.channels) = nonZerosTemp;
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

            kera.savePackage.channels = kera.channels;
            kera.savePackage.letters = letters;
            kera.savePackage.timeData = timeData;
            kera.savePackage.nonZeros = nonZeros;
            kera.output = defaultAnalyze2(kera.savePackage); %analyze the structure to produce output
            kera.stateDwellSummary.eventTimes = kera.output(1).timeLengths;

            [~,index] = sortrows([kera.output.count].');
            kera.output = kera.output(index(end:-1:1));
            kera.savePackage.output = kera.output

            if exist('names','var')
                savePackageNames = {'name', 'channels', 'letters', 'timeData', 'nonZeros', 'stateDwellSummary', 'output'};
                savePackageData = {name, kera.savePackage.channels, kera.savePackage.letters, kera.savePackage.timeData, kera.savePackage.nonZeros, kera.stateDwellSummary, kera.savePackage.output};
            else
                savePackageNames = {'channels', 'letters', 'timeData', 'nonZeros', 'stateDwellSummary', 'output'};
                savePackageData = {kera.savePackage.channels, kera.savePackage.letters, kera.savePackage.timeData, kera.savePackage.nonZeros, kera.stateDwellSummary, kera.savePackage.output};
            end

            savePackage = jsonencode(containers.Map(savePackageNames, savePackageData));
            [filename, path] = uiputfile('savePackage.spkg');
            save([path '/' filename], 'savePackage', '-ascii', '-double');
            kera.histogramData()
        end

        function import_spkg(kera, hObject, eventData, handles)
            [filename, path] = uigetfile('*.spkg');
            if filename
                kera.savePackage = jsondecode(char(load([path '/' filename])));
                kera.histogramData()
            else
                error('No file selected');
            end
        end

        function histogramData(kera)
            row = inputdlg('Which row of the output file would you like to plot?','Data select');
            row = str2double(row{1});

            dataType = questdlg('Would you like to plot dwell times or off times?', 'Data select',...
                'Dwell Times', 'Off Times', 'Dwell Times');

            if dataType(1) == 'D'
                out.dataType = 1;
                rawData = kera.savePackage.output(row).timeLengths;
                out.rawData = rawData;
            else
                out.dataType = 2;
                rawData = kera.savePackage.output(row).timeLengths_Gaps;
                out.rawData = rawData;
            end

            fitType = questdlg('Would you like to plot a default or a logarithmic histogram', 'Fit select',...
                'Default', 'Logarithmic', 'Default');

            if fitType(1) == 'D'
                out.fitType = 1;
                out.data = rawData;
            else
                out.fitType = 2;
                out.data = log(rawData);
            end

            order = questdlg('Single or double exponential?', 'Fit select',...
                'Single', 'Double', 'Single');

            if order(1) == 'S'
                out.order = 1;
            else
                out.order = 2;
            end

            hold on;
            out.handle = gcf;


            subplot(1,2,1)
            h1 = histogram(out.data);
            subplot(1,2,2)
            fitModel = getFitHistogram(h1,out.fitType,out.order);

            xList = linspace(h1.BinEdges(1),h1.BinEdges(end),500);
            yList = fitModel(xList);
            plot(xList,yList);
            disp(fitModel);
        end
    end
end
