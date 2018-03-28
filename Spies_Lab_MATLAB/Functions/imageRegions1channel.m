%Joseph Tibbs
%Last updated: 9/22

%close all;

%This program was rewritten as a function to allow it to be called by
%'analyzepma'
%It analyzes pma files which are one-channel, trajectories which are
%single-color, or trajectories which have been normalized to emulate FRET
%values (referred to as emFRET trajectories)

function imageRegions1channel(intensities)
load('Gauss.mat');
answer = questdlg('Do you have a previously analyzed intensities file you wish to upload?  If yes, you will be prompted to open it');
%If the user has already analyzed intensities, they can input it here to
%skip to the plotting and cutting portion of the program.
if answer(1) == 'Y'
%     if exist('intensities','var')
%         answer1 = questdlg('Do you want to use the currently loaded intensities?');
%         if answer1(1) == 'Y'
%             timeUnit = str2double(strjoin(inputdlg('Input duration of each frame (.1 for 100 ms)')));
%             frames = size(intensities,2);
%             plotCut(intensities,frames,timeUnit);
%         else
%             path = strjoin(inputdlg('Input path to intensities file, terminated with a slash'));
%             fileName = strjoin(inputdlg('Input file name with extension'));
%             load([path fileName]);
%             timeUnit = str2double(strjoin(inputdlg('Input duration of each frame (.1 for 100 ms)')));
%             frames = size(intensities,2);
%             plotCut(intensities,frames,timeUnit);
%         end
%     else
        uiopen; %Open matlab file, previously saved, containing intensities
        timeUnit = str2double(strjoin(inputdlg('Type time unit of movie, in seconds, i.e. .1 or .030 \n Default is .1 \n')));
        if isnan(timeUnit)
            timeUnit = .1;
        end
        if exist('emFRET','var') %if they opened it in the 'emFRET' form
            intensities = emFRET;
        end
        frames = size(intensities,2); %Intensities is an mxn array, where m=number of trajectories and n=number of frames
        if exist('emFRET','var') %if they opened it in the 'emFRET' form
        plotCut2(1-emFemRET,emFRET,frames,timeUnit); %Skip to plotting func.
        else
        plotCut(intensities,frames,timeUnit); %Skip to plotting func.
        end
%     end
else


[A,fileName] = openFile(); %Old function used to get file id
            timeUnit = str2double(strjoin(inputdlg('Type time unit of movie, in seconds, i.e. .1 or .030 \n Default is .1 \n')));
            if isnan(timeUnit)
                timeUnit = .1;
            end
answer = questdlg('Analyze Left side or Right side?','Left or Right?','Left','Right','Left');
side = answer(1)=='L';
sizeX = fread(A,1,'uint16'); %the first 16 bits of a pma file always contains the pixels on the X dimension
sizeY = fread(A,1,'uint16'); %And the next 16 bits contain the pixels along the Y dimension
frames = 0;
while ~feof(A) %Scan file quickly to see how many total frames there are
    fread(A,sizeX*sizeY,'uint8');
    frames = frames + 1;
end 
frames = frames - 1;
fseek(A,4,-1); %Go back to (almost) the beginning, 4 bytes in
frame1 = zeros(512,512,frames,'uint8'); %for now, we assume 512x512
%frame1 is the movie data with each frame as a slice along the 3rd dimension
%Vectorized reading of file:
frame1(:,:,:) = permute(reshape(fread(A,512*512*frames,'uint8'),512,512,frames),[2 1 3]);
%The permute is necessary because the data is originally transposed along
%the first and second dimensions, so they must be swapped
if ~side
    frame1(:,1:256,:) = frame1(:,257:512,:);
    disp('left side has been deleted and right side copied over to replace it');
end

%Initialize a few variables with default values:
rawCombined = mean(frame1,3);
frame2 = frame1;
minimumBrightness = 5;
spacingStrictness = 5;
reAdjust = 1;

while reAdjust 
    frame1 = frame2; %save a copy of your original frame, so it is not overwritten
%frameAdjust creates a Black-and-white (binary) image called BW; all white
%spots are possible dot locations.  combinedI is just the time-average of
%each pixel.  adjustedL is one half of the frame (the half to be analyzed)
%adjusted for background
[combinedI, BW, adjustedL] = frameAdjust(frame1(:,1:256,:),minimumBrightness);
frame1(:,1:256,:) = adjustedL;
% [leftI,avgL,maxL] = imageAdjust(frame1(:,1:256,:),1,0);
% combinedI = squeeze(sum(frame1(:,1:256,:),3)/frames);
I = 2*uint8(squeeze(adjustedL(:,:,1)));
%I is for display purposes only and otherwise unnecessary
% BW = generateBW(frame1(:,1:256,:),1:frames);
%s is a structure containing information about each "region" or white spot
%in the binary image BW.  The weighted centroid is an approximate guess for
%the center of the dot, and the maximum intensity is the maximum pixel
%value from combinedI that is within the area of each region.  
s = regionprops(BW, combinedI, {'WeightedCentroid', 'MaxIntensity', 'Area', 'MajorAxis', 'MinorAxis'});
figure(1);
imshow(I);
hold on
numObj = numel(s);
s1 = zeros(numObj,2);
for k = 1 : numObj %Locate dots
%     plot(s(k).WeightedCentroid(1), s(k).WeightedCentroid(2), 'bo');
    s1(k,1) = s(k).WeightedCentroid(1);
    s1(k,2) = s(k).WeightedCentroid(2);
