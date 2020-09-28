function [A,name] = openFile()
    A = questdlg('Please select your pma movie file','Select file','OK','Quit','OK');
    [fileName, path,~] = uigetfile({'*.pma','*.mat'},'Select pma movie');
    A = fopen([path fileName]);
    for i = 1:length(fileName)
        if fileName(i) == '.'
            j = i;
        end
    end
    name = fileName(1:j-1);
end
