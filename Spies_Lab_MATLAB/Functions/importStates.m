function imported = importStates()
imported = struct;
%Before running this function, first export the single-molecule datasheet
%for your ebFRET analysis by going to File-->Export-->Single-Molecule Data
%Make sure to select the correct number of states
%Save that export file to a convenient location

h = msgbox(['Please select the single-molecule data file from your ebFRET analysis.  You can create this file'...
    ' by clicking File-->Export-->Single-Molecule Data after the ebFRET analysis is complete.'...
    ' Make sure you select to export the correct state number model'], 'modal');
waitfor(h);

[nameFile, pathFile, ~] = uigetfile;

try 
    delete(h);
catch
end

smd = importdata([pathFile nameFile]);
smd = smd.data;

for i = 1:size(smd,2)
    temporary = smd(i).values;
%     temporary = temporary(i);
    imported.states(i,1:length(temporary)) = temporary(:,4);
    imported.fret(i,1:length(temporary)) = temporary(:,3);
    imported.average(i,1:length(temporary)) = temporary(:,5);
end


end