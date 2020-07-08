function [dataCell, fileNames] = packagePairsHaMMY(channels)
%still needs to be tested
importedFilenames = cell([1 channels]);

for j = 1:channels
    output = questdlg(['Please select the folder which contains HaMMY ',...
       'output for channel ' num2str(j)],'Instructions','OK','Quit','OK');
    if output(1) == 'Q'
        error('Quit program');
    end
    path = uigetdir;
    dir2 = dir([path filesep '*path.dat']);
    if j == 1
        dataCell = cell([size(dir2,1) channels 2]);
        fileNames = cell([size(dir2,1) 1]);
    end
    for i = length(dir2):-1:1
        if dir2(i).name(1) == '.' %must ignore files which begin with a period (MacOS)
            dir2(i) = [];
        end
    end
    importedFilenames(1:length(dir2),j) =  {dir2.name};
    for i = 1:size(dir2,1)
        A = importdata([ path filesep importedFilenames{i,j}]);
        if isstruct(A)
            A = A.data;
        end
        levels = sort(unique(A(:,5)));
        levelArray = arrayfun(@(x) find(x==levels),A(:,5),'UniformOutput',false);
        dataCell{i,j,1} = A(:,4);
        dataCell{i,j,2} = cell2mat(levelArray);
        fileNames{i} = importedFilenames{i,j}(1:end-8);
    end

end


try
    assert(all(~cellfun(@isempty,importedFilenames(end,:))));
catch
    warning('Some of the data sets entered do not have the same number of trajectories; check the variable named "importedFilenames" to find the mismatch ');
    keyboard;
end


end