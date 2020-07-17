function [dataCellEdited, selection] = plotdisplayKera(dataCell, dataCellEdited, fileNames, timeInterval, selection)
%a function called when the user clicks the "view data" button

maxStates = getMaxStates(dataCellEdited);
N = size(dataCell,1);
if isempty(selection)
    selection = ones([N 1],'logical');
end
channels = size(dataCellEdited,2);
thresholded = 0;
i = 1;
% while i <= N
rawAvailable = 0; %becomes 1 if a trace has raw data in addition to the discrete data
figure('Units', 'Normalized','Position',[.05 .4 .9 .5],'MenuBar','none','ToolBar','none');
ax = axes;
ax1 = cell([1 1]); %to hold the plots themselves and obtain brushing information
brushing = {};
dataCellBeforeLastThreshold = {};
hold on;
handles = struct;
handles.btn = uicontrol('Style', 'pushbutton', 'String', 'Discard trace',...
    'Position', [20 5 100 20],...
    'UserData', 1,'Callback', @buttonCallback1);

handles.btn2 = uicontrol('Style', 'pushbutton', 'String', 'Next trace',...
    'Position', [130 5 90 20],...
    'UserData',  2, 'Callback', @buttonCallback2);

dDownString = cell([N 1]);
for trace = 1:N
    dDownString{trace} = num2str(trace);
end

handles.btn3 = uicontrol('Style', 'popupmenu', 'String', dDownString,...
    'Position', [230 5 90 20],...
    'UserData', 3,'Callback', @dDownCallback);
set(handles.btn3,'Value',i);

%     handles.btn4 = uicontrol('Style', 'pushbutton', 'String', 'Auto Deadtime',...
%         'Position', [330 5 110 20],...
%         'UserData', 4, 'Callback', @buttonCallback);
%
handles.btn5 = uicontrol('Style', 'pushbutton', 'String', 'Manual assign',...
    'Position', [450 5 110 20],...
    'UserData', 5, 'Callback', @buttonCallback5);

handles.btn6 = uicontrol('Style', 'pushbutton', 'String', 'Reset',...
    'Position', [570 5 80 20],...
    'UserData', 7, 'Callback', @buttonCallback7);

handles.btn7 = uicontrol('Style', 'pushbutton', 'String', 'Threshold',...
    'Position', [330 5 95 20],...
    'UserData', 9, 'Callback', @buttonCallback9, 'Visible', 'off');


handles.btn8 = uicontrol('Style', 'pushbutton', 'String', 'Undo Threshold',...
    'Position', [765 5 120 20],...
    'UserData', 10, 'Callback', @buttonCallback10,'Visible', 'off');


handles.btn9 = uicontrol('Style', 'pushbutton', 'String', 'Reset All',...
    'Position', [895 5 100 20],...
    'UserData', 11, 'Callback', @buttonCallback11);

handles.btn10 = uicontrol('Style', 'pushbutton', 'String', 'Save & Exit',...
    'Position', [1005 5 105 20],...
    'UserData', 12, 'Callback', @buttonCallback12);

renderPlots();
uiwait;
return

    function renderPlots()
        set(handles.btn3,'Value',i);
        cla(ax);
        if thresholded
            set(handles.btn8,'Visible','on');
        else
            set(handles.btn8,'Visible','off');
        end
        helptext = '';
        if ~selection(i)
            helptext = 'Currently deselected; click "reset" to re-select';
        end
        title([fileNames{i} newline helptext]);
        shift = 0;
        legendList = cell([1 2*channels]);
        l = 1;
        meanState = cell([1 channels]);
        ax1 = cell([1 1]);
        for j = 1:channels
            n = length(dataCellEdited{i,j,1});
            color1 = ax.ColorOrder(ax.ColorOrderIndex, :);
            meanState{j} = 1:max(dataCellEdited{i,j,2});
            if n>0
                rawAvailable = 1;
                for state = 1:max(dataCellEdited{i,j,2})
                    meanState{j}(state) = mean(dataCellEdited{i,j,1}(dataCellEdited{i,j,2}==state)); %need to change this if 0 or negative state id's are ever allowed
                end
                plot(((1:n)*timeInterval)-timeInterval,dataCellEdited{i,j,1}+shift);
                legendList(l) = {['Channel ' num2str(j) ' raw']};
                l=l+1;
            else
                n = length(dataCellEdited{i,j,2});
            end
            if rawAvailable
                set(handles.btn7,'Visible', 'on');
            else
                set(handles.btn7,'Visible', 'off');
            end 
            ax1{j} = plot(((1:n)*timeInterval)-timeInterval,meanState{j}(dataCellEdited{i,j,2})+shift,'o','Color',color1);
            for i0 = unique(dataCellEdited{i,j,2})'
                text(ax,(1+.05*j)*n*timeInterval,meanState{j}(i0)+shift,num2str(i0),'Color',color1,'FontSize',16);
            end
            legendList(l) = {['Channel ' num2str(j) ' discrete']};
            l=l+1;
            if ~rawAvailable
                shift = shift+0.1;
            end
        end
        legendList = legendList(1:(l-1));
        legend(legendList);
        
    end


