function [dataCell, fileNames] = packagePairsebFRET(channels)

%called by Kera.ebfretImport inside Kera.m

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
        if isfield(smd.data(i).attr,'file')
            fileNames{i,j} = smd.data(i).attr.file; %the ebFRET output structure (sometimes) holds the names of the original files
        end
    end

if size(smd.data,2)==1
    anS = questdlg('Did you want to use the fits in this trace, but distributed over the separate traces from a different smd?');
    if strcmp(anS,'Yes')
    %we're using long form (the first smd entered had all the traces
    %stitched together into one long trace; the second smd has to have them
    %individually, but the first is where the idealization data is taken
    %from)
    [file, path] = uigetfile;
    smd = importdata([path file]);
    for i = 1:size(smd.data,2)
        dataCell{i+1,j,1} = smd.data(i).values(:,3); %raw values (the "FRET" signal)
        dataCell{i+1,j,2} = smd.data(i).values(:,4); %discretized values
        if isfield(smd.data(i).attr,'file')
            fileNames{i+1,j} = smd.data(i).attr.file; %the ebFRET output structure (sometimes) holds the names of the original files
        end
    end
    
    [dataCell, fileNames] = useLongFormImport(dataCell, fileNames, j);
    end
end

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
