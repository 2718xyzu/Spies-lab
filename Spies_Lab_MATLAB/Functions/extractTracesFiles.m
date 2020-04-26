% Written by Digvijay Singh  ( dgvjay@illinois.edu)
% Modified by Shyamal Subramanyam (subrama9@illinois.edu)
% Further Modified by Joseph Tibbs (jtibbs2@illinois.edu)

function [donors, acceptors] = extractTracesFiles()
    addpath('Functions');
    h = msgbox('Select your .traces file');
    waitfor(h);
    %FilePointer
     [filename, path] = uigetfile('.traces');
     File_id=fopen([path filename],'r');

    % FileIndexNumber=input('Enter the index number of the traces you want to analyse \n for e.g. if you want to analyse hel1.traces...then enter 1 \n if you want to analyse hel2.traces...then enter2 \n  ');
    % FileIndexNumber=num2str(FileIndexNumber);
    % TheFileThatWillbeAnalysed = ['raw' FileIndexNumber GenericFileType]; %displays the .traces file that will be used to show
    %it's single molecule traces.

    % Define time unit
    % Make it 0.03 if the frame rate is 30 ms etc...0.1 if the frame rate is
    % 100ms

    % Directory_of_TracesFiles=input('Please enter the full name of the directory which has the traces file you want to analyse :: \n');
    % cd(Directory_of_TracesFiles);

    % FileIndexNumber=input('File index number:','s');
    % GenericFileType = '.traces';
    %
    %  File_id=fopen([Directory_of_TracesFiles '/' 'hel' FileIndexNumber GenericFileType],'r');



    Timeunit=input('Enter the value of the time unit i.e. the duration of your frame rate [Default=0.1 sec]  ');
        if isempty(Timeunit)
            Timeunit=0.1;
        end
    ChannelLeakage=input('Enter the value of the Channel Leakage (Default is 0.07) ? :');
        if isempty(ChannelLeakage)
           ChannelLeakage=0.07;
        end
    Donor_Backgrnd_Correction=input('Enter the Donor Background Value (Default 0):');
        if isempty(Donor_Backgrnd_Correction)
           Donor_Backgrnd_Correction=0;
        end
    Acceptor_Backgrnd_Correction=input('Enter the Acceptor Background Value (Default 0):');
        if isempty(Acceptor_Backgrnd_Correction)
           Acceptor_Backgrnd_Correction=0;
        end
    GammaFactor=input('Enter Gamma Factor (Default 1):');
        if isempty(GammaFactor)
               GammaFactor=1.0;
        end



    % Extracting important information from .traces binary file
    Length_of_the_TimeTraces=fread(File_id,1,'int64');% This fetches the total duration of the imaging that was carried out for the
    % concerned .traces file...please note that .traces is a binary file and
    % this is the way it was binarized and we are just extracting the
    % information from the binary file
    disp('The length of the time traces is: ')
    disp(Length_of_the_TimeTraces);% This displays the total duration of the imaging that was carried out for the
    % concerned .traces file.

    Number_of_traces=fread(File_id,1,'int16');  % This fetches the total number of single molecule spots in the
    % concerned .traces file...since each spot has a pair i.e. Green channel
    % and a red channel therefore we would need to divide this number by 2 to
    % get the actual number of spots.

    disp('The number of traces in this file is:')
    disp(Number_of_traces/2);% This displays the total number of single molecule spots in the
    % concerned .traces file.
    Number_of_traces = 2*floor(Number_of_traces/2);
    %Reading in the entire raw data from the .traces binary file encoded in
    %int16 format as noted above that .traces is a binary file and
    % this is the way it was binarized and we are just extracting the
    % information from the binary file.
    Raw_Data=fread(File_id,Number_of_traces*Length_of_the_TimeTraces,'int16');
    disp('Done reading data');
    fclose(File_id);  % We close the file pointer here as all the information that we needed from it
    % has been extracted succesffuly and stored into local variables like Raw_Data, Number_of_Traces etc etc.


    % Converting into Donor and Acceptor traces of several selected spots in
    % the movie.
    Index_of_SelectedSpots=(1:Number_of_traces*Length_of_the_TimeTraces);
    DataMatrix=zeros(Number_of_traces,Length_of_the_TimeTraces);
    donors=cell([Number_of_traces/2,1]);
    acceptors=cell([Number_of_traces/2,1]);
    DataMatrix(Index_of_SelectedSpots)=Raw_Data(Index_of_SelectedSpots);

    for i=1:(Number_of_traces/2)
       donors{i}=(DataMatrix(i*2-1,:)+(DataMatrix(i*2-1,:)*ChannelLeakage)-Donor_Backgrnd_Correction);   %So this will be a matrix where each column will be the Donor time series of each selected spot of the movie
       acceptors{i}=(DataMatrix(i*2,:)-(DataMatrix(i*2-1,:)*ChannelLeakage)-Acceptor_Backgrnd_Correction); %So this will be a matrix where each column will be the Acceptor time series of each selected spot of the movie
    end

%     blank = questdlg(['Would you like to normalize your data for use in ebFRET?  If so, select "Donor"',...
%         'or "Acceptor" to normalize that channel'],'Normalize?','Neither','Acceptor','Donor','Neither');
% 
%     if blank(1) == 'A'
%         emFRET = emulateFRET(acceptors);
%         plotCut3(1-emFRET,emFRET,length(acceptors),Timeunit);
%     elseif blank(1) == 'D'
%         emFRET = emulateFRET(Donors);
%         plotCut3(1-emFRET,emFRET,length(Donors),Timeunit);



end