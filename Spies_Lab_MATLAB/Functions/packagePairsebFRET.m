function matrix = packagePairsebFRET(channels)
    for i = 1:channels
    output = questdlg(['Please select the SMD file for channel ',...
        num2str(i)],'Instructions','OK','Quit','OK');
        if output(1) == 'Q'
            error('Quit program');
        end
        [file, path] = uigetfile;
        smd = importdata([path file]);
        for j = 1:size(smd.data,2)
            longth = size(smd.data(j).values(:,4),1);
            matrix(1:longth, i+j*channels-1) = smd.data(j).values(:,4);
        end
    end
end
