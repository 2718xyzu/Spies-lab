% Joseph Tibbs
% Last updated 7/26/17

answer = questdlg('One channel or two channels (FRET)?','One channel or two?','Two Channels','One Channel','Two Channels');
addpath('Functions');
if answer(1) == 'O'
    imageRegions1channel();
else
    imageRegions2channel();
end
