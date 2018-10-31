addpath('Functions');
clear intensity

blank = questdlg('Are your traces in a .traces file or saved individually in txt, csv, or dat?',...
    'Select format','.traces','Individual','Individual');


if blank(2) == 't'
    Trace_viewer_myversion();

else
    blank = questdlg('Select the folder which contains all traces to normalize',...
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

    column = inputdlg(['Which column of the data would you like extracted?  If you want each column extracted, type "all".' ...
        ' If it helps, the mean of each column is, in order: ' mat2str(meanA,5) ]);

    column = str2double(column{1});
    for q = 1:length(dir3)
        A = importdata([ path filesep dir3{q}]);
        if isstruct(A)
            A = A.data;
        end
        intensity(q,1:length(A)) = A(:,column);
    end

    emFRET = emulateFRET(intensity);
    timeUnit = inputdlg('Input time unit of the video in seconds');
    if isempty(timeUnit{:})
        timeUnit = .1;
    else
        timeUnit = str2double(timeUnit{1});
    end

    plotCut3(1-emFRET,emFRET,length(intensity),timeUnit);
end
