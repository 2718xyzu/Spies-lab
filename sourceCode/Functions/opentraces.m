function intensity = opentraces()

    clear intensity

    blank = questdlg('Select the folder which contains all traces to extract',...
        'Select folder','Ok','Ok');

    path = uigetdir;

    if ispc
        slash = '\';
    else
        slash = '/';
    end

    format = questdlg('Which format are the traces in?','Select format','.csv','.txt','.dat','.dat');

    if format(2) == 'c'
        dir2 = dir([path slash '*.csv']);
        clear dir3;
        dir3 = { dir2.name };
        A = importdata([ path slash dir3{1}]);
        meanA = mean(A.data);
    elseif format(2) == 't'
        dir2 = dir([path slash '*.txt']);
        clear dir3;
        dir3 = { dir2.name };
        A = importdata([ path slash dir3{1}]);
        meanA = mean(A);
    else
        dir2 = dir([path slash '*.dat']);
        clear dir3;
        dir3 = { dir2.name };
        A = importdata([ path slash dir3{1}]);
        meanA = mean(A);
    end
    column = inputdlg(['Which column of the data would you like extracted?  If you want each column extracted, type "all".' ...
        ' If it helps, the mean of each column is, in order: ' mat2str(meanA,5) ]);
    if ~isnan(str2double(column{1}))
        column = str2double(column{1});
        for q = 1:length(dir3)
            A = importdata([ path slash dir3{q}]);
            if isstruct(A)
                A = A.data;
            end
            intensity(q,1:length(A)) = A(:,column);
        end
    else
        for q = 1:length(dir3)
            A = importdata([ path slash dir3{q}]);
            if isstruct(A)
                A = A.data;
            end
            for c = 1:size(A,2)
                intensity(q,1:length(A),c) = A(:,c);
            end
        end
    end
end
