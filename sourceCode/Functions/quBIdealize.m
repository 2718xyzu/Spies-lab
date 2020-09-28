function quBIdealize(traces)
    tracesModified = traces;
    numTraces = size(traces,1);
    lengthTraces = size(traces,2);
    numCol = size(traces,3);
    prefix = inputdlg('Please choose a prefix for this data set, to start each filename');
    for i = 1:numCol
        suffix = inputdlg(['Please choose a suffix for color number ',num2str(i)]);
        suffixes{i} = suffix{1};
    end
    i = 1;
    j = 2;
    values = 0;
    while i <= numTraces && values ~= 6
        h = figure();
        pos = get(h,'position');
        set(h,'position',[pos(1:2),pos(3)*1.4,pos(4)]);
        hold on;
        for j = 1:numCol
            plot(1:lengthTraces,tracesModified(i,:,j),'.');
        end
        while j <= numCol && values ~= 6
            plot(1:lengthTraces,tracesModified(i,:,j),'o-');
            values = quBui;
            values = values.Values;
            switch values(1)
                case 10
                    j = j+1;
                    break
                case 1 %idealize
                    tracesModified(i,:,j) = smoothTrace(tracesModified(i,:,j));
                    break
                case 3 %save idealizations
                    break
                case 5 %cut and save
                    break
                case 0 %back
                    if j == 1
                        i = max([i-2,0]);
                    else
                        j = j-1;
                    end
                    break
                case 7 %Go to specific trace
                    traceInput = inputdlg('Input number of trace to go to');
                    j = 1;
                    i = traceInput;
                    break
                case 8 %set dead times
                    break
            end
        end
        i = i+1;
    end
end
