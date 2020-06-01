function [matrix, plotDisplay] = packagePairsebFRET(channels,filetype)
if strcmp(filetype,'smd')
    for i = 1:channels
    output = questdlg(['Please select the SMD file for channel ',...
        num2str(i)],'Instructions','OK','Quit','OK');
        if output(1) == 'Q'
            error('Quit program');
        end
        [file, path] = uigetfile;
        smd = importdata([path file]);
        plotDisplay = cell([size(smd.data,2) channels 2]);
        for j = 1:size(smd.data,2)
            longth = size(smd.data(j).values(:,4),1);
            matrix(1:longth, i+(j-1)*channels) = smd.data(j).values(:,4);
            plotDisplay(j,i,1) = smd.data(j).values(:,3);
            plotDisplay(j,i,2) = smd.data(j).values(:,4);
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
    for i = 1:channels
    output = questdlg(['Please select the matlab variable file for channel ',...
        num2str(i)],'Instructions','OK','Quit','OK');
        if output(1) == 'Q'
            error('Import terminated');
        end
        [file, path] = uigetfile;
        smd = importdata([path file]);
        for j = 1:size(smd.data,2)
            longth = size(smd,1);
            matrix(1:longth, i+(j-1)*channels) = smd(:,j);
        end
    end
    plotDisplay = [];
end

end
