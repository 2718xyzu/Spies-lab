function [matrix, plotDisplay, fileNames] = packagePairsHaMMY(channels)

fileNames = {};
for i = 1:channels
    output = questdlg(['Please select the folder which contains HaMMY ',...
       'output for channel ' num2str(i)],'Instructions','OK','Quit','OK');
    if output(1) == 'Q'
        error('Quit program');
    end
    path = uigetdir;
    dir2 = dir([path filesep '*path.dat']);
    clear dir3;
    dir3 = { dir2.name };
    plotDisplay = cell([size(dir2,1) channels 2]);
    fileNames = cell([size(dir2,1) 1]);
    for j = 1:size(dir2,1)
        
        A = importdata([ path filesep dir3{j}]);
        if isstruct(A)
            A = A.data;
        end
        intensity{c}(q) = {A(:,column)'};
        
        
        
        
        longth = size(smd.data(j).values(:,4),1);
        matrix(1:longth, i+(j-1)*channels) = smd.data(j).values(:,4);
        plotDisplay(j,i,1) = smd.data(j).values(:,3);
        plotDisplay(j,i,2) = smd.data(j).values(:,4);
        fileNames{j} = dir3{j}(1:end-8);
    end

end
end