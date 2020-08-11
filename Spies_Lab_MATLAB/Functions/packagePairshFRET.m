function [dataCell, fileNames] = packagePairshFRET(channels)

%a function which takes in multiple hFRET output files and extracts the
%data from them, keeping the traces in the correct order to pair the
%corresponding traces with each other

%hFRET must be run in 1-color mode on each set of traces (if you have
%multiple channels, this means loading all the channel 1 traces into hFRET,
%getting a model, exporting it, and then repeating that process for the
%traces in the next channel).  Each of the resulting exports will be
%imported during this function call.

%dataCell is a cell containing both the raw data (if available) and the
%disretizations; the first dimension iterates over the traces, the second
%dimension over the channels, and the third dimension is 1 if raw and 2 if
%discretized.  Each cell contains a column vector.

%fileNames is populated only with numeric strings, since unfortunately
%hFRET does not retain any information about the filenames of traces put
%into it.

fileNames = cell([1 channels]);
dataCell = cell([1 channels 2]);
for j = 1:channels
output = questdlg(['Please select the hFRET output file for channel ',...
    num2str(j)],'Instructions','OK','Quit','OK');
    if output(1) == 'Q'
        error('Quit program');
    end
    [file, path] = uigetfile;
    hf = importdata([path file]);
    for i = 1:size(hf.data,1)
        dataCell{i,j,1} = hf.data{i}; %raw values (the "FRET" signal)
        m = hf.vbem{i}.m;
        discrete = zeros(size(hf.vbem{i}.ideals));
        for i0 = 1:length(hf.vbem{i}.ideals)
            discrete(i0) = find(hf.vbem{i}.ideals(i0)==m);
        end
        dataCell{i,j,2} = discrete;  %discretized values
        fileNames{i,j} = num2str(i); %the ebFRET output structure holds the names of the original files
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
