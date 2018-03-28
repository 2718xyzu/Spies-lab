%Joseph Tibbs
%Last updated: 8/16/17

%close all;
%This script was rewritten as a function to allow it to be called by
%'analyzepma'
%It analyzes pma files which are two-channel or trajectories which are
%2-color


function imageRegions2channel()
%dbstop if error;

load('Gauss.mat');
answer = questdlg('Do you have previously analyzed intensities files you wish to upload? If yes, you will be prompted to open a file; open the donor file first');
%If there was a previously-saved intensities file, it will open, and the
%variables 'intensityA' and 'intensityD' will exist in the workspace.  The program will skip
%to the plotting and cutting function
if answer(1) == 'Y'
        h = msgbox('Click OK and select Donor intensity file','modal');
        uiopen;
        h = msgbox('click OK and select Acceptor intensity file','modal');
        uiopen;
        try
        delete(h);
        catch
        end
%         path = strjoin(inputdlg('Input path to donor intensities file, terminated with a slash'));
%         fileName = strjoin(inputdlg('Input donor intensity file name with extension'));
%         load([path fileName]);
%         path = strjoin(inputdlg('Input path to acceptor intensities file, terminated with a slash'));
%         fileName = strjoin(inputdlg('Input acceptor intensity file name with extension'));
%         load([path fileName]);
        timeUnit = str2double(strjoin(inputdlg('Type time unit of movie, in seconds, i.e. .1 or .030 \n Default is .1 \n')));
        if isnan(timeUnit)
            timeUnit = .1;
        end
         frames = size(intensityA,2);
         plotCut2(intensityD,intensityA,frames,timeUnit); %Skip to plotting and cutting
%     end
else


[A, fileName] = openFile(); %Old file-open function to get file ID, A
timeUnit = str2double(strjoin(inputdlg('Type time unit of movie, in seconds, i.e. .1 or .030 \n Default is .1 \n')));
if isnan(timeUnit)
    timeUnit = .1;
end
% donorIntensity = input('Type donor intensity \n Default for Cy3 is 1.7 \n');
% if isempty(donorIntensity)
%     donorIntensity = 1.7;
% end
% acceptorIntensity = input('Type acceptor intensity \n Default for Cy5 is 4.2 \n');
% if isempty(acceptorIntensity)
%     acceptorIntensity = 4.2;
% end

channelLeakage = str2double(strjoin(inputdlg('Type channel leakage \n Default is .07 \n')));
if isnan(channelLeakage)
    channelLeakage = .07; %This value is for our particular setup; if you want to change the default, change this value (and in the message above)
end
sizeX = fread(A,1,'uint16'); %The first two bytes of a pma file are always the number of pixels along the x dimension
sizeY = fread(A,1,'uint16'); %and the next two bytes are the size along the y dimension
frames = 0;
while ~feof(A) %quickly scan file to determine number of frames
    fread(A,512*512,'uint8');
    frames = frames + 1;
end
frames = frames - 1;
fseek(A,4,-1); %Rewind file to almost the beginning
frame1 = zeros(512,512,frames,'uint8');
%Vectorized reading of file:
frame1(:,:,:) = permute(reshape(fread(A,512*512*frames,'uint8'),512,512,frames),[2 1 3]);
%frame1 now contains the movie data, with the first and second dimensions
%being spatial and the third dimension being time
rawCombined = mean(frame1,3);
%Ensure that we keep an unadjusted copy of the frame:
frame2 = frame1;

thresholdAnswer = inputdlg({['Input spacing strictness value. Lower values allow closer dots to '...
    'be counted.  Higher values will exclude more dots'],['Input minimum brightness value for the left side.  Increasing'...
    ' this value will exclude more dim dots.'],'Input new minimum brightness value for the right side'},...
    'Input Thresholds', 1, {'5','3','3'});
%Spacing strictness can be any floating point number greater than zero, and
%it is roughly the minimum allowable distance, in pixels, between any two dots
%minimumBrightness thresholds (also floating point > 0) allow the program to determine
%what is a valid bright spot on the slide.  You should make the
%brightness thresholds match your slide brightness, i.e. our microscope
%always made the right side dimmer, so that threshold we typically set lower.  

spacingStrictness = str2double(thresholdAnswer{1});
minimumBrightnessR = str2double(thresholdAnswer{2});
minimumBrightnessL = str2double(thresholdAnswer{3});

% 
% minimumBrightnessL = 5;
% minimumBrightnessR = 3;
% spacingStrictness = 5;

