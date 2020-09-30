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

% if exist('kera','var')
%     [~] = questdlg(['Warning: a variable called "kera" already exists; export your current KERA session to '...
%         'a saved session, delete the kera variable, and then run this script again.  You can later reopen '...
%         'the old session by clicking "import-->saved session" in your new kera (this is the only supported ' ...
%         'method to open multiple kera sessions at once)'],'Kera overwrite warning','Ok','Ok');
%     return
% end


Kera(1);