%     output = KeraSelectUi(ax1,rawAvailable, thresholded, N, i);
%     switch output.Value

    function buttonCallback12(~,~) %close and save
        close(gcf);
        return
    end

%     function buttonCallback4(~,~)
%             handleClose = gcf;
%             anS = inputdlg(['Please enter an integer number of frames; all'...
%                 ' events of this length or less will be snapped to'...
%                 ' a nearby state']);
%             try
%                 deadFrames = str2double(anS{:}); %if the user closes without answering
%                 assert(round(deadFrames)==deadFrames) %or gives something not an integer
%             catch
%                 deadFrames = 0; %signal to not do the deadTime thing
%             end
%             close(handleClose);
%             for j = 1:channels
%                 dataCellEdited{i,j,2} = autoDeadTime(dataCellEdited{i,j,1}, dataCellEdited{i,j,2}, deadFrames);
%             end
%             maxStates = getMaxStates(dataCellEdited);
%     end

    function buttonCallback5(~,~) %brushing the data
        brush;
        set(handles.btn,'enable','off'); %disable some buttons:
        set(handles.btn2,'enable','off');
        set(handles.btn3,'enable','off');
%         set(handles.btn4,'enable','off');
        set(handles.btn7,'enable','off');
        set(handles.btn8,'enable','off');
        set(handles.btn5,'Callback',@buttonCallback0); %change the appreance and behavior of two buttons:
        set(handles.btn5,'String','Assign Brushed');
        set(handles.btn6,'Callback',@buttonCallback8);
        set(handles.btn6,'String','Cancel');
    end

    function buttonCallback8(~,~) %brushing canceled
        for j = 1:length(ax1)
            brushing{j} = [];
            set(ax1{j},'BrushData',[]);
        end
        set(handles.btn,'enable','on'); %enable some buttons:
        set(handles.btn2,'enable','on');
        set(handles.btn3,'enable','on');
