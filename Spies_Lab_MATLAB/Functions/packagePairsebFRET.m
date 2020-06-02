function [matrix, plotDisplay, fileNames] = packagePairsebFRET(channels,filetype)

%a function which takes in multiple ebFRET output files and extracts the
%data from them, keeping the traces in the correct order to pair the
%corresponding traces with each other

%matrix is a matrix containing column vectors (if the traces are not the
%same length, the end of each vector is padded with zeros) which correspond
%to [ channel1trace1 channel1trace2.... channel1trace2 channel2trace2 ...]

%plotDisplay is a cell containing both the raw data (if available) and the
%disretizations; the first dimension iterates over the traces, the second
%dimension over the channels, and the third dimension is 1 if raw and 2 if
%discretized.  Each cell contains a column vector.

%fileNames does its best to extract the filenames out of the dataset and
%have each one corresponding to its trace(s).

fileNames = {};
if strcmp(filetype,'smd')
    for j = 1:channels
    output = questdlg(['Please select the SMD file for channel ',...
        num2str(j)],'Instructions','OK','Quit','OK');
        if output(1) == 'Q'
            error('Quit program');
        end
        [file, path] = uigetfile;
        smd = importdata([path file]);
        plotDisplay = cell([size(smd.data,2) channels 2]);
        fileNames = cell([size(smd.data,2) 1]);
        for i = 1:size(smd.data,2)
            longth = size(smd.data(i).values(:,4),1);
            matrix(1:longth, j+(i-1)*channels) = smd.data(i).values(:,4); %discretized values
            plotDisplay(i,j,1) = smd.data(i).values(:,3); %raw values (the "FRET" signal)
            plotDisplay(i,j,2) = smd.data(i).values(:,4); %discretized values
            fileNames{i} = smd.data(i).attr.file; %the ebFRET output structure holds the names of the original files
        end
    end
else
    ans1 = questdlg(['Are your discretized traces stored as column vectors with a'...
        ' constant time step between values?  And, if you have more than one channel,'...
        ' are the traces for each channel contained in separate variables (but are'...
        ' ordered such that all variables contain colocalized traces as the same column number)?'],...
        'Format check', 'Yes', 'No', 'Yes');
    if strcmp(ans1,'No')
        print('Check the documentation for input filetypes');
        error('Import terminated');
    end
    for j = 1:channels
    output = questdlg(['Please select the matlab variable file for channel ',...
        num2str(j)],'Instructions','OK','Quit','OK');
        if output(1) == 'Q'
            error('Import terminated');
        end
        [file, path] = uigetfile;
        smd = importdata([path file]);
        for i = 1:size(smd.data,2)
            longth = size(smd,1);
            matrix(1:longth, j+(i-1)*channels) = smd(:,i);
        end
    end
    plotDisplay = [];
end

end
