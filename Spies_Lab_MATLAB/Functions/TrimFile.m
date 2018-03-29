blank = questdlg('Select the folder which contains all traces to cut',...
    'Select folder','Ok','Ok');

path = uigetdir;   

if ispc
    slash = '\';
else
    slash = '/';
end
dir2 = dir([path slash '*.dat']);
clear dir3;
dir3 = { dir2.name };

blank = questdlg('Select or make the folder which the program will save traces to',...
    'Select save folder','Ok','Ok');
path2 = uigetdir;

name = dir2(1).name;
A = fopen([path slash name]);

j = 0;
char = 1;
while char~=10
    j = j+1;
    char = fread(A,1);
end
%j is now the length (in bytes) of each line (assuming all files have the
%same number of bytes in each line...)
indices = inputdlg({'What is the number of the first row you want to include?',...
    'What is the last row you want to include? (Note: units are frames, not seconds)'});
startI = (str2double(indices{1})-1)*j+1;
endI = (str2double(indices{2}))*j;


for i = 1:numel(dir3)
    name = dir2(i).name;  
    A = fopen([path slash name]);
    binaryData = fread(A);
    binaryDataCut = binaryData(startI:endI);
    save([path2 slash name],'binaryDataCut');
    B = fopen([path2 slash name],'wb');
    frewind(B);
    fwrite(B,binaryDataCut,'uint8');
    fclose(B);
    fclose(A);
end
