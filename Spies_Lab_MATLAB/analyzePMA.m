addpath('Functions'); %Allow access to 'Functions' folder

answer = questdlg('One channel or two channels (FRET)?','One channel or two?','Two Channels','One Channel','Two Channels');

if answer(1) == 'O'
    imageRegions1channel();
else
    imageRegions2channel();
end
