classdef Kera < handle
    properties
        output
        stateDwellSummary
        versionNumber = '3.0.0'
        gui
        channels
        states
        stateList
        timeInterval
        savePackage
        transM
        rawM
        dataType
        fitType
        order
        filenames
        Histogram
        histogramFit
        histogramRow
        visualizeTrans
        selection
        stateText
        condensedStates
        stateTimes
        stateOutput
        baseState
        dataLoaded
        dataCell
        dataCellEdited
        importedData
        importedFilenames
        h1
        h2
        h3
        dataDisplayed
        dwellSelection
        dwellSelectionOn = 0;
    end
    methods
        function kera = Kera(new)
            if new %a new Kera is initialized if an argument is given; otherwise it will not
                kera.gui = keraGUI();
                kera.gui.createPrimaryMenu('Import');
                kera.gui.createSecondaryMenu('Import', 'ebFRET', @kera.ebfretImport);
                kera.gui.createSecondaryMenu('Import', 'QuB', @kera.qubImport);
                kera.gui.createSecondaryMenu('Import', 'Hammy', @kera.haMMYImport);
                kera.gui.createSecondaryMenu('Import', 'hFRET', @kera.hFRETImport);
                kera.gui.createSecondaryMenu('Import', 'Raw Data Cell', @kera.rawImport);
                kera.gui.createSecondaryMenu('Import', 'Saved Session', @kera.importSPKG);
                %add a line here to create a new import option, then create a function
                %(like the @ functions above) inside the file Kera.m to execute your import
                %script.  An example has been included as "exampleImport" there; rename it
                %and fill it in with your own code

                kera.gui.createPrimaryMenu('Export');
                kera.gui.createSecondaryMenu('Export', 'Save Session', @kera.exportSPKG);
                kera.gui.createSecondaryMenu('Export', 'Analyzed Data');
                kera.gui.createSecondaryMenu('Analyzed Data', 'csv', @kera.exportAnalyzed);
                kera.gui.createSecondaryMenu('Export', 'State Dwell Summary');
                kera.gui.createSecondaryMenu('State Dwell Summary', 'csv', @kera.exportStateDwellSummary);

                kera.gui.createPrimaryMenu('Analyze');
                kera.gui.createSecondaryMenu('Analyze', 'View Data', @kera.viewTraces);
                kera.gui.createSecondaryMenu('Analyze', 'Run/Refresh Analysis', @kera.processDataStates);
                kera.gui.createSecondaryMenu('Analyze','Custom Search', @kera.customSearch);
                kera.gui.createSecondaryMenu('Analyze','Regex Search (advanced)', @kera.regexSearchUI);
                kera.gui.createSecondaryMenu('Analyze','Open in cftool',@kera.opencftool);

                kera.gui.createPrimaryMenu('Settings');
                kera.gui.createSecondaryMenu('Settings','Set channels and states', @kera.setChannelState);
                kera.gui.createSecondaryMenu('Settings','Set time step', @kera.setTimeStep);
                kera.gui.createSecondaryMenu('Settings','Set baseline state', @kera.setBaselineState);
                kera.gui.createSecondaryMenu('Settings','Toggle intraevent kinetics', @kera.toggleDwellSelection);
                kera.gui.createSecondaryMenu('Settings','Name Window', @kera.nameWindow);
                kera.gui.createSecondaryMenu('Settings','Update old file', @kera.updateOldFile);

                %commands which should not be available at the beginning but which will be
                %enabled later:
                kera.gui.disable('Export');
                kera.gui.disable('Analyze');
                kera.gui.disable('Set baseline state');
                kera.gui.disable('Toggle intraevent kinetics');
                kera.gui.disable('Open in cftool');
                
                assignin('base',['kera' num2str(get(gcf,'Number'))],kera);
                disp(['New kera window opened; figure named ' num2str(get(gcf,'Number')) ' and variable named kera' num2str(get(gcf,'Number'))]);
            end
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

        function qubImport(kera, hObject, eventData, handles)
            %qubImport imports QuB data and packages it into the standard
            %variable formats
            %   See also ebfretImport and PROCESSDATA
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
            [data,names] = findPairs(kera);
            %raw (pre-discretization) data is not extracted from QuB
            if kera.gui.error
                kera.gui.resetError()
                return
            end

            kera.importedFilenames = names;
            k = 1;
            kera.importedData = cell([size(data,4) kera.channels 2]);
            for i = 1:size(data,1) %number of colocalized trace sets
                clear binM;
                binM = zeros([sum(data{i,1}(:,2)) 1]);
                for j = 1:kera.channels %number of channels
                    timeM = data{i,j};
                    count = 1;
                    for i0 = 1:size(timeM,1) %number of distinct dwells
                        binM(count:count+timeM(i0,2)-1) = timeM(i0,1)+1;
                        %QuB makes 0 its default lowest state, but in KERA
                        %all states must be positive integers, hence the +1
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
            [kera.importedData, kera.importedFilenames] = packagePairsebFRET(kera.channels);
            kera.importSuccessful();
        end
        
        function hFRETImport(kera, hObject, eventData, handles)
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
            [kera.importedData, kera.importedFilenames] = packagePairshFRET(kera.channels);
            kera.importSuccessful();
        end
        
        
        function haMMYImport(kera,hObject, eventData, handles)
            %imports HaMMY data then calls the analysis function
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
            [kera.importedData, kera.importedFilenames] = packagePairsHaMMY(kera.channels);
            kera.importSuccessful();
        end
        
        function rawImport(kera, ~, ~, ~)
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
            [~] = questdlg('Please select the .mat file containing the dataCell (see documentation for format)',...
                'Select file','Ok','Ok');
            %also see the long comment below in the exampleImport function
            [file, path] = uigetfile();
            dataCellTemp = load([path filesep file]);
            fieldNames = fieldnames(dataCellTemp);
            kera.importedData = dataCellTemp.(fieldNames{1}); 
            for i = 1:size(kera.importedData,1)
                kera.importedFilenames{i} = num2str(i);
            end
            kera.importSuccessful();
        end
        
        function importSPKG(kera, hObject, eventData, handles) %#ok<*INUSD>
            kera.gui.resetError();
            [filename, path] = uigetfile('*.mat');
            if filename
