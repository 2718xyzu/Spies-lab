%Joseph Tibbs
%Last updated: 6/19

function plotCut3(matrixID,matrixIA,frames,timeUnit)
    saveMode = '2'
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
    if ismac
        slash = '/';
    else
        slash = '\';
    end
    saveDir{i} = [saveDir{i} slash];
    if ~isdir(saveDir{i})
        errordlg('Directory not found.  Using default directory');
        saveDir{i} = [];
    end
    end
    
    goOn = 1;
    i = 1;
    timeSeries = 0:timeUnit:timeUnit*(frames-1);
    cutCount = zeros(size(matrixID,1),1);
    while i <= size(matrixID,1) && goOn ~= 6
        %figure(3);
%         figure('OuterPosition',[100,100,1000,700]);
%         subplot(2,1,1);
%         axis([0 frames*timeUnit 0 150]);
%         plot(timeSeries,smoothTrace(matrixID(i,:)),'g');
%         hold on;
%         plot(timeSeries,smoothTrace(matrixIA(i,:)),'r');
%         title(['\fontsize{20} Trace ' num2str(i)]);
%         axis([0 frames*timeUnit 0 inf]);
% %         hold off;
%         subplot(2,1,2);
%         plot(timeSeries,smoothTrace(getFret(matrixID(i,:),matrixIA(i,:))),'b');
%         axis([0 frames*timeUnit 0 1]);
% %         title(['Trace ' num2str(i)]);
        goOn=1;
%         goOn = input(['Press Enter to go to the next trace; Press 1 to save entire trace. \n' ...
%         'Press 3 to save part of a trace; Press 5 to go to a particular trace; Press 0 to go back \n'...
%         'Press 6 or ctrl+C to exit']);
        if isempty(goOn)
            goOn = 10;
        end
        switch goOn
            case 1
                traceD = matrixID(i,:);
                traceA = matrixIA(i,:);
                traceFret = getFret(traceD,traceA);
                saveMatrix = vertcat(timeSeries,traceD,traceA,traceFret);
                saveMatrix = transpose(saveMatrix);
                if QuB
                save(([saveDir{1} 'trace_' num2str(i) '.dat']),'saveMatrix','-ascii');
                cutCount(i,1) = cutCount(i,1) + 1;
                end
                if ebFRET
                    saveMatrix = vertcat(traceD,traceA);
                    saveMatrix = transpose(saveMatrix);
                    save(([saveDir{2} 'trace_' num2str(i) '_' num2str(cutCount(i,1)) '.dat']),'saveMatrix','-ascii');
                    cutCount(i,1) = cutCount(i,1) + 1;
                end
            case 3
%                 [x,~] = ginput(2);
                x = x./timeUnit;
                x = round(x);
                traceD = matrixID(i,x(1):x(2));
                traceA = matrixIA(i,x(1):x(2));
                traceFret = getFret(traceD,traceA);
                if QuB
                saveMatrix = vertcat((x(1):x(2))*timeUnit,traceD,traceA,traceFret);
                saveMatrix = transpose(saveMatrix);
                if cutCount(i,1) == 0
                    save(([saveDir{1} 'trace_' num2str(i) '.dat']),'saveMatrix','-ascii');
                else
                    save(([saveDir{1} 'trace_' num2str(i) '_' num2str(cutCount(i,1)) '.dat']),'saveMatrix','-ascii');
                end
                cutCount(i,1) = 1 + cutCount(i,1);
                end
                if ebFRET
                saveMatrix = vertcat(traceD,traceA);
                saveMatrix = transpose(saveMatrix);
                if cutCount(i,1) == 0
                    save(([saveDir{2} 'trace_' num2str(i) '.dat']),'saveMatrix','-ascii');
                else
                    save(([saveDir{2} 'trace_' num2str(i) '_' num2str(cutCount(i,1)) '.dat']),'saveMatrix','-ascii');
                end
                cutCount(i,1) = 1 + cutCount(i,1);
                end
            case 5
                i = str2double(strjoin(inputdlg('Trace to go to:')))-1;
            case 0
                i = i-2;
        end
          i = i+1;
%         figure(3);
%         close 3;
    end
end