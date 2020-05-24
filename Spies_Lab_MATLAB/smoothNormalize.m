function [matrix, niceList] = smoothNormalize(varargin)
%smoothNormalize: Smooths and normalizes a matrix containing a
%group of fluorescence traces
%   The input matrix should have each trace stored as an array (1xlength) within an Nx1 cell array, with the
%   second (optional) input being two columns of data, with the same number of rows
%   as the input matrix, which contain the start and end indices of the
%   baseline for each trace (typically a region of photoblinking, if it is present).

input = varargin{1};
matrix = cell(size(input));
width = 7; %width of comparison region
N = size(input,1);

% v = version('-release');

try %Check that required functions are available in the user's version
    smoothdata(rand(1,100));
    filloutliers(rand(1,100),'spline');
    findchangepts(rand(1,100));
    close(gcf)
    old_version = 0;
catch
    old_version = 1;
end

% if str2double(v(1:4))<2017
if old_version
msgbox('Your MATLAB version does not support smoothing techniques; performance may be affected');
for j = 1:N
    trace = input{j};
    %First, set up two sliding windows to compare regions of the trace for
    %similarity and smooth the contiguous regions
    i1 = 1;
    i2 = 1;
    regions = zeros(0,2);
    while i1 < length(trace)-width*2 && i2 < length(trace)-width
        same = 1;
        copy = 1;
        seg1 = trace(i1:i1+width-1);
        i2 = i1+width;
        while same && i2 < length(trace)-width
            seg2 = trace(i2:i2+width-1); %Next, a t-test evaluates the data in each window
            same = abs((mean(seg1)-mean(seg2))/sqrt(var(seg1)/length(seg1)+var(seg2)/length(seg2)))<2.179;
            if same
                i2 = i2+1;
                seg1 = [seg1 seg2(1)]; %Place data into one window for the next comparison
                copy = 0;
                try
                    if regions(end,2)~=0
                        regions(size(regions,1)+1, 1) = i1;
                    end
                catch
                    regions(1, 1) = i1;
                    regions(1,2) = 0;
                end
            else %if next window does not match this window
                try
                    if regions(end,2)==0 %Record the end of the contiguous region
                        regions(end,2)=i2+3;
                    end
                    if copy
                        i1 = i1+1;
                    else
                        i1=i2+3;
                    end
                catch
                    if copy
                        i1 = i1+1;
                    else
                        i1=i2+3;
                    end
                end
                
            end
        end
    end
    if regions(end,2)==0 %Record the end of the last contiguous region
        regions(end,2)=i2-1;
    end
    matrix{j} = trace;
    for i = 1:size(regions,1)
        indices = regions(i,1):regions(i,2);
        matrix{j}(indices) = smoothTrace(trace(indices)); %Smooth the contiguous regions
        %matrix(j,indices) = trace(indices);
    end
end

