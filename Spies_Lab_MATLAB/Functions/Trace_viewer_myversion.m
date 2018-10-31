% Written by Digvijay Singh  ( dgvjay@illinois.edu)
% Modified by Shyamal Subramanyam (subrama9@illinois.edu)
% This script will let you the single molecule traces from the .traces file
% After entering the required information initially.
% It will sift through each trace present in the analysed movie file ( .traces file)
% and you can decide to SAVE THEM in different ways...read on to
% understand or simply RUN this script and you will know everything

% close all;
%clear all;
% fclose('all');

% Directory_of_TracesFiles=input('Please enter the full name of the directory which has the traces file you want to analyse :: \n');
% cd(Directory_of_TracesFiles);

% This script assumes that the .traces file in the folder(input above) is
% in the following order in your directory
% like hel1.traces...hel2.traces...  % The single molecule information post IDL analysis is stored in the .traces file
% for each movie analysed.hel3.traces
function Trace_viewer_myversion()

    GenericFileType='.traces';
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
    ChannelLeakage=str2double(input('Enter the value of the Channel Leakage (Default is 0.07) ? :','s'));
        if isempty(ChannelLeakage)
           ChannelLeakage=0.07;
        end
    Donor_Backgrnd_Correction=str2double(input('Enter the Donor Background Value (Default 0):','s'));
        if isempty(Donor_Backgrnd_Correction)
           Donor_Backgrnd_Correction=0;
        end
    Acceptor_Backgrnd_Correction=str2double(input('Enter the Acceptor Background Value (Default 0):','s'));
        if isempty(Acceptor_Backgrnd_Correction)
           Acceptor_Backgrnd_Correction=0;
        end
    GammaFactor=str2double(input('Enter Gamma Factor (Default 1):','s'));
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
    Donors=zeros(Number_of_traces/2,Length_of_the_TimeTraces);
    Acceptors=zeros(Number_of_traces/2,Length_of_the_TimeTraces);
    DataMatrix(Index_of_SelectedSpots)=Raw_Data(Index_of_SelectedSpots);

    for i=1:(Number_of_traces/2)
       Donors(i,:)=(DataMatrix(i*2-1,:)+(DataMatrix(i*2-1,:)*ChannelLeakage)-Donor_Backgrnd_Correction);   %So this will be a matrix where each column will be the Donor time series of each selected spot of the movie
       Acceptors(i,:)=(DataMatrix(i*2,:)-(DataMatrix(i*2-1,:)*ChannelLeakage)-Acceptor_Backgrnd_Correction); %So this will be a matrix where each column will be the Acceptor time series of each selected spot of the movie
    end

    blank = questdlg(['Would you like to normalize your data for use in ebFRET?  If so, select "Donor"',...
        'or "Acceptor" to normalize that channel'],'Normalize?','Neither','Acceptor','Donor','Neither');

    if blank(1) == 'A'
        emFRET = emulateFRET(Acceptors);
        plotCut3(1-emFRET,emFRET,length(Acceptors),Timeunit);
    elseif blank(1) == 'D'
        emFRET = emulateFRET(Donors);
        plotCut3(1-emFRET,emFRET,length(Donors),Timeunit);
    else

    TimeSeries=(0:(Length_of_the_TimeTraces-1))*Timeunit;

    plotCut2(Donors,Acceptors,size(Donors,2),Timeunit);

    % TracesCounter = randi(40);
    % FRET_Time_Series=(Acceptors(TracesCounter,:)./(Acceptors(TracesCounter,:)+(GammaFactor*(Donors(TracesCounter,:)))));
    % figure(2);
    % plot(TimeSeries,FRET_Time_Series,'LineWidth',1.0,'Color','b');
    % figure(3);
    % cd('\\128.255.119.15\Summer Guests 2017\MATLAB Programs');
    % FRET_Integrated_Series = integrate_FRET(FRET_Time_Series);
    % plot(TimeSeries,FRET_Integrated_Series,'LineWidth',1.0,'Color','b');


    %TimeSeries is nothing but the index of each frame event in the series.
    % Suppose you made a movie which is 10 seconds long, if the frame rate was 100ms. It means you have collected
    %     10/0.1 ==100 frames. TimeSeries is simply a series from 1 to 100 where index 1 would correspond to first frame
    %     index 2 would correspond to frame2 and index 3 would correspond to frame numbrr 3 and so on and each frame number
    %     would have a particular intensity for the spot in the Green channel and the red channel.

    TracesCounter=0;
    %Now we will be going over the trace one by one to select them or whatever

    % while TracesCounter < Number_of_traces/2 || choice ~= 6
    %    close all;
    %    TracesCounter = TracesCounter + 1 ;
    %
    %    figure;
    %    subplot(2,1,1);
    %    %Simply plotting the Donor and the Leakage Corrected Acceptor
    %    TimeSeries=(0:(Length_of_the_TimeTraces-1))*Timeunit;
    %    plot(TimeSeries,Donors(TracesCounter,:),'LineWidth',1.5,'Color','g');
    %    hold
    %    plot(TimeSeries,(Acceptors(TracesCounter,:)),'LineWidth',1.5,'Color','r');
    %    %Turn the below on if you also want to see the total intensity time series( i.e.
    %    %Acceptor Plus Donor)
    %    legend({'Donor Intensity ','Acceptor Intensity'},'FontSize',8,'FontWeight','bold')
    %    xlabel('Time(s)');
    %    ylabel('Intensity ( a.u.)');
    %    %plot(TimeSeries,Acceptors(TracesCounter,:)+Donors(TracesCounter,:),'k');
    %    TitleNameForThePlot=sprintf('Molecule Number %d of the file %s',TracesCounter,TheFileThatWillbeAnalysed);
    %    title(TitleNameForThePlot); % Giving the title name to the plot as described above
    %    subplot(2,1,2);
    %    %Simply plotting the  FRET traces now in a subplot below the above plot.
    %    FRET_Time_Series=(Acceptors(TracesCounter,:)./(Acceptors(TracesCounter,:)+(GammaFactor*(Donors(TracesCounter,:)))));
    %    TitleNameForThePlot=sprintf('Molecule Number %d of the file %s',i,TheFileThatWillbeAnalysed);
    %    plot(TimeSeries,FRET_Time_Series,'LineWidth',1.0,'Color','b');
    %    xlabel('Time(s)');
    %    ylabel('FRET Efficiency');
    %    ylim ([-0.2 1.2]);
    %    set(gca, 'YTick', [-0.2 0 0.25 0.5 0.75 1.0 1.2]);
    %    grid On;
    %
    %
    %
    %    % Now the particular trace has been plotted completely, we now can
    %    % decide what we want to do with the trace.
    %
    %    % You can choose to
    %
    %     %  PRESS 1.
    %     %  Save the trace as it is....( At this point it will output a .dat file in the same folder
    %     %  % where the first column will be Time
    %     %  the second column will be corrected donor intensitty
    %     %  the third column will be corrected acceptor intensity
    %     % (PLEASE NOTE THAT THIS .DAT file's donor and acceptor values will  be corrected for leakage or additional
    %     %  background.).
    %     % YOU MAY CHOOSE TO CHANGE THAT BY CHANGING THE CODING HERE.
    %
    %
    %
    %     % PRESS 3.
    %     % Sometimes you may want to use only a portion of the entire single
    %     % molecule trace and discard the rest ( for e.g. removing the single
    %     % step photobleaching event or remove the weird intensity fluctuation
    %     % regions)
    %     % In that case you can manually cut out the portion of the trace which is good and relevant and can
    %     % be used for your studies.
    %
    %     % For cutting out the trace, all you have to do is make two clicks.
    %     % The first click will be the starting point of where you want to induce the cut and the second click will be the
    %     % end point
    %
    %     % You may want to make more cuts than just 1 and the script allows you
    %     % do to that. If you keep pressing 0 after pressing 3...then it will
    %     % keep letting you make more cuts and all of those cuts will be stored
    %     % separately in the same format.
    %
    %     % If you want to stop making the cuts, then simply press 1 after making
    %     % the required number of cuts.
    %
    %
    %     % PRESS 0 to go back and look at the previous traces that have gone by
    %     % and you can choose to press 1 or 3 over them again to select them
    %
    %
    %     % PRESS 4 to save the trace in a picture file. You can use this for
    %     % meeting or your personal records.
    %     % if you want to save the trace in both .DAT format as well as save
    %     % image of it...just press 1 or 3 once to save the .DAT file of the
    %     % trace and then go back to the same trace again by pressing 0 and now
    %     % press 4 to save it's image....simple !
    %
    %     %PRESS 5 to go to a trace number in particular. This is helpful when
    %     %you have already glanced through your data and know the trajectories
    %     %you need to analyze.
    %
    %     %PRESS 6 to exit the program
    %
    %    choice=input('press 1 to save the trace as it is and 3 to cut out the part of the trace to save \n Press 0 to go back one trace \n Press 5 to go to a particular trajectory \n Just press Enter without anything to move to the next trace. \n press 6 to exit');
    %
    %     % Making this choice will simply save the entire trace in its format
    %     % where the first column will be Time
    %     % the second column will be corrected donor intensitty
    %     % the third column will be corrected acceptor intensity
    %      if choice==1
    %       TheFileThatWillbeAnalysed_truncated=TheFileThatWillbeAnalysed(1:end-7);
    %       Filename_for_This_Trace=sprintf('%s_Trace_%d.dat',TheFileThatWillbeAnalysed_truncated,TracesCounter);
    %       Output_to_be_saved_inaFile=[TimeSeries()' Donors(TracesCounter,:)' (Acceptors(TracesCounter,:))'];
    %       save(Filename_for_This_Trace,'Output_to_be_saved_inaFile','-ascii') ;
    %      end
    %     % Making this choice will simply cut out the trace...when you specify the region
    %     % The format will be like:
    %     % where the first column will be Time
    %     % the second column will be donor intensitty
    %     % the third column will be raw(non leakage corrected) acceptor intensity
    %      if choice==3
    %       TheFileThatWillbeAnalysed_truncated=TheFileThatWillbeAnalysed(1:end-7);
    %       disp('Click twice to select the range which you want to cut out\n Please remember you can cut out multiple parts from a single trace \n Keep pressing 0 if you want to keep cutting traces \n Press a non zero value to stop that process and to move to next trace');
    %       Done_Cutting_Choice=0;
    %       Cut_Counter=0;
    %       while Done_Cutting_Choice ==0
    %            Cut_Counter=Cut_Counter+1;
    %            [x,y]=ginput(2);  % Make Two clicks to specify a region which you want to cut out.
    %            x(1)=round(x(1)/Timeunit); % Starting point of the cut region
    %            x(2)=round(x(2)/Timeunit); % End point of the cut region
    %            %Only the timeseries and the corresponding Donor and Acceptor intensity falliny betwee the above
    %            %two points will be stored now, the rest will not be stored.
    %            Filename_for_This_Trace=sprintf('%s_Trace_%d_CutCount_%d.dat',TheFileThatWillbeAnalysed_truncated,TracesCounter, Cut_Counter);
    %            %Output_to_be_saved_inaFile=[TimeSeries(x(1):x(2))' Donors(TracesCounter,x(1):x(2))' (Acceptors(TracesCounter,x(1):x(2)))'];
    %            %To enable FRET value output alongwith the change line 216
    %            Output_to_be_saved_inaFile=[TimeSeries(x(1):x(2))' Donors(TracesCounter,x(1):x(2))' (Acceptors(TracesCounter,x(1):x(2)))' FRET_Time_Series(x(1):x(2))'];
    %            save(Filename_for_This_Trace,'Output_to_be_saved_inaFile','-ascii') ;
    %            % Asking you whether you want to keep cutting the trace or want
    %            % to move on to the NEXT set of traces.
    %            Done_Cutting_Choice=input('Are you done cutting out traces..Press 0 to continue cutting the same trace \n. Press 1 to move to the next trace  ?');
    %       end
    %      end
    %
    %      % If you press 0 once it will let you go back to a previous trace that
    %      % has gone by...keep pressing this to keep going back in traces that
    %      % have gone by.
    %      if choice==0
    %       TracesCounter=TracesCounter - 2;
    %      end
    %
    %      % If you press 4....it will save the trace in a picture file. You can use this for
    %      % meeting or your personal records...
    %      % if you want to save the trace in both .DAT format as well as save
    %      % image of it...just press 1 or 3 once to save the .DAT file of the
    %      % trace and then go back to the same trace again by pressing 0 and now
    %      % press 4 to save it's image....simple !
    %      if choice==4
    %       TheFileThatWillbeAnalysed_truncated=TheFileThatWillbeAnalysed(1:end-7);
    %       FilenameForTheImage_Saving=sprintf('%s_Trace_%d.png',TheFileThatWillbeAnalysed_truncated,TracesCounter);
    %       print(FilenameForTheImage_Saving,'-dpng','-r500');
    %      end
    %
    %      %PRESS 5 to go to the trajectory in particular.
    %       if choice==5
    %          mol= input('which molecule do you choose  ');
    %         TracesCounter=mol - 1;
    %     end
    % end
    % close all;
    % clear all;




    % This will zip all the traces that you wished to convert into pictures.
    % Prevents the cluttering of too many files in a folder
    % zip('Selected Traces in Images','*.png');
    % delete('*.png');


    % This will zip all the traces that you selected and saved in the .DAT file format.
    % Prevents the cluttering of too many files in a folder
    % zip('Selected Traces in DAT files','*.dat');
    % delete('*.dat');


    end
end
