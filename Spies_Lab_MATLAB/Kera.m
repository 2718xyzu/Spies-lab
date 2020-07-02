classdef Kera < handle
    properties
        gui
        channels
        states
        stateList
        timeInterval = 1
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
        stateOutput
        baseState
        dataLoaded
        dataCell
        dataCellEdited
        importedData
        h2
        dataDisplayed
    end
    methods
        function kera = Kera()
            kera.gui = keraGUI();
        end

        function setChannelState(kera,~,~,~)
            %SETCHANNELSTATE Prompts the user for the number of channels
            %   and the number of states their data has
            kera.gui.resetError();

            channelsAndStates = kera.gui.inputdlg('Channels and States', ...
                {'Channels', 'States in each channel (comma separated)'}, {'1', '4'});
            try
%                 disp(channelsAndStates);
                channelS = round(str2double(channelsAndStates{1}));
                stateLisT = round(eval(['[' channelsAndStates{2} ']' ]));
                if prod(~isreal(stateLisT)) || ~isreal(channelS) || prod(stateLisT < 0) || prod(channelS < 0)
                    kera.gui.errorMessage('Invalid Channel or State');
                    kera.setChannelState()
                    return
                end
                kera.channels = channelS;

                kera.stateList = stateLisT;
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
                kera.setChannelState()
                return
            end
            kera.gui.enable('Set baseline state');
        end
        
        function importSuccessful(kera,~,~,~)
            %keep track of the original data entered vs any changes which are subsequently made
%             kera.dataCellEdited  = kera.dataCell; 
              kera.gui.enable('Analyze');
              if isempty(kera.dataCell)
                  kera.dataCell = kera.importedData;
                  kera.importedData = [];
                  kera.dataCellEdited  = kera.dataCell;
              else
                  anS = questdlg(['You already have data loaded; do you want'...
                      'to overwrite it or append to it with the newly-loaded data?'],...
                      'New data','Overwrite','Append','Overwrite');
                  switch anS
                      case 'Overwrite'
                          kera.dataCell = kera.importedData;
                          kera.dataCellEdited  = kera.dataCell;
                          kera.importedData = [];
                          disp('Data overwritten');
                      case 'Append'
                          kera.dataCell = cat(1,kera.dataCell,kera.importedData);
                          kera.dataCellEdited = cat(1,kera.dataCellEdited,kera.importedData);
                          kera.importedData = [];
                          disp('Data appended');
                  end
              end
        end
        

        function qubImport(kera, hObject, eventData, handles)
            %qubImport imports QuB data and packages it into the standard
            %variable formats
            %   See also ebfretImport and PROCESSDATA
            kera.gui.resetError();
            if isempty(kera.channels) || isempty(kera.stateList)
                kera.setChannelState()
            end
            if kera.gui.error
                kera.gui.resetError();
                return
            end
            [data,names] = findPairs(kera); %currently not sure how to extract raw data from QuB files
            if kera.gui.error
                kera.gui.resetError()
                return
            end

            kera.filenames = names;
            k = 1;
            kera.importedData = cell([size(data,4) kera.channels 2]);
            for i = 1:size(data,1) %number of colocalized trace sets
                clear binM;
                binM = zeros([sum(data{i,1}(:,2)) 1]);
                for j = 1:kera.channels %number of channels
                    timeM = data{i,j};
                    count = 1;
                    for i0 = 1:size(timeM,1) %number of distinct dwells
                        binM(count:count+timeM(i0,2)-1) = timeM(i0,1);
                        count = count + timeM(i0,2);
                    end
                    kera.importedData{i,j,2} = binM(1:end-1);
                    k = k+1;
                end
            end
%             kera.dataCell = dataCell;
            kera.importSuccessful();
