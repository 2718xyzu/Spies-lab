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

    if 2*length(dataCell{1,j,1})>=sum(cellfun(@length,dataCell(:,j,1)))
        anS = questdlg('Did you want to use the fits in the first (long) trace?');
        if strcmp(anS,'Yes')
            for i = 2:size(dataCell,1)
                for i2 = find(dataCell{1,j,1}==dataCell{i,j,1}(1))' %really should not occur more than once
                    if sum(dataCell{1,j,1}(i2:(i2+length(dataCell{i,j,1})-1))-dataCell{i,j,1})<eps
                        dataCell{i,j,2} = dataCell{1,j,2}(i2:(i2+length(dataCell{i,j,2})-1));
                    end
                end
            end
            dataCell(1:end-1,j,:) = dataCell(2:end,j,:); %get rid of the long-form trace
            fileNames(1:end-1,j) = fileNames(1:end-1,j);
            dataCell(end,:,:) = [];
            fileNames(end,:,:) = [];
        end
    end

end

    
try
    assert(all(~cellfun(@isempty,fileNames(end,:))));
catch
    warning('Some of the data sets entered do not have the same number of trajectories; check the variable named "filenames" to find the mismatch ');
    keyboard;
end
    
   

fileNames = fileNames(:,1);
end
