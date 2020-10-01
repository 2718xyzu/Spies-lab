function saveEmFret(emFret,channel, fileNames)

    %called by newChangeToebFRET for the purpose of saving the
    %newly-normalized trace data to a format which can be imported to
    %ebFRET or HaMMY


    formatStrings = {'ebFRET', 'HaMMY','hFRET'};
    [format, tf] = listdlg('ListString',formatStrings,'PromptString','Select export format(s)');
    if ~tf || ~any(logical(format))
        disp('No file types selected; save aborted.')
    end
    
    if any(format==2)
        timeStr = inputdlg('Please enter the frame rate of data in seconds (i.e. 0.1)');
        timeUnit = str2double(timeStr);
    end
    
    if any(format==3)
        fillerValue = inputdlg(['Please enter the numerical value you would like to pad all'...
            ' trajectories with so they are the same length']);
        fillerValue = str2double(fillerValue);
        hFRETmat = zeros([1 length(emFret)]);
        lengthVector = zeros([1 length(emFret)]);
    end
    
    
    for j = format
    [~] = questdlg(['Please select a directory (or make a new one) in which to save traces in channel ',...
        num2str(channel) 'in the ' formatStrings{j} ' format'], 'Select Directory','Ok','Ok');
    saveDir = uigetdir;
    if ~isfolder(saveDir)
        errordlg('Directory not found.  Using default directory');
        saveDir = [];
    end
    for i = 1:length(emFret)
        traceA = emFret{i};
        traceD = 1-traceA;
        switch j
            case 1
                saveMatrix = vertcat(traceD,traceA)';
                save(([saveDir filesep regexprep(fileNames{i},'.dat','') '_eb_c' num2str(channel) '.dat']),'saveMatrix','-ascii');
            case 2
                timeVector = 0:timeUnit:((length(traceD)-1)*timeUnit);
                saveMatrix = vertcat(timeVector, traceD, traceA)';
                save(([saveDir filesep regexprep(fileNames{i},'.dat','') '_ha_c' num2str(channel) '.dat']),'saveMatrix','-ascii');
            case 3
                lengthVector(i) = length(traceA);
                hFRETmat(1:lengthVector(i),i) = traceA;
        end
        
    end
    
    if any(format==3)
        for i = 1:length(emFret)
            hFRETmat((lengthVector(i)+1):end,i) = fillerValue;
        end
        save(([saveDir filesep 'traces_hF_c' num2str(channel) '.dat']),'hFRETmat','-ascii');
    end
    
    end
end