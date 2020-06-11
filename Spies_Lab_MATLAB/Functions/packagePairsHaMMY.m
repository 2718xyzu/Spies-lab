function [matrix, plotDisplay, fileNames] = packagePairsHaMMY(channels)
%created but left in a broken state
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
    for i = length(dir2):-1:1
        if dir2(i).name(1) == '.' %must ignore files which begin with a period (MacOS)
            dir2(i) = [];
        end
    end
    dir3 = { dir2.name };
    plotDisplay = cell([size(dir2,1) channels 2]);
    fileNames = cell([size(dir2,1) 1]);
    for j = 1:size(dir2,1)
        A = importdata([ path filesep dir3{j}]);
        if isstruct(A)
            A = A.data;
        end
        longth = size(A,1);
        matrix(1:longth, i+(j-1)*channels) = A(:,4);
        levels = sort(unique(A(:,5)));
        levelArray = arrayfun(@(x) find(x==levels),A(:,5));
        plotDisplay{j,i,1} = levelArray;
        plotDisplay{j,i,2} = A(:,4);
        fileNames{j} = dir3{j}(1:end-8);
    end

end
end