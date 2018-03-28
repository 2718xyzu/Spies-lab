function packagePairsebFRET(numCol)

output = questdlg('Next, please select the folder which has all the txt files you want to convert',...
    'Instructions','OK','Quit','OK');
path = uigetdir;
if ismac
    slash = '/';
elseif ispc
    slash = '\';
else
    slash = '/';
end

dir2 = dir([path slash '*.txt']);
clear dir3;
dir3 = { dir2.name };
for i = 1:length(dir3)
    A = importdata([path slash dir3{i}]);
    if isstruct(A)
        A = A.data;
    end
    intensitySingle(i,2*(1:size(A(:,2),1))-1) = A(:,2)./max(A(:,2)+.01);
    intensitySingle(i,2*(1:size(A(:,3),1))) = A(:,3)./max(A(:,3)+.01);
    
end
plotCut3(1-intensitySingle,intensitySingle,length(intensitySingle),.1);
end