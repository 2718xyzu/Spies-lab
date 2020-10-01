function [dataCell, fileNames] = useLongFormImport(dataCell, fileNames, j)

%This was part of an experimental import method--all traces would be
%concatenated into a single trace and analyzed by ebFRET or HaMMY that way.
% It was largely unwieldy and ineffective; although it helped some of the
% problems of an ebFRET analysis, HaMMY has a limit on how long any trace
% can be which is imported to it.  If ebFRET is giving you problems, use
% hFRET instead.



importLengths = cellfun(@length,dataCell(:,j,1));
[~, ordering] = sort(importLengths,'descend');
dataCell(:,j,:) = dataCell(ordering,j,:);
fileNames(:,j) = fileNames(ordering,j);
    
    
if 2*length(dataCell{1,j,1})>=sum(cellfun(@length,dataCell(:,j,1)))

        u = unique(dataCell{1,j,2});
        for i0 = u'
            meanState(i0) = mean(dataCell{1,j,1}(dataCell{1,j,2}==i0));
            stateLocations{i0} = dataCell{1,j,2}==i0;
        end
        [~,I] = sort(meanState,'ascend');
        for i0 = 1:max(u)
            dataCell{1,j,2}(stateLocations{I(i0)}) = i0;
        end

        for i = 2:size(dataCell,1)
            for i2 = find(dataCell{1,j,1}==dataCell{i,j,1}(1))' %really should not occur more than once
                if sum((dataCell{1,j,1}(i2:(i2+length(dataCell{i,j,1})-1))-dataCell{i,j,1}).^2)/sum((dataCell{i,j,1}-mean(dataCell{i,j,1})).^2)<1E-7
                    dataCell{i,j,2} = dataCell{1,j,2}(i2:(i2+length(dataCell{i,j,2})-1));
                else
                    if numel(find(dataCell{1,j,1}==dataCell{i,j,1}(1)))==1
                        keyboard; %something is wrong; are you sure the second smd you entered has the same traces
                                  %in it as the "long" trace in the first smd?
                    end
                end
            end
        end
        dataCell(1:end-1,j,:) = dataCell(2:end,j,:); %get rid of the long-form trace
        fileNames(1:end-1,j) = fileNames(2:end,j);
        dataCell(end,:,:) = [];
        fileNames(end,:,:) = [];

end


end