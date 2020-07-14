function [dataCellEdited] = plotdisplayKera(dataCell, dataCellEdited, fileNames, timeInterval)
%a function called when the user clicks the "view data" button

maxStates = getMaxStates(dataCellEdited);
N = size(dataCell,1);
selection = ones([1 N],'logical');
channels = size(dataCellEdited,2);
thresholded = 0;
i = 1;
while i <= N
    rawAvailable = 0; %becomes 1 if a trace has raw data in addition to the discrete data
    figure('Units', 'Normalized','Position',[.05 .4 .9 .5]);
    ax = axes;
    hold on;
    helptext = '';
    if ~selection(i)
        helptext = 'Currently deselected';
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
        ax1{j}=plot(((1:n)*timeInterval)-timeInterval,meanState{j}(dataCellEdited{i,j,2})+shift,'o','Color',color1);
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
    output = KeraSelectUi(ax1,rawAvailable, thresholded);
    switch output.Value
        
        case 6 %closed without selecting anything (probably want to get out)
            return
        case 4 
            for j = 1:channels
                dataCellEdited{i,j,2} = autoDeadTime(dataCellEdited{i,j,1}, dataCellEdited{i,j,2}, output.deadFrames);
            end
            maxStates = getMaxStates(dataCellEdited);
        case 5 %I guess they closed it while brushing?  
            %In that case do nothing and re-open the trace
        case 8 %same thing
            
        case 1 %discard and next
            selection(i) = 0;
            i = i+1;
        case 2
            i = i+1; %go forward
        case 3
            if i>1
                i = i-1; %go back
            end
        case 7 %reset everything back to how it was
            for j = 1:channels
                dataCellEdited(i,j,2) = dataCell(i,j,2);
            end
            selection(i) = 1;
        case 0 %brushed some data
            try
                assert(sum(cat(2,output.brushing{:}))>0);
            catch
                [~] = questdlg('No data selected; drag the brush tool to select data','Brushing help','Ok','Ok');
                continue
            end
            if channels>1
                channelEdit = inputdlg('Which channel are you editing?');
                try
                    channelEdit = str2double(channelEdit{:}); %if the user closes without answering
                    assert(round(channelEdit)==channelEdit) %or gives something not an integer?
                    assert(channelEdit<=size(dataCellEdited,2)); %or something which is not a valid channel
                catch
                    continue %skip it and re-open the trace
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

                assert(length(output.brushing{channelEdit})==length(dataCellEdited{i,channelEdit,2}));
                dataCellEdited{i,channelEdit,2}(logical(output.brushing{channelEdit})) = stateEdit;
                maxStates = getMaxStates(dataCellEdited);
            catch
                continue %skip it and re-open the trace
            end
        case 9
            maxStates = getMaxStates(dataCellEdited);
            histVal = cell([channels max(maxStates) 2]);
            edgeVal = cell([channels max(maxStates) 2]);
            for j = 1:channels
                normalizedTraces = cellfun(@(x) (x-prctile(x,1))/(prctile(x,99)-prctile(x,1)), dataCellEdited(:,j,1),'UniformOutput',false);
                bigRawMat = cell2mat(dataCellEdited(:,j,1));
                bigDiscMat = cell2mat(dataCellEdited(:,j,2));
                bigNormalizedMat = cell2mat(normalizedTraces);
                for i0 = 1:maxStates(j)
                    [histVal{j,i0,1}, edgeVal{j,i0,1}] = histcounts(bigRawMat(bigDiscMat==i0),ceil(sqrt(nnz(bigDiscMat==i0))),'Normalization','countdensity');
                    [histVal{j,i0,2}, edgeVal{j,i0,2}] = histcounts(bigNormalizedMat(bigDiscMat==i0),ceil(sqrt(nnz(bigDiscMat==i0))),'Normalization','countdensity');
                end %these variables are stored so that less data has to be passed into the app
            end
            clear bigRawMat bigDiscMat bigNormalizedMat normalizedTraces
            %NOTE: assignin is being used to set the following three
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
                method = app.method;
                states2Set = app.state2ChangeFrom;
                pause(0.1);
            end
%             thresholdingKeraTraces_exported(histVal, edgeVal, channels);
            %the three variables should be set now, if the above function
            %has executed properly
            if isnan(threshold) || stateSet == 0
                %Something prevented the variables fransom being set
                continue
            end
            %otherwise
            dataCellBeforeLastThreshold = dataCellEdited; %thresholding needs a quick 'undo' button
            dataCellEdited = setThresholdingOnPlotCell(threshold, stateSet, boundDirection, channel, method, states2Set, dataCellEdited);
            thresholded = 1;
        case 10
            dataCellEdited = dataCellBeforeLastThreshold;
        case 11
            dataCellEdited = dataCell; %the big reset button
            return
    end
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