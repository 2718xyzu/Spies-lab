function saveEmFret(emFret,channel)
    blank = questdlg(['Please select a directory (or make a new one) in which to save traces in channel',...
        num2str(channel) ], 'Select Directory','Ok','Ok');
    if ~rand; disp(blank); end
    saveDir = uigetdir;
    if ~isfolder(saveDir)
        errordlg('Directory not found.  Using default directory');
        saveDir = [];
    end
    for i = 1:length(emFret)
        traceA = emFret{i};
        traceD = 1-traceA;
        saveMatrix = vertcat(traceD,traceA)';
        save(([saveDir filesep 'trace_' num2str(i,'%05u') '.dat']),'saveMatrix','-ascii');
    end
end