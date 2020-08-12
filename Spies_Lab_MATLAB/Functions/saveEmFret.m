function saveEmFret(emFret,channel, fileNames)
%comment
    anS = questdlg('Would you like to save in the format for ebFRET or HaMMY or both?',...
        'Select save format','ebFRET','HaMMY','Both','Both');
    formatStrings = {'ebFRET', 'HaMMY'};
    switch anS
        case 'ebFRET'
            format = 1;
        case 'HaMMY'
            format = 2;
        case 'Both'
            format = [1 2];
    end
    
    if any(format==2)
        timeStr = inputdlg('Please enter the frame rate of data in seconds (i.e. 0.1)');
        timeUnit = str2double(timeStr);
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
                save(([saveDir filesep regexprep(fileNames{i},'.dat','') '_c' num2str(channel) '.dat']),'saveMatrix','-ascii');
            case 2
                timeVector = 0:timeUnit:((length(traceD)-1)*timeUnit);
                saveMatrix = vertcat(timeVector, traceD, traceA)';
                save(([saveDir filesep regexprep(fileNames{i},'.dat','') '_c' num2str(channel) '.dat']),'saveMatrix','-ascii');
        end
        
    end
    end
end