%identify the approximate location of states within the data
allPeaks = cell([N,1]);
peaksTrimmed = cell([N,1]);
for j = 1:N
    trace = matrix{j};
    FWHM = (prctile(trace(:),96)-min(trace(:)))/25;
    dist = repmat(trace,[length(trace),1])-repmat(trace',[1,length(trace)]);
    signs = sign(dist);
    point = sum((((dist.^2)+FWHM.^2).^-1).*signs,2); %an attempt to create a vector field
    %where each arrow points toward the "watershed" of highest density
    %nearby it, splitting the trace into regions where the vectors point
    %towards the nearest peak
    [traceSort, pointSort] = sort(trace);
    point = point(pointSort)';
    diffPoint = [2 diff(sign(point))];
    %the locations of vector direction changes are the locations of peaks
    %(or the boundaries between watershed regions, but those are the
    %positive changes, diffPoint==+2)
    clear peaks;
    peaks(:,1) = traceSort(diffPoint==-2); %The location of the peaks
    peaks(:,2) = diff(find([diffPoint==2, 1])); %The intensity of the peaks
    allPeaks(j) = {peaks};
end
%if version is 2017a or newer:
else %smooth the traces, remove outliers, find contiguous regions, organize into peaks
    allPeaks = cell([N,1]);
    peaksTrimmed = cell([N,1]);
    for j = 1:N
        clear regions;
        trace = input{j};
        trace = filloutliers(trace,'spline','movmean',7);
        trace = trace/(max(trace));
        regions = [1 findchangepts(trace, 'MinDistance',5,'MinThreshold',.25) length(trace)+1];
        %Find locations within the trace which are good candidates for
        %state boundaries
        pk = 0;
        peaks = zeros(length(regions),3);
        peakIndices = cell(length(regions),1);
        for i = 1:length(regions)-1
            trace(regions(i):regions(i+1)-1) = filloutliers(trace(regions(i):regions(i+1)-1),'spline','movmean',7);
            trace(regions(i):regions(i+1)-1) = smoothdata(trace(regions(i):regions(i+1)-1),'movmean',11);
            segment = trace(regions(i):regions(i+1)-1);
            peaks(pk+1,:) = [mean(segment), length(segment), std(segment)];
            peakIndices(pk+1) = {regions(i):regions(i+1)-1};
            if pk == 0
                h = 1;
            else
                h = zeros(1,pk);
            end
            for ip = 1:pk
                %check to see if this peak is statistically similar to any
                %of the ones we have already found in this trace (compare:
                %mean via t test; standard deviation via simple comparison)
                h(ip) = ttest2(segment,trace(peakIndices{ip}),'Alpha',.1,'Vartype','unequal') || ...
                    peaks(ip,3)>3*peaks(pk+1,3) || peaks(ip,3)*3<peaks(pk+1,3);
                %h will equal 1 if the two regions are distinct
            end
            if h %if distinct from all other peaks
                pk = pk+1;
                peaks(pk,:) = [mean(segment), length(segment), std(segment)];
            else
                for ip = find(~h)
                    segment2 = [trace(peakIndices{ip}) segment];
                    peaks(ip,:) = [mean(segment2), length(segment2), std(segment2)];
                    peakIndices(ip) = {[peakIndices{ip} peakIndices{pk+1}]};
                end
            end 
        end
        [~,I] = sort(peaks(1:pk,1));
        allPeaks(j) = {peaks(I,:)};
        allPeakIndices(j) = {peakIndices(I,1)};
        matrix{j} = trace;
    end
end


%Find baseline for all traces, if possible:
if length(varargin)==2 %if baseline provided
    baseIndices = varargin{2};
    for j = 1:N
        try
            baseline = smoothTrace(matrix{j}(baseIndices(j,1):baseIndices(j,2)));
        catch
            peaksTrimmed{j} = allPeaks{j};
            continue
        end
%         meaN = mean(baseline);
%         stD = std(baseline)/sqrt(length(baseline));
        i = 2;
        try
            while ~ttest2(matrix{j}(allPeakIndices{j}{i}),baseline,'Vartype','unequal','Alpha',.05)
                %Is this peak statistically similar to the baseline?
                %if yes, remember it and check the next peak
                i = i+1;
%                 skip(j) = i;
            end
            peaksTrimmed{j} = allPeaks{j}(i:end,:); 
            %record all peaks that don't look like the baseline
        catch
            peaksTrimmed{j} = allPeaks{j}(end,:);
            %if there is only one peak
        end
    end
else
    peaksTrimmed = allPeaks;
end

goodMatrix = cell(size(matrix));
mult = zeros(N,1);
niceList = zeros(N,1,'logical');
for j = 1:N
    if size(peaksTrimmed{j},1)<3||length(peaksTrimmed{j})>20
        continue %skip ill-behaved traces
    end
    trace = matrix{j};
    lengths(j) = length(trace);
    %Set lowest state at 0 for now (can always change), and squeeze to fit
    %together (approximately)
    mult(j) = 0.8/(range(peaksTrimmed{j}(:,1)));
    goodMatrix{j} = (trace-peaksTrimmed{j}(1,1))*mult(j);
    peaksTrimmed{j} = [(peaksTrimmed{j}(:,1)-peaksTrimmed{j}(1,1))*mult(j) peaksTrimmed{j}(:,2)];
    niceList(j) = 1;
end

originalMatrix = cell(size(goodMatrix));
originalMatrix(niceList) = goodMatrix(niceList);
%Every trace in originalMatrix is scaled down and well-behaved, but has an
%index which matches its position in the peaksTrimmed list
%Also matches the scaling of peaksTrimmed
basisMatrix = originalMatrix;
n = nnz(niceList); %n is the number of well-behaved traces
mult = ones(1,N)*1000;
%Make all the peaks into one big histogram to see where peaks fall

[valueS,edges] = histcounts(cell2mat(basisMatrix'),n*5); 
valueS = valueS/(sum(lengths))*n*5; %A normalization based on the number of bins and number of data points
centers = edges(1:end-1) + diff(edges)/2;
miN = round(centers(1),3); %Get beginning and end points
maX = round(centers(end),3);
dist = interp1(centers, valueS, miN:.001:maX); %A vector describing population density at each level
dist(isnan(dist))=0; %remove NaN values
shift = round(-1*miN*1000)+1+length(dist); %define the position within dist of the original starting point
dist = [mean(dist)*ones(size(dist))/10 dist mean(dist)*ones(size(dist))/10]; 
%extend it on both sides to enable extrapolation outside 

basisScore = 0;

% for j = find(niceList)'
%     fitScore = @(x)sum(-peaksTrimmed{j}(:,2)'.*(dist(shift+round(x*peaksTrimmed{j}(:,1)))));
%     mult(j) = fminbnd(fitScore, 250, 1500);
%     basisMatrix{j} = basisMatrix{j}*mult(j)/1000;
%     basisScore = basisScore-fitScore(mult(j));
% end
figure; histogram(cell2mat(basisMatrix'));
title(['Basis score: ' num2str(basisScore)]);

satisfied = 0;
iteration = 1;
bestIteration = 1;
multMatrix(1,:) = mult;
penultimateMatrix = cell(size(basisMatrix));
scoreMatrix = basisScore;

YN = questdlg('Would you like to shuffle the traces and attempt a better fit score?');
try
if YN(1) == 'N'
    satisfied = 1;
end
catch
    disp('Program exited; debug enabled');
    disp('type dbquit to quit');
    keyboard;
end

while ~satisfied
    
    repeats = str2double(cell2mat(inputdlg('How many shuffles would you like to attempt?')));
    for i = 1:repeats
        iteration = iteration+1; %pick a random selection of well-behaved traces to serve as the new basis
        shuffle = randperm(n);
        found = find(niceList);
        n0 = randi(n);
        shuffle = found(shuffle(1:n0));
        basisMatrix = originalMatrix(shuffle);
        %repeat the histogram (population distribution) calculations for this new basis 
        [valueS,edges] = histcounts(cell2mat(basisMatrix'),max(n0*5,100));
        valueS = valueS/(sum(lengths(shuffle)))*max(n0*5,100); 
        centers = edges(1:end-1) + diff(edges)/2;
        miN = round(centers(1),3);
        maX = round(centers(end),3);
        dist = interp1(centers, valueS, miN:.001:maX); %A vector describing population density at each level
        dist(isnan(dist))=0;
        shift = round(-1*miN*1000)+1+length(dist);
        dist = [mean(dist)*ones(size(dist))/10 dist mean(dist)*ones(size(dist))/10];
        %repeat the scaling and fitting process for each trace
        scoreMatrix(iteration) = 0;
        for j = find(niceList)'
            fitScore = @(x)sum(-peaksTrimmed{j}(:,2)'.*(dist(shift+round(x*peaksTrimmed{j}(:,1)))));
            multMatrix(iteration,j) = fminbnd(fitScore, 250, 1500);
%             basisMatrix(j,:) = basisMatrix(j,:)*mult(j)/1000;
            scoreMatrix(iteration) = scoreMatrix(iteration)-fitScore(multMatrix(iteration,j));
            %Fitscore returns a negative number, but a higher scoreMatrix
            %is better, so subtract.
        end
    end
    [bestScore,bestIteration] = max(scoreMatrix);
    
    for j = find(niceList)'
        displayedMatrix{j} = originalMatrix{j}*multMatrix(bestIteration,j)/1000; 
    end
    figure; histogram(cell2mat(displayedMatrix'));
    title(['Current score: ' num2str(bestScore)]);
    
    
    
    YN = questdlg(['Would you like to use this normalization, keep it but reshuffle to see if it can be' ...
        'improved upon, or delete it so you won`t see it again?'],'Options','Use','Reshuffle','Delete','Reshuffle');
    
    try
        if YN(1) == 'U'
            satisfied = 1;
        elseif YN(1) == 'R'
        else
            scoreMatrix(bestIteration) = 0;
        end
    catch
        disp('Program exited; debug enabled');
        disp('type dbquit to quit');
        keyboard;
    end
    
end


for j = find(niceList)'
    penultimateMatrix{j} = originalMatrix{j}*multMatrix(bestIteration,j)/1000;
end

YN = questdlg(['It was determined that ' num2str(n) ' out of ' num2str(N) ' traces were'...
    ' well-behaved; would you like to only save these good traces or attempt to fit the others'...
    ' in as well?  If your data is multi-channel, you should save all the traces so that there is' ...
    ' still a one-to-one correspondence of the traces in the two channels' ...
    ],'Save all?','Save only the good traces','Attempt a fit on the other traces and save them too',...
    'Save only the good traces');
scale = [1E10,-1E10];
if YN(1)=='A'
    for j = find(niceList)'
        scale(1) = min([prctile(penultimateMatrix{j},1) scale(1)]);
        scale(2) = max([prctile(penultimateMatrix{j},99) scale(2)]);
    end
    for j = find(~niceList)'
        penultimateMatrix{j} = scale(2)*(matrix{j}-prctile(matrix{j},1))/(prctile(matrix{j},99)-prctile(matrix{j},1));
    end
    niceList = ones(size(niceList));
% else
%     penultimateMatrix = penultimateMatrix(niceList);
%     matrix = matrix(1:length(penultimateMatrix));
end
scale = [1E10,-1E10];
for j = 1:length(penultimateMatrix)
    scale(1) = min([penultimateMatrix{j} scale(1)]);
    scale(2) = max([penultimateMatrix{j} scale(2)]);
end
for j = 1:length(penultimateMatrix)
    matrix{j} = (penultimateMatrix{j}-scale(1))/(-scale(1)+scale(2));
end

%         valueS = histcounts(emFret,[-Inf 0:.01:1 Inf]);
%         [~,maxX] = max(valueS(1:50));
%         fit1 = fit((-.005:.01:(.01*(maxX+2)+.005))',valueS(1:(maxX+4))','gauss1');
%         newBaseLine = fit1.b1+fit1.c1*2;
%         emFret = max(emFret,newBaseLine);

end


