function [baseline, trim, selection] = selectTracesEmFret(intensity,selectionAll)
selection = ones(length(intensity),1,'logical');
N = length(intensity); %number of traces; assumes a cell input
    YN = questdlg(['Would you like to view and select traces?  This is recommended ',...
        'to allow you to trim the trace (removing photobleaching), and also'...
        ' to select any portions of the trace which exhibit photoblinking'...
        ' (if there is any; defining baseline values for each trace in this way is optional, but '...
        'useful if there is a lot of photoblinking going on)']);
        %the method uses the selected photoblinking regions to train the
        %model, and trimming to remove photobleaching regions is preferable
        %to suppress low-state identification
    if YN(1) == 'Y'
        baseline = zeros(length(intensity),2); 
        trim = zeros(length(intensity),2);
%         intensity2 = intensity;
        for i = 1:length(intensity)
            if ~selectionAll(i)
                helpText = '(Has been removed from final set)';
            end
            figure();
            plot(intensity{i}); %show the trace
            xlabel('Time points');
            trim(i,:) = [1 length(intensity{i})];
            title(['Trace ' num2str(i) '\n' helpText]);
            output = newEmFretUi; %display the buttons, wait until one is pushed
            if isfield(output,'baseline') %if baseline selected (photoblinking)
                %each trace may only have one region of baseline selected
                %(subsequent selections from the same trace will overwrite
                %this selection)
                baseline(i,:) = round(output.baseline);
            end
            if isfield(output,'trim')
                %Each trace may only have one contiguous trimmed region
                trim(i,:) = [output.trim(1),min(output.trim(2),length(intensity{i}))];
%                 intensity{i} = intensity2{i}(output.trim(1):output.trim(2));
            end
            switch output.Value
                case 1
                    selection(i) = 0; %Trace discarded
                    clear currentTrim;
                    continue
                case 2 %Trace and baseline and/or trim saved
                    try %Reformat baseline selection based on trimming
                        baseline(i,:) = min(currentTrim(2),baseline(i,:));
                        baseline(i,:) = max(0,baseline(i,:)-currentTrim(1))+1;
                        if baseline(i,2)-baseline(i,1)<5
                            baseline(i,:) = [0 0]; %if baseline is too short
                            disp(['Ensure that baseline selections are contained'...
                                'within trimmed region, and that they are long enough']);
                        end
                        clear currentTrim;
                    catch
                    end
                    continue;
                case 6
                    YN = questdlg(['Do you want to exit and stop analysis, or do you'...
                        ' want to have the other traces in this set simply be accepted untrimmed with no '...
                        'baseline selected?'],'Exit option','No; exit program','Yes', 'No; exit program');
                    %The above is shown since closing the figure window
                    %is easier than manually clicking 'Next trace' many
                    %times
                    %Alternatively, closing the figure window should have
                    %the option of exiting the program.
                    if YN(1)=='N'
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
            trim(i,:) = [1 length(intensity{i})];
        end
    else %initial prompt closed without responding
        trim = [];
        return
    end
end
