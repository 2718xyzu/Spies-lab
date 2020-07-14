function [dataCell, fileNames] = useLongFormImport(dataCell, fileNames, j)

importLengths = cellfun(@length,dataCell(:,j,1));
[~, ordering] = sort(importLengths,'descend');
dataCell(:,j,:) = dataCell(ordering,j,:);
fileNames(:,j) = fileNames(ordering,j);
    
    
if 2*length(dataCell{1,j,1})>=sum(cellfun(@length,dataCell(:,j,1)))
    anS = questdlg('Did you want to use the fits in the first (long) trace?');
    if strcmp(anS,'Yes')
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
                    keyboard;
                end
            end
        end
        dataCell(1:end-1,j,:) = dataCell(2:end,j,:); %get rid of the long-form trace
        fileNames(1:end-1,j) = fileNames(2:end,j);
        dataCell(end,:,:) = [];
        fileNames(end,:,:) = [];
    end
end


end