%         set(handles.btn4,'enable','on');
        set(handles.btn7,'enable','on');
        set(handles.btn8,'enable','on');
        set(handles.btn5,'Callback',@buttonCallback5); %change the appreance and behavior of two buttons:
        set(handles.btn5,'String','Manual Set');
        set(handles.btn6,'Callback',@buttonCallback7);
        set(handles.btn6,'String','Reset');
        brush off
    end

    function buttonCallback1(~,~) %discard and next
        selection(i) = 0;
        i = i+1;
        renderPlots();
    end

    function buttonCallback2(~,~) %next trace
        i = i+1; %go to next trace
        renderPlots();
    end

    function dDownCallback(~,~)
        i = get(handles.btn3, 'Value');
        %go to specified trace
        renderPlots();
    end

    function buttonCallback7(~,~) %reset everything back to how it was
        for j = 1:channels
            dataCellEdited(i,j,2) = dataCell(i,j,2);
        end
        selection(i) = 1;
        renderPlots();
    end

    function buttonCallback0(~,~) %brushed some data
        brushing = cell([length(ax1) 1]);
        for j = 1:length(ax1)
            brushing{j} = get(ax1{j}, 'BrushData');
        end
        
        try
            assert(sum(cat(2,brushing{:}))>0);
        catch
            [~] = questdlg('No data selected; drag the brush tool to select data','Brushing help','Ok','Ok');
            buttonCallback8();
            renderPlots();
            return
        end
        if channels>1
            channelEdit = inputdlg('Which channel are you editing?');
            try
                channelEdit = str2double(channelEdit{:}); %if the user closes without answering
                assert(round(channelEdit)==channelEdit) %or gives something not an integer?
                assert(channelEdit<=size(dataCellEdited,2)); %or something which is not a valid channel
            catch
                buttonCallback8();
                renderPlots();
                return %skip it and re-open the trace
            end
        else
            channelEdit = 1;
        end
        stateEdit = inputdlg(['Which state would you like to assign' ...
            ' selected points to?  The current maximum state in the'...
            ' channel is ' num2str(maxStates(channelEdit)) ]);
        try
            stateEdit = str2double(stateEdit{:}); %if the user closes without answering
            assert(round(stateEdit)==stateEdit) %or gives something not an integer?
            
            assert(length(brushing{channelEdit})==length(dataCellEdited{i,channelEdit,2}));
            dataCellEdited{i,channelEdit,2}(logical(brushing{channelEdit})) = stateEdit;
            maxStates = getMaxStates(dataCellEdited);
        catch
            %don't edit the data if one of the above tests does not pass
        end
        buttonCallback8();
        renderPlots();
    end

    function buttonCallback9(~,~) %thresholding
        maxStates = getMaxStates(dataCellEdited);
        histVal = cell([channels max(maxStates) 2]);
        edgeVal = cell([channels max(maxStates) 2]);
        for j = 1:channels
            normalizedTraces = cellfun(@(x) (x-prctile(x,1))/(prctile(x,99)-prctile(x,1)), dataCellEdited(:,j,1),'UniformOutput',false);
            bigRawMat = cell2mat(dataCellEdited(selection,j,1));
            bigDiscMat = cell2mat(dataCellEdited(selection,j,2));
            bigNormalizedMat = cell2mat(normalizedTraces);
            for i0 = 1:maxStates(j)
                [histVal{j,i0,1}, edgeVal{j,i0,1}] = histcounts(bigRawMat(bigDiscMat==i0),ceil(sqrt(nnz(bigDiscMat==i0))),'Normalization','countdensity');
                [histVal{j,i0,2}, edgeVal{j,i0,2}] = histcounts(bigNormalizedMat(bigDiscMat==i0),ceil(sqrt(nnz(bigDiscMat==i0))),'Normalization','countdensity');
            end %these variables are stored so that less data has to be passed into the app
        end
        clear bigRawMat bigDiscMat bigNormalizedMat normalizedTraces
        %NOTE: a bit of a kludge is being used to assign the following
        %variables:
        threshold = NaN;
        boundDirection = NaN;
        stateSet = NaN;
        channel = NaN;
        states2Set = NaN;
        method = NaN;
        %the app designer platform does not currently support output
        %variables.  If it ever does, PLEASE fix this to set the above
        %three variables using a more elegant syntax.
        app = tresholdingKeraTraces(histVal, edgeVal, channels, maxStates);
        pause(1); %I'm sorry
        while isvalid(app)
            threshold = app.threshold;
            stateSet = app.stateSet;
            boundDirection = app.boundDirection;
            channel = app.channel;
            states2Set = app.state2ChangeFrom;
            method = app.method;
            pause(0.05);
        end
        %the three variables should be set now, if the app
        %has executed and exited properly
        if isnan(threshold) || stateSet == 0
            %Something prevented the variables from being set
            renderPlots();
            %don't change the data
        else
            dataCellBeforeLastThreshold = dataCellEdited; %thresholding needs a quick 'undo' button
            dataCellEdited = setThresholdingOnPlotCell(threshold, stateSet, boundDirection, channel, method, states2Set, dataCellEdited);
            thresholded = 1;
            renderPlots();
        end
    end

    function buttonCallback10(~,~)
        dataCellEdited = dataCellBeforeLastThreshold; %undo that thresholding
        renderPlots();
    end

    function buttonCallback11(~,~)
        dataCellEdited = dataCell; %the big reset button
        renderPlots();
    end


    function maxStates = getMaxStates(plotCell)
        maxStates = zeros([1 size(plotCell,2)]);
        for j1 = 1:size(plotCell,2)
            for i1 = 1:size(plotCell,1)
                maxStates(j1) = max([maxStates(j1); plotCell{i1,j1,2}]);
            end
        end
        
    end




end