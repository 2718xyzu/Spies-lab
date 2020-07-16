function [dataCell, fileNames] = packagePairsebFRET(channels)

%a function which takes in multiple ebFRET output files and extracts the
%data from them, keeping the traces in the correct order to pair the
%corresponding traces with each other

%dataCell is a cell containing both the raw data (if available) and the
%disretizations; the first dimension iterates over the traces, the second
%dimension over the channels, and the third dimension is 1 if raw and 2 if
%discretized.  Each cell contains a column vector.

%fileNames does its best to extract the filenames out of the dataset and
%have each one corresponding to its trace(s).

fileNames = cell([1 channels]);
dataCell = cell([1 channels 2]);
for j = 1:channels
output = questdlg(['Please select the SMD file for channel ',...
    num2str(j)],'Instructions','OK','Quit','OK');
    if output(1) == 'Q'
        error('Quit program');
    end
    [file, path] = uigetfile;
    smd = importdata([path file]);
    for i = 1:size(smd.data,2)
        dataCell{i,j,1} = smd.data(i).values(:,3); %raw values (the "FRET" signal)
        dataCell{i,j,2} = smd.data(i).values(:,4); %discretized values
        fileNames{i,j} = smd.data(i).attr.file; %the ebFRET output structure holds the names of the original files
    end

[dataCell, fileNames] = useLongFormImport(dataCell, fileNames, j);

end

    
try
    assert(all(~cellfun(@isempty,fileNames(end,:))));
catch
    warning('Some of the data sets entered do not have the same number of trajectories; check the variable named "filenames" to find the mismatch ');
    keyboard;
end
    
   
%keyboard %uncomment this line in order to view the filenames before
%continuing analysis; this way, you can view the variable named "fileNames"
%and make sure the names in each column correspond to the traces which are
%supposed to be paired
fileNames = fileNames(:,1);
end
