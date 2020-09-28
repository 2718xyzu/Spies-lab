function changeTohFRET

[~] = questdlg('Select the folder which contains data',...
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

    column = inputdlg(['Which column of the data would you like to extract? If it helps, the mean of each column is, in order: ' mat2str(meanA,5) ]);

    column = str2double(column{1});
    intensity = cell(length(dir3),1);
    fileNames = dir3;
    for i = 1:length(dir3)
        A = importdata([ path filesep dir3{i}]);
        if isstruct(A)
            A = A.data;
        end
        intensity(i) = {A(:,column)};
    end

 [~] = questdlg('Please select a directory (or make a new one) in which to save traces in hFRET format',...
     'Select Directory','Ok','Ok');
    saveDir = uigetdir;
    if ~isfolder(saveDir)
        errordlg('Directory not found.  Using default directory');
        saveDir = [];
    end
    for i = 1:length(intensity)
        traceA = intensity{i};
        save(([saveDir filesep regexprep(fileNames{i},'.dat','') '_h.dat']),'traceA','-ascii');
    end
    

end