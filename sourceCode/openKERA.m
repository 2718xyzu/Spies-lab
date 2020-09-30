% KERA setup function
% Joseph Tibbs 09/30/2020


% Make sure the user is in the sourceCode directory, and add
% the Functions folder to the path:

lastwarn('');
addpath('Functions');
[warnMsg, warnId] = lastwarn;
if ~isempty(warnMsg)
    questdlg(['Functions directory not found; please select the sourceCode '...
        'scripts directory to add it to the search path'],'Select search dir',...
    'Ok','Ok');
    lastwarn('');
    cd(uigetdir);
    addpath('Functions');
end

% open a KERA session:

[~] = Kera(1);

