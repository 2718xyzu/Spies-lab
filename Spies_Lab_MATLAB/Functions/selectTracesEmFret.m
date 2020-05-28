function [baseline, trim, selection] = selectTracesEmFret(c,intensity,selectionAll, fileNames)
    channels = length(intensity); %number of channels in the data
    N = length(intensity{c}); %number of traces; assumes a cell input    
    selection = ones([N 1],'logical');
    YN = questdlg(['Would you like to view and select traces?  This is recommended ',...
        'to allow you to trim the trace (removing photobleaching), and also'...
        ' to select any portions of the trace which exhibit photoblinking'...
        ' (if there is any; defining baseline values for each trace in this way is optional, but '...
        'useful if there is a lot of photoblinking going on)']);
    %the method uses the selected photoblinking regions to train the
    %model, and trimming to remove photobleaching regions is preferable
    %to suppress low-state identification
    if YN(1) == 'Y'
        baseline = zeros([N 2]);
        trim = zeros([N 2]);
        i = 1;
        while i <= N
            helpText = '';
            if ~selectionAll(i)
%                 helpText = '(Has been removed from final set)';
                %If, for whatever reason, a trace has been excluded, it
                %might be nice for the user to know that so they don't
                %waste time trimming it. 
            end
            figure('Units', 'Normalized','Position',[.05 .4 .9 .5]);
            plot(intensity{c}{i}); %show the trace of the current channel
            yyaxis right
            hold on;
            for j = setdiff(1:channels, c)
                plot(intensity{j}{i},':');
                %plot the other corresponding traces, but make them dashed;
                %this is to emphasize that any baseline selected for this
                %trace only applies to the channel currently being viewed.
                %However, any trimming will apply to all channels at once,
                %so it makes sense to show all of them to guide the
                %trimming decision
            end
            xlabel('Time points');
            trim(i,:) = [1 length(intensity{c}{i})];
            title([fileNames{i} newline helpText]);
            output = newEmFretUi; %display the buttons, wait until one is pushed
            if output.Value == 1
                selection(i) = 0; %Trace discarded
                selectionAll(i) = 0;
            elseif output.Value == 2 || output.Value == 0 %Trace and baseline and/or trim saved
                %Whether we are moving to the next trace (2) or the
                %previous trace (0) we need to potentially save the user's
                %selection on the current trace:
                if isfield(output,'trim')
                    %Each trace may only have one contiguous trimmed region
                    trim(i,:) = [output.trim(1),min(output.trim(2),length(intensity{c}{i}))];
                    %                 intensity{i} = intensity2{i}(output.trim(1):output.trim(2));
                end
                if isfield(output,'baseline') %if baseline selected (photoblinking)
                    %each trace may only have one region of baseline selected
                    %(subsequent selections from the same trace will overwrite
                    %this selection)
                    baseline(i,:) = output.baseline;
                    baseline(i,:) = min(trim(i,2),baseline(i,:));
                    baseline(i,:) = max(0,baseline(i,:)-trim(i,1))+1;
                    if range(baseline(i,:))<5
                        baseline(i,:) = [0 0]; %if baseline is too short
                        disp(['Ensure that baseline selections are contained'...
                            'within trimmed region, and that they are long enough. '...
                            'Or, if the baseline occurs at the edge of a trace, just trim it off']);
                    end
                end
            end
            if output.Value == 0 %move to the previous trace
                if i>1
                    i = i-1;
                end
            else
                i = i+1;
            end
            if output.Value == 6
                YN = questdlg(['Do you want to exit and stop analysis, or do you'...
                    ' want to have the other traces in this set simply be accepted untrimmed with no '...
                    'baseline selected?'],'Exit option','Exit program','Accept all and move on', 'Exit program');
                %The above is shown since closing the figure window
                %is easier than manually clicking 'Next trace' many
                %times
                %Alternatively, closing the figure window should have
                %the option of exiting the program.
                if YN(1)=='E'
                    trim = []; %Signal to parent function that analysis was incomplete
                    return
                else
                    break %All further traces are selected untrimmed and with no baseline
                end
            end
        end
        %         intensity = intensity(selection); %remove unselected intensities
        %         baseline = baseline(selection,:);
        %         emFret = smoothNormalize(intensity,baseline); %normalize traces
    elseif YN(1) == 'N' %normalize without viewing
        baseline = [];
        trim = zeros(length(intensity),2);
        for i = 1:N
            trim(i,:) = [1 length(intensity{c}{i})];
        end
    else %initial prompt closed without responding
        trim = [];
        return
    end
end
