%Joseph Tibbs
%Last updated: 6/12

function plotCut(matrixI,frames,timeUnit)
    blank = questdlg('Please select a directory (or make a new one) in which to save all traces',...
        'Select Directory','Ok','Ok');
    saveDir = uigetdir;
    if ismac
        slash = '/';
    else
        slash = '\';
    end
    goOn = 1;
    i = 1;
    timeSeries = 0:timeUnit:timeUnit*(frames-1);
    cutCount = zeros(size(matrixI,1),1);
    while i <= size(matrixI,1) && goOn ~= 6
        figure('OuterPosition',[100,100,1000,700]);
%         figure(3);
        hold on;
        title(['\fontsize{16} Trace ' num2str(i)]);
        axis([0 frames*timeUnit 0 inf]);
        plot(timeSeries,smoothTrace(matrixI(i,:)));
%         plot(timeSeries,matrixIadj(i,:));
        goOn = FRETui;
        if isfield(goOn,'xValues')
            x = goOn.xValues;
        end
        goOn = goOn.Value;
%         goOn = input(['Press Enter to go to the next trace; Press 1 to save entire trace. \n' ...
%         'Press 3 to save part of a trace; Press 5 to go to a particular trace; Press 0 to go back \n'...
%         'Press 6 or ctrl+C to exit']);
        if isempty(goOn)
            goOn = 10;
        end
        switch goOn
            case 1
                trace = matrixI(i,:);
%                 traceAdj = matrixIadj(i,:);
                saveMatrix = vertcat(timeSeries,trace);
                saveMatrix = transpose(saveMatrix);
                save(([saveDir slash 'trace_' num2str(i) '.dat']),'saveMatrix','-ascii');
                cutCount(i,1) = cutCount(i,1) + 1;
            case 3
%                 [x,~] = ginput(2);
                x = x./timeUnit;
                x = round(x);
                trace = matrixI(i,x(1):x(2));
                saveMatrix = vertcat((x(1):x(2))*timeUnit,trace);
                saveMatrix = transpose(saveMatrix);
                if cutCount(i,1) == 0
                    save(([saveDir slash 'trace_' num2str(i) '.dat']),'saveMatrix','-ascii');
                else
                    save(([saveDir slash 'trace_' num2str(i) '_' num2str(cutCount(i,1)) '.dat']),'saveMatrix','-ascii');
                end
                cutCount(i,1) = 1 + cutCount(i,1);
            case 5
                i = str2double(strjoin(inputdlg('Trace to go to:')))-1;
            case 0
                i = i-2;
        end
        i = i+1;
        figure(3);
        close 3;
    end
end