%                 guiTemp = kera.gui.guiWindow;
                kera2 = load([path filesep filename]); %load all variables; "kera" might not be called kera
                namestr = inputdlg('Give your new KERA window a label');
                set(kera2.kera.gui.guiWindow,'Name',namestr{1});
                assignin('base',['kera' num2str(get(gcf,'Number'))],kera2.kera);
                disp(['New kera window opened; figure named ' namestr{1} ' and variable named kera' num2str(get(gcf,'Number'))]);
%                 kera.gui.guiWindow = guiTemp;
            else
                kera.gui.errorMessage('Failed to import saved session file');
            end
        end
        
        
        function exampleImport(kera, ~, ~, ~)
            %this example function can be altered to allow the import of a
            %filetype not currently supported
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
            
            %[kera.importedData, kera.importedFilenames] = yourfunctionhere(channels);
            
            %write a function, place it in the "functions" folder, and make
            %sure the output arguments hold to the following conventions:
            
            %importedData must be an N-by-Channels-by-2 cell, where N is
            %the number of traces (or trace pairs, etc.) and Channels is the
            %number of channels.  Each cell must contain a column vector,
            %and the colunmn vector in importedData(1,a,1) must have the
            %same length as importedData(1,b,1) and importedData(1,a,2).
            %This is because importedData(1,a,1) and importedData(1,b,1)
            %are the time series of the same colocalized trace but in the
            %different channels.  The (:,:,1) entries are the "raw" data
            %values (the pure fluorescence or FRET values) whereas the
            %(:,:,2) entries are column vectors of integers, which
            %correspond to the discretized traces.  All values in the
            %discretized trace cells must be integers greater than 0 in
            %order for the "viewing" functions to work correctly, and though the
            %analysis can probably still run if some of the states are 
            %0, the custom search interface will not be able to access
            %those states (you may have to dig in to the code a bit to
            %change how the custom search works).  
            %Putting anything in the "raw" data cells is optional, as this
            %only shows up when viewing the data and setting the dead time,
            %and otherwise has no bearing on the analysis
            
            %filenames should be a N-by-1 cell of strings which identify
            %the trace sets.  This could be as simple as making a list of
            %{'1'; '2'; .... 'N'} or you could actually try to pull some 
            %filename information from the imported data
            
            %For help on crafting an import function for your type of data,
            %contact Joseph Tibbs at jtibbs2@illinois.edu, or the authors
            %of a paper who you know have used KERA on the type of data you
            %want to.
            
            kera.importSuccessful();
        end
        
        function importSuccessful(kera,~,~,~)
            %keep track of the original data entered vs any changes which are subsequently made
