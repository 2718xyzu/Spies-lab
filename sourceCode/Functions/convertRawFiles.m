%This script runs the input and output steps of emFRET without actually
%doing any normalizing.  Its main purpose is to allow a researcher to take
%in files of some raw data type (dat files, .traces) and export in one of
%the other formats for further analysis (HaMMY, ebFRET, hFRET) without any
%changes being made to the data.  Mainly this is useful for hFRET because
%it requires all of your traces be compiled into a single file with all
%traces padded to the same length.


lastwarn('');
addpath('Functions');
[warnMsg, warnId] = lastwarn;
if ~isempty(warnMsg)
    questdlg(['Functions directory not found; please select the Spies-lab '...
        'scripts directory to add it to the search path'],'Select search dir',...
    'Ok','Ok');
    cd(uigetdir);
    addpath('Functions');
end

channels = inputdlg(['How many channels does your data have?  Any FRET data '...
    'only counts as one channel, since for post-processing purposes the donor and '...
    'acceptor are combined into one trajectory.  If you do have FRET data, make '...
    'sure to select the column which contains it when prompted.']);
channels = str2double(channels);
[intensity,fileNames] = openRawData(channels);

for c = 1:channels
    saveEmFret(intensity{c},c, fileNames);
end