end
% display('Showing regions...');
% figure(1);
% figure(4);
% imshow(uint8(floor(combinedI)));

reLocate = 1;
%Th next loop specifically filters dots for quality, throwing out the 'bad' 
%dots, before asking the user if they are satisfied with the dots found
while reLocate

% statusList = partitionNeighborhoods(s1(:,1),s1(:,2),spacingStrictness,[512 256],numObj);

gauss = 1;
if gauss == 1;
[xData,yData,err] = compareGauss(s1(:,1), s1(:,2), combinedI, Gauss);
%Find center of each peak as described by a Gaussian function
%where err is an approximate measure of the goodness of fit (larger err is bad)
allDots = [xData' yData' err' ];
gaussCutoff = 2.5*std(err)+mean(err);
else
    gaussCutoff = inf; %ignore the gauss filter if gauss is set to 0
end
%The next line essentially flags all dots that are too close to another dot
statusList = partitionNeighborhoods(allDots(:,1),allDots(:,2),spacingStrictness,[512 256],numObj);
%Flag every dot with a 1 in their 'statusList' entry iff they are within
%the same 'neighborhood' as another dot, where neighborhoods are defined as
%a set of four overlapping grids, the grid spacing equal to 'spacingStrictness' pixels
validDots = zeros(1,3); %Columns: x, y, MaxIntensity
i = 1;
areaCutoff = prctile([s(:).Area],98); %The very largest 'dots' are typically noise
intensityCutoff = prctile([s(:).MaxIntensity],99.6); %as are very bright dots

for k = 1: numObj %Throw out junk dots with a series of conditionals
    if statusList(k) == 0 
        if s1(k,1) < 252 && s1(k,1) > 4 && s1(k,2) < 508 && s1(k,2) > 4
            if s(k).Area < areaCutoff
                if s(k).MaxIntensity < intensityCutoff
                    if err(k) < gaussCutoff
                        %record the information of all valid dots
                        validDots(i,1:3) = [allDots(k,1), allDots(k,2), s(k).MaxIntensity(1)];
                        i = i+1;
                    end
                end
            end
        end
    end
end

figure(1);
close 1;
figure(4);
close 4;
figure(4);
imshow(I,[0,max(I(:))]);
hold on
plot(validDots(:,1), validDots(:,2), 'go');


disp(['There were ' num2str(length(validDots)) ' good dots on the selected side']);
%Stopping for input is the only way to pause a program while allowing
%interaction with a figure (to zoom, etc.)
inpuT = input('Paused to allow viewing of dots.  Press enter in the command line to continue');
clear('inpuT');
answer1 = questdlg(['All good dots are plotted in green.  There were ' num2str(length(validDots)) ' good dots, with a spacing strictness of ' ...
    num2str(spacingStrictness) ' and a minimum brightness of ' num2str(minimumBrightness) ...
    '.  Would you like to input different thresholds to get more or fewer dots?']);

if answer1(1) == 'Y'
    thresholdAnswer = inputdlg({['Input new spacing strictness value. Lower values allow closer dots to '...
        'be counted.  Higher values will exclude more dots'],['Input new minimum brightness value.  Increasing'...
        ' this value will exclude more dim dots.']}, 'Input Thresholds', 1, {num2str(spacingStrictness),...
        num2str(minimumBrightness)});
    spacingStrictnessAns = str2double(thresholdAnswer{1});
    minimumBrightnessAns = str2double(thresholdAnswer{2});
    %if the only thing that has changed is the spacing strictness, we do
    %not need to re-adjust the image, so we merely 'reLocate' dots
    if minimumBrightnessAns == minimumBrightness
        reLocate = 1;
        spacingStrictness = spacingStrictnessAns;
    else
        %However, if the minimumBrightness has changed, we need to go all
        %the way back to the 'reAdjust' portion; thus we need to exit the
        %reLocate loop
        reLocate = 0;
        spacingStrictness = spacingStrictnessAns;
        minimumBrightness = minimumBrightnessAns;
        reAdjust = 1;
    end
else %if we are satisfied with the dots, exit both loops
    reLocate = 0;
    reAdjust = 0;
end
end
end
%frame1 = (squeeze(frame1(:,:,:))-trueAverageI).*(uint8(squeeze(frame1(:,:,:)-trueAverageI)>0));

%The next section very precisely locates the center of each dot by fitting
%it to a 'real' Gaussian model, not the simplified model found in the
%earlier gauss section in the reLocate loop.  This is a more time-intensive
%method, but much more precise, which is why it is saved until the
%location and number of dots has already been approved
gauss = 2;
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
    numDots = size(validDots,1);
%     for i = 1:numDots
%         pairedDots(i,1,1:2) = validDots(pairs(i,1),1:2);
%         pairedDots(i,2,1:2) = validDots(pairs(i,2),1:2);
%     end
    for i = 1:numDots
        %Get the appropriate 'slice' of the matrix for each dot by using
        %the nearest integer coordinate
        x1 = round(validDots(i,1));
        y1 = round(validDots(i,2));
        %Store the integer part of each position; the precise fractional
        %part will be calculated and then added in later
        validX(i) = x1;
        validY(i) = y1;
        try
            zS(:,:,i) = mean(frame1(y1-2:y1+2,x1-2:x1+2,:),3);
        catch
            zS(:,:,i) = ones(5,5);
        end
    end
    clear xData;
    clear yData;
    for i = 1:size(zS,3)
        %The following line calculates the fractional part of the center position 
        %and goodness of fit for each dot
        [xData(i),yData(i),~,~,gof(i)] = getGauss(0,gaussFit,fo,50,xS,yS,zS(:,:,i));
    end
%     for j = 1:size(pairedDots,1)
%         pairedDots(j,1,1:3) = [xData(j)+validX(j),yData(j)+validY(j),gof(j)];
%     end
%     for j = 1:size(pairedDots,1)
%         k = size(pairedDots,1)+j;
%         pairedDots(j,2,1:3) = [xData(k)+validX(k),yData(k)+validY(k),gof(k)];
%     end
     %Add the fractional part to the integer part that was stored earlier 
     validDots = [validX'+xData', validY'+yData' ];
end



intensities = zeros(size(validDots,1),frames); %Record each dot's intensity
for j = 1:length(validDots)
    %j, the index, is dot id, and corresponds to the row of 'intensities'
    %Again extract the slice of the matrix immediately surrounding each dot
    x0 = validDots(j,1);
    y0 = validDots(j,2);
    x1 = round(x0);
    y1 = round(y0);
    slice = double(frame1(y1-2:y1+2,x1-2:x1+2,:));
    %getIntensity is a weighted average of the pixels surrounding the
    %central dot, and is repeated (vectorized) for each frame
    intensities(j,:) = getIntensity(slice, x0, y0);
    %thus intensities has 'frames' columns
end

choice = questdlg('Would you like to normalize the data for use in emFRET?');
if choice(1) == 'Y'
    %Normalizes trajectories to be only between 0 and 1; has extra input
    %args because different methods for this normalization were attempted
    deadFrames = inputdlg(['Input the number of frames at the beginning of'...
        ' the movie during which the fluorescence should be constant'...
        '  These frames will be used to determine baseline fluorescence']);
    deadFrames = str2double(deadFrames{1});
    if ~isnumeric(deadFrames)
        deadFrames = 100;
    end
    [baselines, standardDev] = getIntensityCoefficients(validDots,frame2(:,:,1:deadFrames));
    for i = 1:length(validDots)
        intensitiesAdj(i,:) = intensities(i,:)/baselines(i);
    end
    emFRET = emulateFRET(intensitiesAdj);
end

choice = questdlg('Would you like to save your intensities file as a matlab variable before continuing?');

if choice(1) == 'Y'
    uisave('intensities',[num2str(fileName) '_intensity_' datestr(now,1) '.mat']);
    if exist('emFRET','var')
        uisave('emFRET',[num2str(fileName) '_emFRET_intensity_' datestr(now,1) '.mat']);
    end
        
end


% intensitiesAdj = intensities;
% for j = 1:numObj
%     for i = 4:frames-4
%         intensitiesAdj(j,i) = .27*(intensities(j,i-1)+intensities(j,i+1))+.15*(intensities(j,i-2)+intensities(j,i+2))+.08*(intensities(j,i-3)+intensities(j,i+3));
%     end
% end

%Open the appropriate plotting and cutting function for the type of data
%saved.  
    if exist('emFRET','var')
        plotCut2(1-emFRET,emFRET,frames,timeUnit);
    else
        plotCut(intensities,frames,timeUnit);
    end

% 
% figure(2);
% axis([0 100 0 1500]);
% for i = 1:15 
%     figure(2);
%     hold on;
%     comet(1:100,intensities(randi(400),:))
% end

% figure(3);
% hold on;
% axis([0 100 0 1500]);
% for i = 1:15 
% comet(1:100,intensitiesAdj(randi(400),:))
% figure(3);
% hold on;
end
end