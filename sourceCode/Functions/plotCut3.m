function plotCut3(matrixID,matrixIA,frames,timeUnit)
saveMode = '2';
QuB = 1;
ebFRET = 1;
modes = {'QuB','ebFRET'};
if saveMode(1) == '2'
    QuB = 0;
    ebFRET = 1;
elseif saveMode(1) == '4'
    QuB = 1;
    ebFRET = 0;
end
for i = 2
    blank = questdlg('Please select a directory (or make a new one) in which to save traces in the format for ebFRET',...
        'Select Directory','Ok','Ok');
    saveDir(i) = {uigetdir};
    saveDir{i} = [saveDir{i} filesep];
    if ~isdir(saveDir{i})
        errordlg('Directory not found.  Using default directory');
        saveDir{i} = [];
    end
end

goOn = 1;
i = 1;
timeSeries = 0:timeUnit:timeUnit*(frames-1);
while i <= size(matrixIA,1) && goOn ~= 6
    try
        assert(~iscell(matrixIA));
        traceD = matrixID(i,:);
        traceA = 1-traceD;
    catch %in case it was passed as a cell array
        traceA = matrixIA{i};
        traceD = 1-traceA;
    end
    traceFret = getFret(traceD,traceA);
    if QuB
        save(([saveDir{1} 'trace_' num2str(i,'%05u') '.dat']),'saveMatrix','-ascii');
        saveMatrix = vertcat(timeSeries,traceD,traceA,traceFret);
        saveMatrix = transpose(saveMatrix);
    end
    if ebFRET
        saveMatrix = vertcat(traceD,traceA);
        saveMatrix = transpose(saveMatrix);
        save(([saveDir{2} 'trace_' num2str(i,'%05u') '.dat']),'saveMatrix','-ascii');
    end
    i = i+1;
end
end
