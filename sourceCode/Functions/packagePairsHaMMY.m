function [dataCell, fileNames] = packagePairsHaMMY(channels)

%called by Kera.haMMYimport inside Kera.m

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
        fileNames = cell([size(dir2,1) channels]);
    end
    dir2 = dir2(~cellfun('isempty', {dir2.date})); %ignore invalid files
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
        fileNames{i,j} = importedFilenames{i,j}(1:end-8);
    end
    
[dataCell, fileNames] = useLongFormImport(dataCell, fileNames, j);
    
end


try
    assert(all(~cellfun(@isempty,importedFilenames(end,:))));
catch
    warning('Some of the data sets entered do not have the same number of trajectories; check the variable named "importedFilenames" to find the mismatch ');
    keyboard;
end


end