%             kera.dataCellEdited  = kera.dataCell; 
              kera.gui.enable('Analyze');
              if isempty(kera.dataCell)
                  kera.dataCell = kera.importedData;
                  kera.importedData = [];
                  kera.dataCellEdited  = kera.dataCell;
                  kera.filenames = kera.importedFilenames;
                  kera.importedFilenames = [];
              else
                  anS = questdlg(['You already have data loaded; do you want'...
                      'to overwrite it or append to it with the newly-loaded data?'],...
                      'New data','Overwrite','Append','Overwrite');
                  switch anS
                      case 'Overwrite'
                          kera.dataCell = kera.importedData;
                          kera.dataCellEdited  = kera.dataCell;
                          kera.importedData = [];
                          kera.filenames = kera.importedFilenames;
                          kera.importedFilenames = [];
                          disp('Data overwritten');
                      case 'Append'
                          kera.dataCell = cat(1,kera.dataCell,kera.importedData);
                          kera.dataCellEdited = cat(1,kera.dataCellEdited,kera.importedData);
                          kera.filenames = cat(1,kera.filenames,kera.importedFilenames);
                          kera.importedData = [];
                          kera.importedFilenames = [];
                          disp('Data appended');
                  end
              end
              kera.selection = ones([size(kera.dataCell,1) 1],'logical');
        end
        
        function viewTraces(kera,~,~,~)
            [kera.dataCellEdited, kera.selection, kera.stateList] = plotdisplayKera(kera.dataCell, kera.dataCellEdited, kera.filenames, kera.timeInterval, kera.selection);
        end

        function preProcessing(kera, ~, ~, ~)          
            if isempty(kera.baseState)
                kera.baseState = ones([1,kera.channels]);
            end
            Y = kera.selection;
            kera.stateDwellSummary = dwellSummary(kera.dataCellEdited(Y,:,:), kera.timeInterval, kera.channels, kera.baseState);
            %dataCell should contain only column vectors, and the vectors
            %for colocalized sets should be the same length
            for i = find(Y)'
                workingStates = horzcat(kera.dataCellEdited{i,:,2});
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
            
            if isempty(kera.output)
                kera.output = struct([]);
            end

        end
        
        function processDataStates(kera, ~, ~, ~)
            kera.preProcessing();
            kera.output = defaultStateAnalysis(kera.output, kera.condensedStates, ...
                kera.stateTimes, kera.filenames, kera.baseState, kera.stateList, kera.selection);