reAdjust = 1;

%The following loops will iterate more than once if you want to change your
%thresholds (that's what they are there for), but your mapping file will
%presumably not change, so you select it here, before the loops start.
%Only the location/name of the file are saved, to be used later on.
answer = questdlg('Please selet your mapping file','Input pma','OK','Quit','OK');
[fileNameMap, path,~] = uigetfile({'*.pma','*.mat'},'Select pma mapping movie');
mapFile = [path fileNameMap];

%If we need to readjust the frame and run the region analysis again:
while reAdjust
frame1 = frame2;
%frameAdjust takes the portion of the frame fed to it (we separate the left
%and the right) and outputs a combinedI (a time-average of each pixel), a
%binary (BW) image, where white spots are possible dot locations, and an
%adjusted frame, which is the entire movie corrected for background noise.
[combinedIL, BWL, adjustedL] = frameAdjust(frame1(:,1:256,:),minimumBrightnessL);
[combinedIR, BWR, adjustedR] = frameAdjust(frame1(:,257:512,:),minimumBrightnessR);
%[leftI,avgL,maxL] = imageAdjust(frame1(:,1:256,:),1,0);  %Will be replaced by above line
%[rightI,avgR,maxR] = imageAdjust(frame1(:,257:512,:),1,0);
%Concatenate the results:
frame1 = cat(2,adjustedL,adjustedR);
combinedI = cat(2,combinedIL,combinedIR);
BW = cat(2,BWL,BWR); 
clear adjustedL;
clear adjustedR;
% trueAverageI = mean(mean(mean(combinedI)));
% leftAverageI = mean(mean(mean((leftI))));
% rightAverageI = mean(mean(mean(rightI)));
% 
% leftI = (leftI-leftAverageI).*(uint8((leftI-leftAverageI)>0));
% rightI = (rightI-rightAverageI).*(uint8((rightI-rightAverageI)>0));
% 
% combinedI(:,1:256) = squeeze(sum(leftI(:,:,:),3)/frames);
% combinedI(:,257:512) = squeeze(sum(rightI(:,:,:),3)/frames);
% combineToBW(:,1:256) = squeeze(sum(leftI(:,:,:),3)/frames);
% combineToBW(:,257:512) = leftAverageI/rightAverageI*squeeze(sum(rightI(:,:,:),3)/frames);

I = combinedI; %I is for display purposes only

%BW = cat(2,generateBW(frame1(:,1:256,:),1:frames),generateBW(frame1(:,257:512,:),1:frames)); %Generates binary image for each half, concatenates them
%s is a structure containing the location, maximum intensity, and area of each
%white region in the binary image.
s = regionprops(BW, combinedI, {'WeightedCentroid', 'MaxIntensity', 'Area'});
figure(1);
imshow(I,[0,max(I(:))]);
hold on;
numObj = numel(s);
s1 = zeros(numObj,2);

for k = 1 : numObj %Locate dots
%     plot(s(k).WeightedCentroid(1), s(k).WeightedCentroid(2), 'bo');
    s1(k,1) = s(k).WeightedCentroid(1);
    s1(k,2) = s(k).WeightedCentroid(2);

    allDots(k,1) = s1(k,1);
    allDots(k,2) = s1(k,2);
end

% answer = questdlg('Please selet your mapping file','Input pma','OK','Quit','OK');
% 
% [fileName, path,~] = uigetfile({'*.pma','*.mat'},'Select pma mapping movie');
% 
% mapFile = [path fileName];
rePair = 1;

%The following loop filters out any 'bad' dots, and then pairs up dots from
%one side to the other, ultimately only keeping dots which have a
%corresponding dot on the other side.  This is where the map file is used
while rePair
% display('Showing regions...');
% figure(1);
% figure(4);
% imshow(I);
% statusList = partitionNeighborhoods(s1(:,1),s1(:,2),spacingStrictness,[512 512],numObj); 
%The above line detects dots too close to one another
%In the function, the third argument determines strictness (dots within 'x' pixels are removed)
gauss = 0;
%If the above variable is 1, then the following script roughly fits each
%dot to a gaussian distribution, to ensure that it is a good quality dot
%(and not two dots merged into one, or noise, or a speck of dust)
if gauss==1;
    [xDataGauss,yDataGauss,err] = compareGauss(s1(:,1), s1(:,2), combinedI, Gauss);
    %Find the rough center of each peak as described by a Gaussian function
    allDots = [xDataGauss' yDataGauss' err' ];
    gaussCutoff = 2.5*std(err)+mean(err);
% elseif gauss == 2
%     [xS1,yS1] = meshgrid(1:5,1:5);
%     xS = xS1(:);
%     yS = yS1(:);
%     simpleGauss = (@(x,y) exp(-(3-x).^2-(3-y).^2));
%     weights = simpleGauss(xS,yS);
%     weights(13) = .5;
%      gaussFit = fittype(@(c,w,a,b,x,y) c*exp(-((x-a).^2+(y-b).^2)/w),...
%       'coefficients',{'c','w','a','b'}, 'dependent',{'z'},'independent',{'x','y'});
%      fo = fitoptions('Method','NonlinearLeastSquares','Lower',[0,.5,1.5,1.5],...
%      'Upper',[150,2,4.5,4.5],'StartPoint',[30,1,3,3],'Weights',weights);
%     for i = 1:size(s1,1)
%         x1 = round(s1(i,1));
%         y1 = round(s1(i,2));
%         try
%             zS(:,:,i) = mean(frame1(y1-2:y1+2,x1-2:x1+2,:),3);
%         catch
%             zS(:,:,i) = ones(5,5);
%         end
%     end
%     for i = 1:size(s1,1)
%         [xData(i),yData(i),cData(i),wData(i),gof(i)] = getGauss(0,gaussFit,fo,50,xS,yS,zS(:,:,i));
%     end
%     allDots = [(round(xData')-3+s1(1:length(xData),1)) (round(yData')-3+s1(1:length(yData),2)) gof' ]; %Needs to add back in original coordinates
else
    %otherwise, ignore the gaussCutoff
    gaussCutoff = inf;
    err = ones(size(allDots));

end

statusList = partitionNeighborhoods(allDots(:,1),allDots(:,2),spacingStrictness,[512 512],numObj); 
%Flag every dot with a 1 in their 'statusList' entry iff they are within
%the same 'neighborhood' as another dot, where neighborhoods are defined as
%a set of four overlapping grids, the grid spacing equal to 'spacingStrictness' pixels
validDots = zeros(1,3); %Columns: x, y, MaxIntensity
i = 1;
areaCutoff = prctile([s(:).Area],98); %Dots which are too large are likely noise
intensityCutoff = prctile([s(:).MaxIntensity],99.6); %as are dots which are too bright

for k = 1: numObj %Throw out junk dots with a series of conditionals
    if statusList(k) == 0; %All dots which are too close to another dot get marked in statusList as "1"
        if s1(k,1) < 508 && s1(k,1) > 4 && s1(k,2) < 508 && s1(k,2) > 4 && abs(s1(k,1)-256)>4 %They are not too close to an edge
            if s(k).Area < areaCutoff
                if s(k).MaxIntensity < intensityCutoff
                    if err(k) < gaussCutoff 
                        %record the information of all good dots
                        validDots(i,1:3) = [allDots(k,1), allDots(k,2), s(k).MaxIntensity(1)];
                        i = i+1;
                    end
                end
            end
        end
    end
end
% figure(2);
% hold on
% %for i = 1 : size(validDots) %Locate dots
%     plot(validDots(:,1), validDots(:,2), 'ro');
%end
%figure(2);


[~,pairs] = getMapping(combinedI,s,validDots,mapFile); %map each dot to another dot
%The previous function uses the mapFile already inputted to determine which
%dots should map to each other, and then attempts to pair every dot on the validDots
%list with another dot on that list.  Only dots with a single corresponding
%dot will be included in the 'pairs' list.

disp(['There were ' num2str(length(pairs)) ' good pairs of dots']);

figure(1);
close 1;
figure(4);
close 4;
figure(4);
imshow(I,[0,max(I(:))]);
hold on
plot(validDots(pairs(:,1),1), validDots(pairs(:,1),2), 'go');
plot(validDots(pairs(:,2),1), validDots(pairs(:,2),2), 'go');
figure(4);
inpuT = input('Paused to allow viewing of dots.  Press enter in the command line to continue');
%waiting for user input pauses the program, while still allowing the user
%to interact with the figure which is showing them which dots were selected

answer1 = questdlg(['All good dots are plotted in green.  There were ' num2str(length(pairs)) ' good pairs, with a spacing strictness of ' ...
    num2str(spacingStrictness) ' and a minimum brightness of ' num2str(minimumBrightnessL) ...
    ' on the left and ' num2str(minimumBrightnessR) ' on the right.  Would you like to input different thresholds to get more or fewer dots?']);

if answer1(1) == 'Y'
    thresholdAnswer = inputdlg({['Input new spacing strictness value. Lower values allow closer dots to '...
        'be counted.  Higher values will exclude more dots'],['Input new minimum brightness value for the left side.  Increasing'...
        ' this value will exclude more dim dots.'],'Input new minimum brightness value for the right side'},...
        'Input Thresholds', 1, {num2str(spacingStrictness),...
        num2str(minimumBrightnessL),num2str(minimumBrightnessR)});
    spacingStrictnessAns = str2double(thresholdAnswer{1});
    minimumBrightnessRAns = str2double(thresholdAnswer{2});
    minimumBrightnessLAns = str2double(thresholdAnswer{3});
    if minimumBrightnessRAns == minimumBrightnessR && minimumBrightnessLAns == minimumBrightnessL
         %if the only thing that has changed is the spacing strictness, we do
         %not need to re-adjust the image, so we merely 'rePair' dots
        rePair = 1;
        spacingStrictness = spacingStrictnessAns;
    else
        %Otherwise, we need to re-adjust the image, which requires exiting
        %the 'rePair' loop and going back to the beginning of the reAdjust 
        rePair = 0;
        spacingStrictness = spacingStrictnessAns;
        minimumBrightnessR = minimumBrightnessRAns;
        minimumBrightnessL = minimumBrightnessLAns;
    end
else
    %else we just exit both loops
    rePair = 0;
    reAdjust = 0;
end

end

end
pairedDots = zeros(size(pairs,1),2,3);
gauss = 2;
%The next section very precisely locates the center of each dot by fitting
%it to a 'real' Gaussian model, not the simplified model found in the
%earlier gauss section in the reLocate loop.  This is a more time-intensive
%method, but much more precise, which is why it is saved until the
%location and number of dots has already been approved
if gauss ==2;
    [xS1,yS1] = meshgrid(-2:2,-2:2);
    xS = xS1(:);
    yS = yS1(:);
    %We want the values near the center of our distribution to count most
    simpleGauss = (@(x,y) exp(-(x).^2-(y).^2));
    weights = simpleGauss(xS,yS);
    weights(13) = .5;
     gaussFit = fittype(@(c,w,a,b,x,y) c*exp(-((x-a).^2+(y-b).^2)/w),...
      'coefficients',{'c','w','a','b'}, 'dependent',{'z'},'independent',{'x','y'});
     fo = fitoptions('Method','NonlinearLeastSquares','Lower',[0,.5,-1.5,-1.5],...
     'Upper',[150,2,1.5,1.5],'StartPoint',[30,1,0,0],'Weights',weights);
    numPairs = size(pairs,1);
    for i = 1:numPairs
        pairedDots(i,1,1:2) = validDots(pairs(i,1),1:2);
        pairedDots(i,2,1:2) = validDots(pairs(i,2),1:2);
    end
    for i = 0:size(pairs,1)*2-1
        %Get the appropriate 'slice' of the matrix for each dot by using
        %the nearest integer coordinate
        x1 = round(pairedDots(mod(i,numPairs)+1,floor(1+i/numPairs),1));
        y1 = round(pairedDots(mod(i,numPairs)+1,floor(1+i/numPairs),2));
        %Store the integer part of each position; the precise fractional
        %part will be calculated and then added in later
        validX(i+1) = x1;
        validY(i+1) = y1;
        try
            zS(:,:,i+1) = mean(frame1(y1-2:y1+2,x1-2:x1+2,:),3);
        catch
            zS(:,:,i+1) = ones(5,5);
        end
    end
    clear xData;
    clear yData;
    for i = 1:size(zS,3)
        %The following line calculates the fractional part of the center position 
        %and goodness of fit for each dot
        [xData(i),yData(i),~,~,gof(i)] = getGauss(0,gaussFit,fo,50,xS,yS,zS(:,:,i));
    end
    for j = 1:size(pairedDots,1)
        pairedDots(j,1,1:3) = [xData(j)+validX(j),yData(j)+validY(j),gof(j)];
    end
    for j = 1:size(pairedDots,1)
        k = size(pairedDots,1)+j;
        %Add back in the integer part of the location of each dot
        pairedDots(j,2,1:3) = [xData(k)+validX(k),yData(k)+validY(k),gof(k)];
    end
    
end


intensityD = zeros(size(pairedDots,1),frames); 
%Record each dot's intensity (essentially a weighted average of the pixels
%surrounding the dot)
for j = 1:length(pairedDots)
    x0 = pairedDots(j,1,1);
    y0 = pairedDots(j,1,2);
    x1 = round(x0);
    y1 = round(y0);
    slice = double(frame1(y1-2:y1+2,x1-2:x1+2,:));
    intensityD(j,:) = getIntensity(slice, x0, y0);
end

intensityA = zeros(size(pairedDots,1),frames); %Record each dot's intensity
for j = 1:length(pairedDots)
    x0 = pairedDots(j,2,1);
    y0 = pairedDots(j,2,2);
    x1 = round(x0);
    y1 = round(y0);
    slice = double(frame1(y1-2:y1+2,x1-2:x1+2,:));
    intensityA(j,:) = getIntensity(slice, x0, y0);
end
% C = 1/(1-channelLeakage^2);

%Correct for channel leakage using accepted formula:
tempD = (1+channelLeakage)*intensityD;
tempA = intensityA-channelLeakage*intensityD;
intensityD = tempD;
intensityA = tempA;


choice = questdlg('Would you like to save your intensities files as matlab variables before continuing?');

if choice(1)=='Y'
    uisave('intensityD',[num2str(fileName) '_intensityD_' datestr(now,1) '.mat']);
    uisave('intensityA',[num2str(fileName) '_intensityA_' datestr(now,1) '.mat']);
end


%Allow the user to view the trajectories and save/cut the good ones:
plotCut2(intensityD,intensityA,frames,timeUnit);


% 
% 
% for i = 1:frames
%     frame1i = frame1(:,:,i);
%     for j = 1:length(pairs);
%         x0 = validDots(pairs(j,1),1);
%         y0 = validDots(pairs(j,1),2);
%         intensity = 0;
%         for i1 = -2:2
%             for i2 = -2:2
%                 if round(y0)+i2 > 0 && round(x0)+i1 > 0 && round(y0)+i2 < 513 && round(x0)+i1 < 513
%                 patch = frame1(round(y0)+i2,round(x0)+i1,i);
%                 intensity = intensity + double(patch*exp(-(abs(-i1+x0)-round(x0))^2-(abs(-i2+y0)-round(y0))^2));
%                 end
%             end
%         end
%         intensityD(j,i) = intensity;
%     end
% end
% 
% intensityA = zeros(length(pairs),frames); %Record each dot's intensity
% for i = 1:frames
%     for j = 1:length(pairs);
%         x0 = validDots(pairs(j,2),1);
%         y0 = validDots(pairs(j,2),2);
%         intensity = 0;
%         for i1 = -2:2
%             for i2 = -2:2
%                 if round(y0)+i2 > 0 && round(x0)+i1 > 0 && round(y0)+i2 < 513 && round(x0)+i1 < 513
%                 patch = frame1(round(y0)+i2,round(x0)+i1,i);
%                 intensity = intensity + double(patch*exp(-(abs(-i1+x0)-round(x0))^2-(abs(-i2+y0)-round(y0))^2));
%                 end
%             end
%         end
%         intensityA(j,i) = intensity;
%     end
% end

% intensitiesAdj = intensityD;
% for j = 1:numObj
%     for i = 4:frames-4
%         intensitiesAdj(j,i) = .27*(intensityD(j,i-1)+intensityD(j,i+1))+.15*(intensityD(j,i-2)+intensityD(j,i+2))+.08*(intensityD(j,i-3)+intensityD(j,i+3));
%     end
% end

% 
% figure(2);
% axis([0 100 0 1500]);
% for i = 1:15 
%     figure(2);
%     hold on;
%     comet(1:100,intensities(randi(400),:))
% end
% intensitiesAdj = intensities;
% for j = 1:numObj
%     for i = 4:frames-4
%         intensitiesAdj(j,i) = .27*(intensities(j,i-1)+intensities(j,i+1))+.15*(intensities(j,i-2)+intensities(j,i+2))+.08*(intensities(j,i-3)+intensities(j,i+3));
%     end
% end
% figure(3);
% hold on;
% axis([0 100 0 1500]);
% for i = 1:15 
% comet(1:100,intensitiesAdj(randi(400),:))
% figure(3);
% hold on;
end

%For debugging purposes only (in case you want to debug the program after
%it is finished running)
answer = questdlg('Do you want to quit the program now?');
if answer(1) == 'N'
    dbstop if error
    stop;

end

end