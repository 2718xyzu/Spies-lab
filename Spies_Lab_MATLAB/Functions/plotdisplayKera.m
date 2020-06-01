function [plotCell] = plotdisplayKera(plotCell, fileNames)

N = length(plotCell);
i = 1;
while i <= N
    figure('Units', 'Normalized','Position',[.05 .4 .9 .5]);
    title(fileNames{i});
end


end