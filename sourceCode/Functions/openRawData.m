function [intensity,fileNames] = openRawData(channels)

%called by normalizeTrajectorySet and convertRawFiles.  Just a UI for
%mass-opening data stored in multiple files (or in the .traces format,
%which is an obscure filetype that might be unique to the Spies lab)

intensity = cell([1 channels]);
for c = 1:channels

blank = questdlg(['Are your traces for channel ' num2str(c) ...
    ' in a .traces file or saved individually in txt, csv, or dat?'],...
    'Select format','.traces','Individual','Individual');


if blank(2) == 't'
    [donors, acceptors] = extractTracesFiles();
    blank = questdlg(['Would you like channel ' num2str(c)...
        ' to be the donors or acceptors?'],...
        'Select data','Donors', 'Acceptors', 'Donors'); 
    if blank(1) == 'D'
        intensity{c} = donors;
    else
        intensity{c} = acceptors;
    end
    fileNames = cell([length(donors); 1]);
    for i = 1:length(donors)
        fileNames{i} = [ 'trace' num2str(i)];
    end
else
    [~] = questdlg(['Select the folder which contains all data for channel ' num2str(c)],...
        'Select folder','Ok','Ok');

    path = uigetdir;


    format = questdlg('Which format are the traces in?','Select format','.csv','.txt','.dat','.dat');

    if format(2) == 'c'
        dir2 = dir([path filesep '*.csv']);
        clear dir3;
        dir3 = { dir2.name };
        A = importdata([ path filesep dir3{1}]);
        meanA = mean(A.data);
    elseif format(2) == 't'
        dir2 = dir([path filesep '*.txt']);
        clear dir3;
        dir3 = { dir2.name };
        A = importdata([ path filesep dir3{1}]);
        meanA = mean(A);

    else
        dir2 = dir([path filesep '*.dat']);
        clear dir3;
        dir3 = { dir2.name };
        A = importdata([ path filesep dir3{1}]);
        meanA = mean(A);

    end

    column = inputdlg(['Which column of the data would you like to assign to channel '...
        num2str(c) '? If it helps, the mean of each column is, in order: ' mat2str(meanA,5) ]);

    column = str2double(column{1});
    intensity{c} = cell(length(dir3),1);
    fileNames = dir3;
    for q = 1:length(dir3)
        A = importdata([ path filesep dir3{q}]);
        if isstruct(A)
            A = A.data;
        end
        intensity{c}(q) = {A(:,column)'};
    end
end
end
end