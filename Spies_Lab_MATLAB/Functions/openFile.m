%Joseph Tibbs
%Last updated: 6/12/17

function [A,name] = openFile()
% path = strjoin(inputdlg('Paste the path to the .pma file you want to analyze'));
% if path(length(path)) ~= '\' && path(length(path)) ~= '/'
%     path(length(path)+1) = path(1);
% end
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