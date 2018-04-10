function out = histogramData(struct)
    row = inputdlg('Which row of the output file would you like to plot?','Data select');
    row = str2double(row{1});

    dataType = questdlg('Would you like to plot dwell times or off times?', 'Data select',...
        'Dwell Times', 'Off Times', 'Dwell Times');

    if dataType(1) == 'D'
        out.dataType = 1;
        rawData = struct.output(row).timeLengths;
        out.rawData = rawData;
    else
        out.dataType = 2;
        rawData = struct.output(row).timeLengths_Gaps;
        out.rawData = rawData;
    end

    fitType = questdlg('Would you like to plot a default or a logarithmic histogram', 'Fit select',...
        'Default', 'Logarithmic', 'Default');

    if fitType(1) == 'D'
        out.fitType = 1;
        out.data = rawData;
    else
        out.fitType = 2;
        out.data = log(rawData);
    end

    order = questdlg('Single or double exponential?', 'Fit select',...
        'Single', 'Double', 'Single');

    if order(1) == 'S'
        out.order = 1;
    else
        out.order = 2;
    end

    figure();
    hold on;
    out.handle = gcf;


    h1 = histogram(out.data);
    fitModel = getFitHistogram(h1,out.fitType,out.order);

    xList = linspace(h1.BinEdges(1),h1.BinEdges(end),500);
    yList = fitModel(xList);
    plot(xList,yList);
    disp(fitModel);
end
