function [dataCell, fileNames] = packagePairsHaMMY(channels)
%still needs to be tested

fileNames = {};
for j = 1:channels
    output = questdlg(['Please select the folder which contains HaMMY ',...
       'output for channel ' num2str(j)],'Instructions','OK','Quit','OK');
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
    dataCell = cell([size(dir2,1) channels 2]);
    fileNames = cell([size(dir2,1) 1]);
    for i = 1:size(dir2,1)
        A = importdata([ path filesep dir3{i}]);
        if isstruct(A)
            A = A.data;
        end
        levels = sort(unique(A(:,5)));
        levelArray = arrayfun(@(x) find(x==levels),A(:,5));
        dataCell{i,j,1} = levelArray;
        dataCell{i,j,2} = A(:,4);
        fileNames{i} = dir3{i}(1:end-8);
    end

end
end