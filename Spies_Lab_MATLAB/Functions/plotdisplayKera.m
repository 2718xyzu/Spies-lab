function [plotCell2] = plotdisplayKera(plotCell, fileNames, timeInterval)
%a function called when the user clicks the "view data" button
plotCell2 = plotCell; %keep the original plotCell untouched in case we need it again
maxStates = getMaxStates(plotCell);
N = size(plotCell,1);
selection = ones([1 N],'logical');
channels = size(plotCell2,2);
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
    for j = 1:channels
        n = length(plotCell2{i,j,1});
        color1 = ax.ColorOrder(ax.ColorOrderIndex, :);
        meanState{j} = 1:max(plotCell2{i,j,2});
        if n>0
            rawAvailable = 1;
            for state = 1:max(plotCell2{i,j,2})
                meanState{j}(state) = mean(plotCell2{i,j,1}(plotCell2{i,j,2}==state));
            end
            plot(((1:n)*timeInterval)-timeInterval,plotCell2{i,j,1}+shift);
            legendList(l) = {['Channel ' num2str(j) ' raw']};
            l=l+1;
        else
            n = length(plotCell2{i,j,2});
        end
        ax1{j}=plot(((1:n)*timeInterval)-timeInterval,meanState{j}(plotCell2{i,j,2})+shift,'o','Color',color1);
        legendList(l) = {['Channel ' num2str(j) ' discrete']};
        l=l+1;
        shift = shift+0.1;
    end
    legendList = legendList(1:(l-1));
    legend(legendList);
    output = KeraSelectUi(ax1,rawAvailable);
    switch output.Value
        
        case 6 %closed without selecting anything (probably want to get out)
            return
        case 4 
            for j = 1:channels
                plotCell2{i,j,2} = autoDeadTime(plotCell2{i,j,1}, plotCell2{i,j,2}, output.deadFrames);
            end
            maxStates = getMaxStates(plotCell2);
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
                plotCell2(i,j,2) = plotCell(i,j,2);
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
                    assert(channelEdit<=size(plotCell2,2)); %or something which is not a valid channel
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

                assert(length(output.brushing{channelEdit})==length(plotCell2{i,channelEdit,2}));
                plotCell2{i,channelEdit,2}(logical(output.brushing{channelEdit})) = stateEdit;
                maxStates = getMaxStates(plotCell2);
            catch
                continue %skip it and re-open the trace
            end
        case 9
            histVal = cell([channels 2]);
            edgeVal = cell([channels 2]);
            for j = 1:channels
                [histVal{j,1}, edgeVal{j,1}] = histcounts(cell2mat(plotCell(:,j,1)));
                normalizedTraces = cellfun(@(x) (x-prctile(x,1))/(prctile(x,99)-prctile(x,1)), plotCell(:,j,1),'UniformOutput',false);
                [histVal{j,2}, edgeVal{j,2}] = histcounts(cell2mat(normalizedTraces));
            end
            thresholdingKeraTraces_exported(histVal, edgeVal, channels);
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