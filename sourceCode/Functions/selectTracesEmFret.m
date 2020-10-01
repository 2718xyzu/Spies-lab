function [low, high, trim, selection] = selectTracesEmFret(channels,intensity,selectionAll, fileNames, low, high, trim)
    
    %user interface for selecting the baseline, highest state, and possibly
    %trimming each trace

    N = length(intensity{1}); %number of traces; assumes a cell input
    selection = selectionAll;
    YN = questdlg(['Would you like to view and select traces? This is recommended ',...
        'to allow you to trim the trace (removing photobleaching), and also'...
        ' to select any portions of a trace which are low- or high- states.  This'...
        ' helps the normalization process, especially in cases where the accepted'...
        ' region of a trace only has one state.']);
    %the method uses the selected photoblinking regions to train the
    %model, and trimming to remove photobleaching regions is preferable
    %to suppress low-state identification
    warningsOff = 0;

    if YN(1) == 'Y'

        i = 1;
        trimmed = zeros([N 1],'logical');
        lowed = zeros([N channels],'logical');
        highed = zeros([N channels],'logical');
        while i <= N
            c = 1;              %c is indeed iterated in the following loop, but
            while c <= channels %this loop is actually exited by "break" statements, so the condition is somewhat moot
                warnings = {'select a low state', 'select a high state', 'trim the trace'};
                helpText = '';
                if ~selectionAll(i)
                    helpText = '(Has been removed from final set)';
                    %If, for whatever reason, a trace has been excluded, it
                    %might be nice for the user to know that so they don't
                    %waste time trimming it.
                else
                    helpText = ['Channel ' num2str(c)];
                end
                figure('Units', 'Normalized','Position',[.05 .4 .9 .5]);
                plot(intensity{c}{i}); %show the trace of the current channel
                yyaxis right
                hold on;
                for j = setdiff(1:channels, c)
                    plot(intensity{j}{i},':');
                    %plot the other corresponding traces, but make them dashed;
                    %this is to emphasize that any states selected for this
                    %trace only apply to the channel currently being viewed.
                    %However, any trimming will apply to all channels at once,
                    %so it makes sense to show all of them to guide the
                    %trimming decision
                end
                xlabel('Time points');
                trim{c}(i,:) = [1 length(intensity{c}{i})];
                title([fileNames{i} newline helpText]);
                output = newEmFretUi; %display the buttons, wait until one is pushed
                if output.Value == 1
                    selection(i) = 0; %Trace discarded
                    selectionAll(i) = 0;
                elseif output.Value == 2 || output.Value == 0 %Trace and states and/or trim saved
                    %Whether we are moving to the next trace (2) or the
                    %previous trace (0) we need to potentially save the user's
                    %selection on the current trace:
                    if isfield(output,'trim')
                        %Each trace may only have one contiguous trimmed region
                        trim{c}(i,:) = [output.trim(1),min(output.trim(2),length(intensity{c}{i}))];
                        trimmed(i) = 1;
                        %                 intensity{i} = intensity2{i}(output.trim(1):output.trim(2));
                    end
                    if isfield(output,'low') %if low selected (photoblinking)
                        %each trace may only have one region of low selected
                        %(subsequent selections from the same trace will overwrite
                        %this selection)
                        output.low(1) = max(output.low(1),1);
                        output.low(2) = min(output.low(2),length(intensity{c}{i}));
                        low{c}{i} = intensity{c}{i}(output.low(1):output.low(2));
                        lowed(i,j) = 1;
                    end
                    if isfield(output,'high') %if low selected (photoblinking)
                        %each trace may only have one region of low selected
                        %(subsequent selections from the same trace will overwrite
                        %this selection)
                        output.high(1) = max(output.high(1),1);
                        output.high(2) = min(output.high(2),length(intensity{c}{i}));
                        high{c}{i} = intensity{c}{i}(output.high(1):output.high(2));
                        highed(i,j) = 1;
                    end
                end
                if output.Value == 0 %move to the previous trace
                    if i>1
                        i = i-1;
                        break %go back a trace and reset c to 1
                    else
                        c = 1;
                    end
                else
                    warnings = warnings(~logical([lowed(i,j) highed(i,j) trimmed(i)]));
                    if ~isempty(warnings) && ~warningsOff
                        anS = questdlg(['It seems that you forgot to ' strjoin(warnings,' and ') '.'  ...
                            '  Would you like to return to the trace to fix this,'...
                            ' or continue to the next trace with these values not set?']...
                            ,'Analysis warning', 'Return', 'Continue anyway',...
                            'Do not show this again and continue', 'Return');
                        switch anS(1)
                            case 'R'
                                continue %do not iterate c or i
                            case 'C'
                                %do nothing so that we reach the lines which
                                %iterate c and/or i
                            case 'D'
                                warningsOff = 1;
                        end
                    end
                    if c<channels
                        c = c+1; %just increase the channel number
                    else
                        i = i+1; %actually go to the next trace
                        break
                    end
                end
                if output.Value == 6
                    YN = questdlg(['Do you want to exit and stop analysis? Or, do you'...
                        ' want to have the other traces in this set simply be accepted untrimmed with no '...
                        'baseline selected?  Or do you want to discard all traces not yet viewed?'],...
                        'Exit option','Exit program','Accept all and move on','Discard all unviewed and move on', 'Exit program');
                    %The above is shown since closing the figure window
                    %is easier than manually clicking 'Next trace' many
                    %times
                    %Alternatively, closing the figure window should have
                    %the option of exiting the program.
                    if YN(1)=='E'
                        trim = []; %Signal to parent function that analysis was incomplete
                        return
                    else
                        %All further traces are selected untrimmed and with no baseline
                        if YN(1)=='A'
                            for j = i:N
                                trim{c}(j,:) = [1 length(intensity{c}{j})];
                            end
                        else
                            for j = i:N
                                selection(j) = 0;
                            end
                        end
                        return
                    end
                end
            end
        end
        %         intensity = intensity(selection); %remove unselected intensities
        %         baseline = baseline(selection,:);
        %         emFret = smoothNormalize(intensity,baseline); %normalize traces
    elseif YN(1) == 'N' %normalize without viewing

    else %initial prompt closed without responding
        trim = [];
        return
    end
end
