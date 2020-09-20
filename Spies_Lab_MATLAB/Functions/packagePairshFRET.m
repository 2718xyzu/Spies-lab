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
    paddingTon = inputdlg('Enter the padding value for this data set, or "NaN" if you want to leave the data as-is');
    paddingTon = str2double(paddingTon);
    if ~isnan(paddingTon)
        state2Set = inputdlg(['If anything in the trace was set to the padding state, what state should it be' ...
            ' assigned to (i.e. 1 if you padded at a baseline level)']);
        state2Set = str2double(state2Set);
        mGiven = hf.vbem{1}.m;
        padState = inputdlg(['These are the values of the center of each state: ' mat2str(mGiven) ...
            '.  Which one represents the padding state?  Again, if you padded at the baseline, this is probalby 1.']);
        padState = str2double(padState);
        if isnan(padState)
            padState = 1;
        end
        mPad = mGiven(padState);
        mWithoutPad = mGiven(setdiff(1:length(mGiven),padState));
        %m is the list of "idealized" levels, which allows us to assign
        %each point to the idealized state which hFRET decided for it
        %(stored in the "ideals" list in the hFRET output struct)
        %But if we're deleting padding, we also need to delete the state
        %which was assigned to the padding
    end
    for i = 1:size(hf.data,1)
        if isnan(paddingTon) %set it up so the data does not get changed and we do not assume any padding
            dataCell{i,j,1} = hf.data{i}; %raw values (the "FRET" signal)
            m = hf.vbem{i}.m;
            state2Set = length(m);
            cropIndex = length(hf.data{i});
        else
            tempData = hf.data{i}; %prepare to cut out padded values and re-assign states
            cropIndex = find(diff(tempData == paddingTon),1,'last');
            if isempty(cropIndex)
                cropIndex = length(tempData);
            end
            dataCell{i,j,1} = hf.data{i}(1:cropIndex);
            m = [mWithoutPad ; mPad];
        end
        discrete = zeros(min(size(hf.vbem{i}.ideals),cropIndex));
        for i0 = 1:cropIndex
            discrete(i0) = find(hf.vbem{i}.ideals(i0)==m); 
        end
        discrete(discrete==(length(m))) = state2Set; %in non-padded sets, this line does nothing
        dataCell{i,j,2} = discrete;  %discretized values
        fileNames{i,j} = num2str(i); %the output structure does not hold any original filenames
    end

%long form is not applicable ot hFRET

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