%             kera.processData();
%             kera.processDataStates();
        end

        function ebfretImport(kera, hObject, eventData, handles)
            %ebfretImport Analyzes ebFRET data
            %   See also qubImport and PROCESSDATASTATES
            kera.gui.resetError();
            if isempty(kera.channels) || isempty(kera.stateList)
                kera.setChannelState()
            end
            if isempty(kera.timeInterval)
                kera.setTimeStep(kera);
            end
            if kera.gui.error
                kera.gui.resetError();
                return
            end
            [kera.importedData, kera.filenames] = packagePairsebFRET(kera.channels);
            %new scripts:
            kera.importSuccessful();
        end
        
        function viewTraces(kera,~,~,~)
            kera.dataCellEdited = plotdisplayKera(kera.dataCell, kera.dataCellEdited, kera.filenames, kera.timeInterval);
        end
        
        function haMMYImport(kera,hObject, eventData, handles)
            %imports HaMMY data then calls the analysis function
            %   See also qubImport and PROCESSDATASTATES
            kera.gui.resetError();
            if isempty(kera.channels) || isempty(kera.stateList)
                kera.setChannelState()
            end
            if kera.gui.error
                kera.gui.resetError();
                return
            end
            [kera.importedData, kera.filenames] = packagePairsHaMMY(kera.channels);
            kera.importSuccessful();
        end

        function rawAnalyze(kera, hObject, eventData, handles)
            %RAWANALYZE Analyzes data stored as column vectors of states in
            %MATLAB matrix variables
            %   See also ebfretImport and PROCESSDATA
            kera.gui.resetError();
            kera.setChannelState()
            if kera.gui.error
                kera.gui.resetError();
                return
            end
            kera.importSuccessful();
        end
        
        
        function processDataStates(kera, ~, ~, ~)
            if isempty(kera.baseState)
                kera.baseState = ones([1,kera.channels]);
            end
            kera.stateDwellSummary = dwellSummary(kera.dataCell, kera.timeInterval, kera.channels, kera.baseState);
            %dataCell should contain only column vectors, and the vectors
            %for colocalized sets should be the same length
            for i = 1:size(kera.dataCell,1)
                workingStates = horzcat(kera.dataCell{i,:,2});
                changeStates = diff(workingStates);
                changeStates = logical([1; sum(abs(changeStates),2)]);
                kera.condensedStates{i} = workingStates(changeStates,:);
                %Each cell of condensedStates is of the form [ 0 1 0 ; 1 1 0 ; 1 1 1 ...
                % with 'channels' columns, and one row for each transition
                %in other words, list the system's state over time with one
                %entry per state.  The original cell has a row for every
                %single time point, but since the system will sit at a
                %given state for a long time, it's easier to make a set of
                %matrices which just list the state achieved in order,
                %and then record the time at which they happen here:
                kera.stateTimes{i} = [find(changeStates); size(workingStates,1)+1].*kera.timeInterval;
                %the time point of each change in state (transition) as
                %well as the time point occurrig after the end of the trace
            end
%             kera.stateText = '';
%             for i = 1:length(kera.condensedStates)
%                 tempText = mat2str(kera.condensedStates{i});
%                 kera.stateText = [kera.stateText tempText];
%             end
%             kera.stateText = regexprep(kera.stateText,' ','  ');
%             kera.stateText = regexprep(kera.stateText,';',' ; ');
%             kera.stateText = regexprep(kera.stateText,'[','[ ');
%             kera.stateText = regexprep(kera.stateText,']',' ]');
% 
            if isempty(kera.output)
                kera.output = struct([]);
            end
            
            kera.output = defaultStateAnalysis(kera.output, kera.condensedStates, ...
                kera.stateTimes, kera.filenames, kera.baseState, kera.stateList);
%             dispOutput = kera.output;
            kera.stateDwellSummary(1).eventTimes = kera.output(1).timeLengths;
            [~,index] = sortrows([kera.output.count].');
            kera.output = kera.output(index(end:-1:1));
            kera.postProcessing()
        end

        function importSPKG(kera, hObject, eventData, handles) %#ok<*INUSD>
            kera.gui.resetError();

            [filename, path] = uigetfile('*.mat');
            if filename
                tempGui = kera.gui;
                kera = load([path filesep filename]);
                kera.gui = tempGui;
            else
                kera.gui.errorMessage('Failed to import saved session file');
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

%             savePackageNames = {'channels', 'stateList', 'letters', 'timeData', 'nonZeros', 'lettersR', 'timeDataR', 'nonZerosR', 'stateDwellSummary', 'output'};
%             savePackageData = {kera.savePackage.channels, kera.savePackage.stateList, kera.savePackage.letters,...
%                 kera.savePackage.timeData, kera.savePackage.nonZeros, kera.savePackage.lettersR, kera.savePackage.timeDataR,...
%                 kera.savePackage.nonZerosR, kera.stateDwellSummary, kera.savePackage.output};
% 
%             savePackage = jsonencode(containers.Map(savePackageNames, savePackageData)); 
%             [filename, path] = uiputfile('savePackage.spkg');
%             save([path filesep filename], 'savePackage', '-ascii', '-double');
            [filename, path] = uiputfile('savedSession.mat');
            save([path filesep filename], 'kera');
        end

        function exportAnalyzed(kera, hObject, eventData, handles)
            kera.gui.resetError();
            ans1 = questdlg('Select a folder where you want the csv files to be saved', 'Folder Selection', 'Ok', 'Cancel', 'Ok');
            if ~strcmp(ans1,'Ok')
                return
            end
            path = kera.selectFolder();
            if ~exist(path,'var')
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
            ans1 = questdlg('Select a folder where you want the csv files to be saved', 'Folder Selection', 'Ok', 'Cancel', 'Ok');
            if ~strcmp(ans1,'Ok')
                return
            end
            path = kera.selectFolder();
            if ~exist(path,'var')
                return
            end

            t1 = table(kera.stateDwellSummary.dwellTimes);
            t2 = table(kera.stateDwellSummary.eventTimes);
            writetable(t1, [path filesep 'dwellTimes.csv'], 'Delimiter', ',');
            writetable(t2, [path filesep 'eventTimes.csv'], 'Delimiter', ',');
        end

        function histogramDataSetup(kera)
            kera.gui.createText('Data Type:', [0.60 0.2 0.2 0.1]);
            kera.gui.createDropdown('dataType', {'Histogram', 'Cumulative dist.'}, [0.75 0.2 0.2 0.1], @kera.histogramData);
            kera.dataType = 1;

            kera.gui.createText('Fit Type:', [0.60 0.1 0.2 0.1]);
            kera.gui.createDropdown('fitType', {'Default', 'Logarithmic'}, [0.75 0.1 0.2 0.1], @kera.histogramData);
            kera.fitType = 1;

            kera.gui.createText('Data Order:', [0.60 0 0.2 0.1]);
            kera.gui.createDropdown('order', {'Single', 'Double'}, [0.75 0 0.2 0.1], @kera.histogramData);
            kera.order = 1;

            kera.gui.createText(int2str(kera.histogramRow), [0.2 0.10 0.05 0.07]);
            kera.gui.createButton('<', [0.12 0.09 0.1 0.07], @kera.histogramData);
            kera.gui.createButton('>', [0.25 0.09 0.1 0.07], @kera.histogramData);
            kera.gui.createButton('<<', [0.01 0.09 0.1 0.07], @kera.histogramData);
            kera.gui.createButton('>>', [0.36 0.09 0.1 0.07], @kera.histogramData);
            kera.gui.createText('Total', [0.15 0.23 0.17 0.07]);
            kera.gui.createButton('Generate Fits', [0.4 0.15 0.15 0.05], @kera.generateFits); 
        end

        function customSearch(kera, hObject, eventData, handles)
            searchWindow = figure('Visible','on','Position',[400 400 500 350]);
            searchWindow.MenuBar = 'none';
            searchWindow.ToolBar = 'none'; 
            searchMatrix = stateSearchUi(kera.channels, kera.stateList);
            
%             searchExpr = states2search(kera.stateList, channel, transitionList);
            row2fill = size(kera.output,2)+1;
            kera.output(row2fill).searchMatrix = searchMatrix;
            kera.output = fillRowState(kera.output, row2fill, searchMatrix,...
                kera.condensedStates, kera.stateTimes, kera.filenames);
            %fillRow(output, i, expr, channels, stateList, timeData, letters, timeLong, posLong, rowLong, filenames)
            assignin('base','analyzedData',kera.output);
%             kera.savePackage.output = kera.output;
        end
        
        function histogramData(kera, hObject, eventData, handles)
            kera.gui.resetError();

            if isempty(kera.savePackage)
%                 kera.gui.errorMessage('Import data before analyzing');
%                 return
            end

            if isempty(kera.dataType) || isempty(kera.fitType) || isempty(kera.order)
                kera.histogramDataSetup()
            else
                kera.dataType = get(kera.gui.elements('dataType'), 'Value');
                kera.fitType = get(kera.gui.elements('fitType'), 'Value');
                kera.order = get(kera.gui.elements('order'), 'Value');
            end

            if isprop(hObject, 'Style') && strcmpi(get(hObject, 'Style'),'pushbutton')
                if strcmp(hObject.String,'<') && kera.histogramRow > 1
                    kera.histogramRow = kera.histogramRow - 1;
                elseif strcmp(hObject.String,'>') && kera.histogramRow < length(kera.output)
                    kera.histogramRow = kera.histogramRow + 1;
                elseif strcmp(hObject.String,'>>')
                    kera.histogramRow = length(kera.output);
                elseif strcmp(hObject.String,'<<')
                    kera.histogramRow = 1;    
                end
            end

            set(kera.gui.elements('1'), 'String', kera.histogramRow);
            row = kera.histogramRow;
            set(kera.gui.elements('Total'), 'String', ['Total: ' int2str(kera.output(kera.histogramRow).count)]);

            out.dataType = kera.dataType; %1 = normal histogram, 2 = cumulative distribution fit
            out.fitType = kera.fitType;
            out.order = kera.order;
            out.data = kera.output(row).timeLengths;
            
            delete(kera.histogram);
            delete(kera.histogramFit);
            delete(kera.visualizeTrans);
            hold on;
%             out.handle = gcf;
            h1 = subplot('Position', [0.05 0.35 0.4 0.45]); 
            kera.dataDisplayed = out.data;
            switch kera.dataType
                case 1
                    kera.histogram = histogram(h1,out.data);
                case 2
                    kera.histogram = plot(h1,sort(out.data),linspace(0,1,length(out.data)));
            end
            h3 = subplot('Position', [0.05 0.85 0.9 0.1]);
            set(gca, 'ColorOrderIndex', 1);

            [xList, yList] = visualizeTransition(kera.output(row).searchMatrix,kera.channels);
            for j = 2:size(yList,2)
                yList(:,j) = yList(:,j)+.05*j; %make them easier to tell apart
            end
            kera.visualizeTrans = plot(h3,xList, yList, 'LineWidth', 2);
            ylim([min(yList,[],'all')-.2 max(yList(~isnan(mod(yList,1))),[],'all')+.2]);
            xlim([min(xList,[],'all') max(xList,[],'all')]);
%                 disp(outText);
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

            out.dataType = kera.dataType; %1 = normal histogram, 2 = cumulative distribution fit
            out.fitType = kera.fitType;
            out.order = kera.order;
            out.data = kera.output(row).timeLengths;

            delete(kera.histogramFit);
            hold on;
%             out.handle = gcf;
            if isempty(kera.h2)
                kera.h2 = subplot('Position', [0.55 0.35 0.4 0.45]);
            end
            cla(kera.h2);
            try
                [fitModel, rateText, out.data] = getFitHistogram(out.data,out.dataType,out.fitType,out.order, kera.timeInterval);
                xList = linspace(min(out.data),max(out.data),500);
                yList = fitModel(xList);
                kera.histogramFit = plot(kera.h2, xList, yList);
                text(kera.h2, mean(xList),prctile(yList,90),rateText);
            catch
                disp('Fitting failed due to insufficient data');
                kera.histogramFit = plot(kera.h2,[0 0],[0 0]);
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
        
        %NOTE: changing the timestep or baseState after loading data means
        %that you have to run the default analysis again, and so you should
        %really make sure these are correct before doing any custom
        %searching (since the default analysis clears out any custom search
        %results)
        
        %It's probably just best to make a whole new KERA session and
        %export if you think changing the base state is an interesting
        %analysis to do on your data
        
        function setTimeStep(kera,~,~,~)
            timeIntervalCell = inputdlg('Please enter the time interval, in seconds, between data points');
            kera.timeInterval = eval(timeIntervalCell{1});
        end
        
        function setBaselineState(kera, ~, ~, ~)
            kera.baseState = stateSetUi(kera.channels, kera.stateList);
        end
            
    end
end
