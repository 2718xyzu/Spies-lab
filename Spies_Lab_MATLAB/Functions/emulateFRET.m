function [emFret, selection] = emulateFRET(intensity,selection)
%accepts an Nx1 cell of 1xlength matrices (where length can be different
%for each cell entry)
answer = questdlg('Which method would you like to use?', 'Method', 'Original', 'No baseline shift', 'Advanced', 'Advanced');
if answer(1) == 'O'
    try
        intensity = cell2mat(intensity);
    catch
        error('To use original method, all traces must be same length');
    end
    maxIntensities = prctile(intensity(:),98);
    emFret2 = zeros(size(intensity));
    for i = 1:size(intensity,1)
        emFret2(i,:) = smoothTrace(intensity(i,:)/maxIntensities*.85);
        emFret2(i,:) = min(emFret2(i,:),1);
        oneS = emFret2(i,:)==1;
        noise = -abs(oneS.*randn(size(oneS))*.025);
        emFret2(i,:) = emFret2(i,:)+noise;
    end

    emFret = emFret2;
    answer = questdlg('Would you like to smooth the baseline (recommended to suppress low states)');
    if answer(1) == 'Y'
        valueS = histcounts(emFret,[-Inf 0:.01:1 Inf]);
        [~,maxX] = max(valueS(1:50));
%             gaussFit = 'a*exp(-((x-b)/c)^2)';
        fit1 = fit((-.005:.01:(.01*(maxX+2)+.005))',valueS(1:(maxX+4))','gauss1');
        newBaseLine = fit1.b1+fit1.c1*2;
        emFret = max(emFret,newBaseLine);
        emFret = emFret + rand(size(emFret))*.005;
    end
    answer = questdlg(['Would you like to see the emulated Fret values converted '...
        'back to original levels, for comparison?']);
    if answer(1)=='Y'
        revertedFret = emFret*maxIntensities/.85;
        plotCut2(revertedFret,intensity,length(emFret),.1);
        msgbox('Comparison has been halted; program is terminating before function return (this is normal)');
        endNow = 1;
        assert(~endNow);
    end

elseif answer(1)=='N'
    try
        intensity = cell2mat(intensity);
    catch
        error('To use this method, all traces must be same length');
    end
    baselineSelect = zeros([1,size(intensity,1)]);
    baseline((size(intensity,1))).Values = 0;
    for i = 1:size(intensity,1)
        figure();
        plot(intensity(i,:));
        title(['Trace ' num2str(i)]);
        output = emFretUi;
        if isfield(output,'xValues')
            x = round(output.xValues);
        end
        switch output.Value
            case 10
                continue
            case 6
                break
            case 3
                baselineSelect(i) = 1;
                try
                    baseline(i).Values = intensity(i,x(1):x(2));
                catch
                    baseline(i).Values = intensity(i,x(1):end);
                end
        end     
    end
    emFret = zeros(size(intensity));
    for i = 1:size(intensity,1)
        if ~baselineSelect(i)
            continue
        end
        clear smoothedBase;
        smoothedBase = smoothTrace(baseline(i).Values);
        meaN = mean(smoothedBase);
        stDev = std(smoothedBase);
        atBaseline = diff(smoothTrace(intensity(i,:))<(meaN+2*stDev));
        boundaries = find(atBaseline);
        if length(boundaries)<1
            emFret(i,:) = .85*smoothTrace(intensity(i,:))./prctile(intensity(i,:),98);
            continue
        elseif length(boundaries)==1
            intensity(i,:) = [smoothTrace(intensity(i,1:boundaries)) smoothTrace(intensity(i,(boundaries+1):end))];
            emFret(i,:) = .85*intensity(i,:)./prctile(intensity(i,:),98);
            continue
        end
        intensity(i,1:boundaries(1)) = smoothTrace(intensity(i,1:boundaries(1)));
        for j = 1:length(boundaries)-1
            intensity(i,boundaries(j)+1:boundaries(j+1)) = smoothTrace(intensity(i,boundaries(j)+1:boundaries(j+1)));
        end
        intensity(i,boundaries(end)+1:end) = smoothTrace(intensity(i,boundaries(end)+1:end));
        emFret(i,:) = .85*intensity(i,:)./prctile(intensity(i,:),98);
    end
else %if the advanced method is selected (recommended)
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
        intensity2 = intensity;
        for i = 1:length(intensity)
            if ~selection(i)
                continue
            end
            figure();
            plot(intensity{i}); %show the trace
            currentTrim = [1 length(intensity{i})];
            title(['Trace ' num2str(i)]);
            output = newEmFretUi; %display the buttons, wait until one is pushed
            if isfield(output,'baseline') %if baseline selected (photoblinking)
                %each trace may only have one region of baseline selected
                %(subsequent selections from the same trace will overwrite
                %this selection)
                baseline(i,:) = round(output.baseline);
            end
            if isfield(output,'trim')
                %Each trace may only have one contiguous trimmed region
                currentTrim = [output.trim(1),output.trim(2)];
                intensity{i} = intensity2{i}(output.trim(1):output.trim(2));
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
                        emFret = []; %Signal to parent function that analysis was incomplete
                        return
                    else
                        break %All further traces are selected untrimmed and with no baseline
                    end
            end     
        end
        intensity = intensity(selection); %remove unselected intensities
        baseline = baseline(selection,:);
        emFret = smoothNormalize(intensity,baseline); %normalize traces
    elseif YN(1) == 'N' %normalize without viewing
        emFret = smoothNormalize(intensity);
    else %initial prompt closed without responding
        emFret = [];
        return
    end

end


end