%             dispOutput = kera.output;
%             kera.stateDwellSummary(1).eventTimes = kera.output(1).timeLengths;
            anS = questdlg(['Would you like to sort the classifications '...
                'by order of frequency, or leave the ordering as it was before?'],'Sort?','Sort','Do not sort','Do not sort');
            if strcmp(anS,'Sort')
                [~,index] = sortrows([kera.output.count].');
                kera.output = kera.output(index(end:-1:1));
            end
            kera.postProcessing();
            
        end
        
        function customSearch(kera, hObject, eventData, handles)
            kera.preProcessing();
            searchWindow = figure('Visible','on','Position',[400 400 500 350]);
            searchWindow.MenuBar = 'none';
            searchWindow.ToolBar = 'none'; 
            searchMatrix = stateSearchUi(kera.channels, kera.stateList);
            row2fill = size(kera.output,2)+1;
            kera.output(row2fill).searchMatrix = searchMatrix;
            kera.output = fillRowState(kera.output, row2fill, searchMatrix,...
                kera.condensedStates, kera.stateTimes, kera.filenames, kera.selection);
            kera.postProcessing();

        end
        
        function regexSearchUI(kera,~,~,~)
            kera.preProcessing();
            regexInput = inputdlg(['Input string of regular expression text with which to search the data.'...
                '  See regexSearch.m and the documentation for conventions']);
            try
                assert(~isempty(regexInput)); %make sure they didn't hit cancel
            catch
                return
            end
            regexInput = regexInput{1};
            searchMatrix = double(regexInput); %convert to a numerical array
            searchMatrix = [-1 searchMatrix]; %append the flag
            row2fill = size(kera.output,2)+1;
            kera.output(row2fill).searchMatrix = searchMatrix; %same process as customSearch (above)
            kera.output = fillRowState(kera.output, row2fill, searchMatrix,... 
                kera.condensedStates, kera.stateTimes, kera.filenames, kera.selection);
            kera.postProcessing();
        end



        function postProcessing(kera)
            % kera.gui.alert('Processing is done!');
            kera.gui.enable('Export');
            kera.gui.enable('Toggle intraevent kinetics');
            
            assignin('base', 'analyzedData', kera.output);
            assignin('base', 'stateDwellSummary', kera.stateDwellSummary);
            
            delete(kera.Histogram);
            delete(kera.histogramFit);
            delete(kera.visualizeTrans);
            
            if isempty(kera.histogramRow)
                %set up the whole histogram interface
                kera.histogramDataSetup();
            end
            kera.histogramData(); %display the histograms
            kera.createTransitionVisual(); %display the top panel visualization
            N = length(kera.output);
            labels = cellfun(@num2str,mat2cell((1:N)', ones(1,N)),'UniformOutput',false);
            set(kera.gui.elements('Jump to Row'), 'String', labels);
            set(kera.gui.elements('Jump to Row'), 'Value', kera.histogramRow)
        end

        function exportSPKG(kera, hObject, eventData, handles)
            %save the entire session (a good idea if you want to continue
            %analysis at a later date)
            kera.gui.resetError();
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
            if ~exist('path','var')
                return
            end
            for row = 1:length(kera.output)
                try
                t = kera.output(row).table;
                filename = [path, filesep, 'row_', int2str(row), '.csv'];
                writetable(t, filename, 'Delimiter', ',');
                catch
                end
            end
        end

        function exportStateDwellSummary(kera, hObject, eventData, handles)
            kera.gui.resetError();
            channelAns = inputdlg('Which channel would you like to export the dwells of?'); 
            channelExport = str2double(channelAns{1});
            dwellAns = questdlg('Export dwell times excluding edge states (states occurring at the beginning or end of a trace)',...
                'Exclude edge states?', 'Exclude edges', 'Include edges','Exclude edges');
            switch dwellAns(1) %if you change the prompt, remember to change the cases
                case 'E'
                    cellSave = kera.stateDwellSummary(channelExport).dwellTimes;
                case 'I'
                    cellSave = kera.stateDwellSummary(channelExport).dwellTimesWithEdges;
                otherwise
                    warning(['Save failed because the button pressed did not'...
                        ' match the cases in this switch block.  Please review the'...
                        ' code at this location']);
                    return
            end
            dataSave = zeros([1 length(cellSave)]);
            for i = 1:length(cellSave)
                dataSave(1:length(cellSave{i}),i) = cellSave{i};
            end
            
            ans1 = questdlg('Select a folder where you want the csv files to be saved', 'Folder Selection', 'Ok', 'Cancel', 'Ok');
            if ~strcmp(ans1,'Ok')
                return
            end
            path = kera.selectFolder();
            if ~exist('path','var')
                return
            end

            t1 = table(dataSave); %make it csv friendly
            writetable(t1, [path filesep 'channel_' num2str(channelExport) '_' dwellAns(1) '_dwellTimes.csv'], 'Delimiter', ',');
        end

        function histogramDataSetup(kera)
            
            %sets up all the buttons and ui for interacting with the
            %histogram screen.  It's important to remember that most of the
            %items here are referred to elsewhere by their string, so
            %changing the displayed string might break some of the other
            %interaction code.
            
            kera.histogramRow = 1;
            kera.gui.enable('Open in cftool');
            kera.gui.createText('Data Type:', [0.60 0.2 0.2 0.1]);
            kera.gui.createDropdown('dataType', {'Histogram', 'Cumulative dist.'}, [0.75 0.2 0.2 0.1], @kera.histogramData);
            kera.dataType = 1;

            kera.gui.createText('Fit Type:', [0.60 0.1 0.2 0.1]);
            kera.gui.createDropdown('fitType', {'Default', 'Logarithmic'}, [0.75 0.1 0.2 0.1], @kera.histogramData);
            kera.fitType = 1;

            kera.gui.createText('Data Order:', [0.60 0 0.2 0.1]);
            kera.gui.createDropdown('order', {'Single', 'Double'}, [0.75 0 0.2 0.1], @kera.histogramData);
            kera.order = 1;
            
            kera.gui.createDropdown('dwellSelection', {'All'}, [.5 .15 .13 .1], @kera.dwellSelectionChange);
            set(kera.gui.elements('dwellSelection'), 'Visible', 'off');
            kera.dwellSelection = 1;

            kera.gui.createText('Row: 1', [0.2 0.17 0.05 0.07]);
            kera.gui.createButton('<', [0.12 0.09 0.1 0.07], @kera.backOne);
            kera.gui.createButton('>', [0.25 0.09 0.1 0.07], @kera.forwardOne);
            kera.gui.createButton('<<', [0.01 0.09 0.1 0.07], @kera.backAll);
            kera.gui.createButton('>>', [0.36 0.09 0.1 0.07], @kera.forwardAll);
            kera.gui.createText('Total', [0.15 0.23 0.17 0.07]);
            N = length(kera.output);
            labels = cellfun(@num2str,mat2cell((1:N)', ones(1,N)),'UniformOutput',false);
            kera.gui.createDropdown('Jump to Row', labels, [0.185 0.002 0.15 0.07], @kera.jumpToRow);
%             kera.gui.createButton('Generate Fits', [0.4 0.15 0.15 0.05], @kera.generateFits); 
        end

        %the disable/enable on each button is because if you hit the button
        %twice in quick succession the histogram function can run twice
        %without clearing and this can also cause the program to freeze
        function backOne(kera, hObject, ~, ~)
            disable(kera.gui, hObject.String);
            if kera.histogramRow > 1
                kera.histogramRow = kera.histogramRow - 1;
            end
            try
                kera.histogramData();
                kera.createTransitionVisual();
            catch
            end
            enable(kera.gui, hObject.String);
        end
        
        function backAll(kera, hObject, ~, ~)
            disable(kera.gui, hObject.String);
            kera.histogramRow = 1;
            try
                kera.histogramData();
                kera.createTransitionVisual();
            catch
            end
            enable(kera.gui, hObject.String);
        end
        
        function forwardOne(kera, hObject, ~, ~)
            disable(kera.gui, hObject.String);
            if kera.histogramRow<length(kera.output)
                kera.histogramRow = kera.histogramRow + 1;
            end
            try
                kera.histogramData();
                kera.createTransitionVisual();
            catch
            end
            enable(kera.gui, hObject.String);
        end
        
        function forwardAll(kera, hObject, ~, ~)
            disable(kera.gui, hObject.String);
            kera.histogramRow = length(kera.output);
            try
                kera.histogramData();
                kera.createTransitionVisual();
            catch
            end
            enable(kera.gui, hObject.String);
        end
        
        function jumpToRow(kera, ~, ~, ~)
            kera.histogramRow = get(kera.gui.elements('Jump to Row'), 'Value');
            kera.histogramData();
            kera.createTransitionVisual();
        end

        function dwellSelectionChange(kera, ~, ~, ~)
            kera.histogramData();
            kera.createTransitionVisual();
        end
        
        function opencftool(kera,~,~,~)
            if ~isempty(kera.dataDisplayed)
                cftool(kera.dataDisplayed(:,1),kera.dataDisplayed(:,2));
                assignin('base','cftool_x',kera.dataDisplayed(:,1));
                assignin('base','cftool_y',kera.dataDisplayed(:,2));
            end
        end
        
        
        function histogramData(kera, hObject, eventData, handles)
            %refreshes the Kera window; a variety of GUI elements can
            %trigger this, which is why it is so messy.  It is the most
            %likely function to break or malfunction
            kera.gui.resetError();

            kera.dataType = get(kera.gui.elements('dataType'), 'Value');
            kera.fitType = get(kera.gui.elements('fitType'), 'Value');
            kera.order = get(kera.gui.elements('order'), 'Value');
            if ~isempty(kera.output(kera.histogramRow).excel)
                kera.dwellSelection = get(kera.gui.elements('dwellSelection'), 'Value');
            end
            
            set(kera.gui.elements('Jump to Row'), 'Value',kera.histogramRow);
            %needs to be done every time we change rows
            
            if kera.dwellSelectionOn %see kera.toggleDwellSelection.  This is turned off by default
                if ~isempty(kera.output(kera.histogramRow).excel)
                    enable(kera.gui,'dwellSelection');
                    labels = cell([size(kera.output(kera.histogramRow).excel,2)-1 1]);
                    labels{1} = 'All';
                    for i = 1:(size(kera.output(kera.histogramRow).excel,2)-2)
                        labels{i+1} = num2str(i);
                    end
                    set(kera.gui.elements('dwellSelection'),'String',labels);
                    set(kera.gui.elements('dwellSelection'),'Value',min(kera.dwellSelection,length(labels)));
                    kera.dwellSelection = get(kera.gui.elements('dwellSelection'), 'Value');
                else
                    disable(kera.gui,'dwellSelection');
                    set(kera.gui.elements('dwellSelection'),'Value',1);
                    set(kera.gui.elements('dwellSelection'),'String',{'All'});
                    kera.dwellSelection = 1;
                end
            end
            
            %update text on the GUI:
            set(kera.gui.elements('Row: 1'), 'String', ['Row: ' num2str(kera.histogramRow)]);
            row = kera.histogramRow;
            set(kera.gui.elements('Total'), 'String', ['Total: ' int2str(kera.output(kera.histogramRow).count)]);

            if kera.dwellSelection == 1 || ~kera.dwellSelectionOn %the default
                outdata = kera.output(row).timeLengths;
            else %if dwellSelection is turned on and not equal to 1, pick out specific transition
                outdata = kera.output(row).excel(:,kera.dwellSelection);
            end
            hold on;
            if isempty(kera.h1)
                kera.h1 = subplot('Position', [0.05 0.35 0.4 0.45]); 
            end
            cla(kera.h1);
            if kera.fitType == 2
                outdata(outdata<=0) = [];
                outdata = log(outdata);
            end
%             kera.dataDisplayed = outdata;
            switch kera.dataType
                case 1
                    kera.Histogram = histogram(kera.h1,outdata);
                    xData = (kera.Histogram.BinEdges(1:end-1)+kera.Histogram.BinEdges(1:end-1))/2;
                    yData = kera.Histogram.Values;
                    kera.dataDisplayed = cat(2,reshape(xData,[],1),reshape(yData,[],1));
                case 2
                    xData = sort(outdata);
                    yData = linspace(1/length(outdata),1,length(outdata));
                    kera.Histogram = plot(kera.h1,xData,yData);
                    if kera.fitType == 1
                        yData = linspace(1,1/length(outdata),length(outdata)); 
                        %it's easier to fit linear CDF when it is flipped
                        %to the CCDF
                    end
                    kera.dataDisplayed = cat(2,reshape(xData,[],1),reshape(yData,[],1));
            end
            try
                kera.generateFits();
%                 disp(outText);
            catch
            end
        end
        
        function generateFits(kera, ~, ~, ~)
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
            if kera.dwellSelection == 1 %the default
                out.data = kera.output(row).timeLengths;
            else %if dwellSelection is turned on and not equal to 1, pick out specific transition
                out.data = kera.output(row).excel(:,kera.dwellSelection);
            end

            delete(kera.histogramFit);
%             hold on;
%             out.handle = gcf;
            if isempty(kera.h2)
                kera.h2 = subplot('Position', [0.55 0.35 0.4 0.45]);
            end
            cla(kera.h2);
            try
                [fitModel, rateText, out.data] = getFitHistogram(out.data,out.dataType,out.fitType,out.order, kera.timeInterval);
                assignin('base','fitModel',fitModel);
                xList = linspace(min(out.data),max(out.data),500);
                yList = fitModel(xList);
                kera.histogramFit = plot(kera.h2, xList, yList);
                text(kera.h2, mean(xList),range(yList)*0.7,rateText);
            catch err
                kera.histogramFit = plot(kera.h2,[0 0],[0 0]);
                if strcmp(err.identifier, ('curvefit:fit:InsufficientData'))...
                        || strcmp(err.identifier, ('MATLAB:histcounts:expectedPositive'))
                    disp('Fitting failed due to insufficient data');
                else
                    rethrow(err);
                end
            end
           
        end
        
        function createTransitionVisual(kera,~,~,~)
            %create the visual at the top of the Kera window
            if isempty(kera.h3)
                kera.h3 = subplot('Position', [0.05 0.85 0.9 0.1]);
            end
            cla(kera.h3);
            set(kera.h3, 'ColorOrderIndex', 1);
            row = kera.histogramRow;
            if kera.output(row).searchMatrix(1)~= -1 %the row was created with the normal search method
                [xList, yList] = visualizeTransition(kera.output(row).searchMatrix,kera.channels);
            else %rarely used: the regex search function was used (this is an advanced feature)
                xList = [NaN 0   5   NaN NaN];
                yList = [NaN NaN NaN 0   1  ];
                text(kera.h3,2.5, 0.5 ,kera.output(row).expr,'FontSize',25,'HorizontalAlignment','center','Interpreter','none');
            end
            for j = 2:size(yList,2)
                yList(:,j) = yList(:,j)+.05*j; %make them easier to tell apart
            end
            if kera.dwellSelectionOn
                if kera.dwellSelection == 1
                    rectangle(kera.h3,'Position',[2 0 xList(end-1)-2 max(yList(isfinite(yList)),[],'all')],'FaceColor',[1 1 .7],'LineStyle','none');
                else
                    rectangle(kera.h3,'Position',[kera.dwellSelection 0 1 max(yList,[],'all')],'FaceColor',[1 1 .7],'LineStyle','none');
                end
            end
            hold(kera.h3,'on');
            kera.visualizeTrans = plot(kera.h3,xList, yList, 'LineWidth', 2);
            yLimCalc = [min(min(yList,0),[],'all')-.2 max(yList(~isnan(mod(yList,1))),[],'all')+.2]; %the mod is there for the handling of "Inf" flags
            ylim(kera.h3,yLimCalc);
            xlim(kera.h3,[min(xList,[],'all') max(xList,[],'all')]);
            for yInf = find(diff((sum(yList,2)==Inf)')==1)+1
                text(kera.h3,xList(yInf,1)+.5, mean(get(kera.h3,'YLim')),'...','FontSize',30,'HorizontalAlignment','center');
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
        %that you have to run the default analysis again to update the
        %results
        
        function setTimeStep(kera,~,~,~)
            timeIntervalCell = inputdlg('Please enter the time interval, in seconds, between data points');
            kera.timeInterval = eval(timeIntervalCell{1});
        end
        
        function setBaselineState(kera, ~, ~, ~)
            kera.baseState = stateSetUi(kera.channels, kera.stateList);
        end
        
        function toggleDwellSelection(kera, ~, ~, ~)
            %get kinetic event information for just a single transition
            %within a multi-transition event.
            %kind of niche, since most of the time you can just do a
            %3-state custom search and isolate the state you're interested
            %in with the transitions before and/or after it.  On the other
            %hand, kinetic information for the *whole* of a long event is
            %not particularly useful, so maybe it makes sense to allow the user
            %to access each state of it individually.
            kera.dwellSelectionOn = ~kera.dwellSelectionOn;
            if kera.dwellSelectionOn
                set(kera.gui.elements('dwellSelection'), 'Visible', 'on');
                kera.histogramData(); %refresh the screen
                kera.createTransitionVisual();
            else
                set(kera.gui.elements('dwellSelection'), 'Visible', 'off');
                kera.dwellSelection = 1;
                kera.histogramData(); %refresh the screen
                kera.createTransitionVisual();
            end
        end
            
        function nameWindow(kera, ~, ~, ~)
            namestr = inputdlg('Enter name for the figure window');
            set(kera.gui.guiWindow,'Name',namestr{1});
        end
        
        function updateOldFile(kera, ~, ~, ~) 
            updatedAnything = 0;
            mostRecentVersion = '2.9.9';
            
            %when KERA is updated, new properties, fields, or GUI elements
            %might be added.  While they should go into their respective
            %setup functions, a check for these new features should also be
            %added here so that a user who opens a Kera created before the
            %change can "update" it to have those properties added to the
            %existing file.  Each entry should look something like this:
            
            % if (kera doesn't have this thing)
                % add that thing to this kera
                % updatedAnything = 1;
                % mostRecentVersion = new version number
            % end
            
            %example: before version 3.0.0, the kera menu did not
            %inluce the "Name Window" option
            
            if ~isKey(kera.gui.elements,'Name Window')
                kera.gui.createSecondaryMenu('Settings','Name Window', @kera.nameWindow);
                mostRecentVersion = '3.0.0';
                updatedAnything = 1;
            end
            
            
            %Pre-initilized properties, fields of properties, and GUI elements
            %(menu items, buttons, etc.) should be added hdere.  Methods do
            %not need to be added here, since kera objects access all code
            %in the main body of Kera.m.  Mainly, add things that get
            %initialized and would cause an error if the code tries to do
            %something with them on a kera version where that thing doesn't
            %exist
            
            
            if updatedAnything
                disp(['Features added; updated to version ' mostRecentVersion]);
                kera.versionNumber = mostRecentVersion;
            else
                disp('Nothing to update');
            end
        end
    end
end
