function [matrix, niceList] = normalizeSelection(input, low, high)
%normalizeSelection: uses selections of both low state and high state
%within the data to normalize the traces
%   The input matrix should have each trace stored as an array (1xlength) within an Nx1 cell array, with the
%   second and third inputs being two columns of data, with the same number of rows
%   as the input matrix, which contain the start and end indices of the
%   low and high state for each trace, respectively

matrix = cell(size(input));
width = 7; %width of comparison region
N = size(input,1);
precision = 1E-3; %resolution of possible bins
twoState = 0;

lowSpecified = zeros([N 1],'logical');
highSpecified = zeros([N 1],'logical');
for j = 1:N
    if ~isempty(low{j}) %these indices would both be zero if no low state were selected
        lowSpecified(j) = 1;
    end
    if ~isempty(high{j})
        highSpecified(j) = 1;
    end
end


if any(~lowSpecified) || any(~highSpecified)
anS = questdlg('Would you like to assume a two-state model for these traces?','Model select', 'Two-state',...
    'Do not assume two-state', 'Two-state');
if strcmp(anS(1),'T')
    twoState = 1;
end
end
% v = version('-release');

try %Check that required functions are available in the user's version
    smoothdata(rand(1,100));                %Signal Processing Toolbox
    filloutliers(rand(1,100),'spline');
    findchangepts(rand(1,100));
    close(gcf)
    [~] = fit((1:10)',(2:2:20)','poly5');   %Curve Fitting Toolbox
    [~] = ttest2(randn([1 50]),randn([1 50]),'Alpha',.01,'Vartype','unequal'); %Stats and Machine Learning
    old_version = 0;
catch
    old_version = 1;
end

% if str2double(v(1:4))<2017
if old_version
    msgbox(['Function checks failed.  Troubleshooting: use the add-on' ...
        ' manager to download the "Signal Processing Toolbox", "Curve Fitting Toolbox", '...
        'and the "Statistics and Machine Learning Toolbox".  Version should also be newer than 2016. ']);
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
                    joinedSegment = [seg1 seg2(1)]; %Place data into one window for the next comparison
                    seg1 = joinedSegment;
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
    allPeakIndices = cell([N,1]);
    allPeaks = cell([N,1]);
    for j = 1:N
        clear regions;
        trace = input{j};
        %         trace = filloutliers(trace,'spline','movmean',7);
        %         uncomment if you would like to fill single-frame noise spikes
        trace = trace/(max(trace));
        regions = [1 findchangepts(trace, 'MinDistance',5,'MinThreshold',.25) length(trace)+1];
        %Find locations within the trace which are good candidates for
        %state boundaries
        pk = 0;
        peaks = zeros(length(regions),3);
        peakIndices = cell(length(regions),1);
        for i = 1:length(regions)-1
            if regions(i+1)-regions(i)>5 %a continguous region without spikes
                %                 trace(regions(i):regions(i+1)-1) = filloutliers(trace(regions(i):regions(i+1)-1),'spline','rloess',7);
                %         uncomment if you would like to fill single-frame noise spikes
                trace(regions(i):regions(i+1)-1) = smoothdata(trace(regions(i):regions(i+1)-1),'rloess',11);
                % we should only use smoothing on regions without spikes,
                % to avoid artificial intermediate states
            end
            segment = trace(regions(i):regions(i+1)-1);
            peaks(pk+1,:) = [mean(segment), length(segment), std(segment)];
            peakIndices(pk+1) = {regions(i):regions(i+1)-1};
            h = zeros(1,pk);
            if pk == 0
                h = 1;
            end
            for ip = 1:pk
                %check to see if this peak is statistically similar to any
                %of the ones we have already found in this trace (compare:
                %mean via t test; standard deviation via simple comparison)
                h(ip) = ttest2(segment,trace(peakIndices{ip}),'Alpha',.01,'Vartype','unequal') || ...
                    peaks(ip,3)>2*peaks(pk+1,3) || peaks(ip,3)*2<peaks(pk+1,3);
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


    

goodMatrix = cell(size(matrix));
mult = zeros(N,1); %mult is the scaling factor between the original traces
%(in 'matrix') the fitted traces (in 'goodMatrix')
niceList = ones(N,1,'logical');
fixedList = zeros(N,1,'logical');
toFitList = zeros(N,1,'logical');
lengths = zeros([1 N]);

varLow = 0;
nLow = 0;
varHigh = 0;
nHigh = 0;

for j = find(and(lowSpecified, highSpecified))'
    %user helpfully indicated both a low and a high region in this trace
    trace = matrix{j};
    meanHigh = mean(high{j});
    meanLow = mean(low{j});
    mult(j) = 1/(meanHigh-meanLow);
    goodMatrix{j} = (trace-meanLow)*mult(j);
    low{j} = (low{j}-meanLow)*mult(j);
    high{j} = (high{j}-meanLow)*mult(j);
    varLow = (var(low{j})*length(low{j})+varLow*nLow)/(length(low{j})+nLow);
    nLow = nLow + length(low{j});
    varHigh = (var(high{j})*length(high{j})+varHigh*nHigh)/(length(high{j})+nHigh);
    nHigh = nHigh + length(high{j});
    fixedList(j) = 1;
    allPeaks{j} = [(allPeaks{j}(:,1)-meanLow)*mult(j) allPeaks{j}(:,2) allPeaks{j}(:,3)*mult(j)];
end

for j = find(and(lowSpecified, ~highSpecified))'
    %user indicated only a low region in this trace
    trace = matrix{j};
    meanLow = mean(low{j});
    if range(allPeaks{j}(:,1))>2*std(low{j})
        mult(j) = 0.8/(prctile(trace,98)-meanLow);
        %multi-state trace with just the low state filled in, guess a fit
        %at 0.8, keep it in the pool of traces that need fitting
        toFitList(j) = 1;
    elseif varLow
        %if we have some low states already identified:
        mult(j) = sqrt(varLow)/std(low{j});
        %A single-state trace (peaks are all within 2 standard deviations of
        %each other) so we use the low states already fit to estimate the
        %scale of the new fit
        fixedList(j) = 1;
    else
        mult(j) = 0.05/std(low{j});
        %If it's really just a low state trace, the best guess is to scale
        %it to have a small standard deviation around the baseline
        fixedList(j) = 1;
    end
    goodMatrix{j} = (trace-meanLow)*mult(j);
    low{j} = (low{j}-meanLow)*mult(j); %even though this is never used again
    allPeaks{j} = [(allPeaks{j}(:,1)-meanLow)*mult(j) allPeaks{j}(:,2) allPeaks{j}(:,3)*mult(j) ];
end

for j = find(and(~lowSpecified, highSpecified))'
    %user indicated only a high region in this trace
    
    %current fitting methods scale about 0, whereas for these traces the
    %fixed point is at 1.  This situation should not happen very often, as
    %there is almost always some baseline within the trace.
    trace = matrix{j};
    meanHigh = mean(high{j});
    if range(allPeaks{j}(:,1))>2*std(high{j})
        %cannot support a scaling about 1
        %for a multistate trace with no baseline
        mult(j) = sqrt(varHigh)/std(high{j});
        niceList(j) = 0; 
        %will have the option to fit later, but filter out for now as being ill-behaved
    elseif varHigh
        %if we have some high states already identified:
        mult(j) = sqrt(varHigh)/std(high{j});
        %A single-state trace (peaks are all within 2 standard deviations of
        %each other) so we use the high states already fit to estimate the
        %scale of the new fit
        fixedList(j) = 1;
    else
        mult(j) = 0.05/std(high{j});
        %If it's really just a high state trace, the best guess is to scale
        %it to have a small standard deviation around the high state line
        fixedList(j) = 1;
    end
    goodMatrix{j} = (trace-meanHigh)*mult(j)+1;
    high{j} = (high{j}-meanHigh)*mult(j)+1; %even though this is never used again
    allPeaks{j} = [(allPeaks{j}(:,1)-meanHigh)*mult(j)+1 allPeaks{j}(:,2) allPeaks{j}(:,3)*mult(j)  ];
end

for j = find(~or(lowSpecified, highSpecified))'
    %completely flying blind on these traces
    trace = matrix{j};
    if size(allPeaks{j},1)<(3-twoState)
        %a trace with only one state (in a two-state model) or only two
        %states (in a multistate model) must be treated specially, at the
        %end
        niceList(j) = 0;
        continue
    end
    %Set lowest state at 0 for now (can always change), and squeeze to fit
    %together (approximately)
    mult(j) = 1/(range(allPeaks{j}(:,1)));
    goodMatrix{j} = (trace-allPeaks{j}(1,1))*mult(j);
    allPeaks{j} = [(allPeaks{j}(:,1)-allPeaks{j}(1,1))*mult(j) allPeaks{j}(:,2)];
    allPeaks{j} = [(allPeaks{j}(:,1)-allPeaks{j}(1,1))*mult(j) allPeaks{j}(:,2) allPeaks{j}(:,3)*mult(j)  ];
    toFitList(j) = 1;
end

for j = 1:N %all of the traces need to have this done:
    trace = matrix{j};
    lengths(j) = length(trace);
end

if any(toFitList) %if there are any that still need to be fit
    originalMatrix = cell(size(goodMatrix));
    originalMatrix(niceList) = goodMatrix(niceList);
    %Every trace in originalMatrix is scaled down and well-behaved, but has an
    %index which matches its position in the allPeaks list
    %Also matches the scaling of allPeaks
    basisMatrix = originalMatrix;
    n = nnz(niceList); %n is the number of well-behaved traces
    mult = ones(1,N)/precision;
    %Make all the peaks into one big histogram to see where peaks fall:
    [valueS,edges] = histcounts(cell2mat(basisMatrix'),n*5);
    valueS = valueS/(sum(lengths(niceList)))*n*5; %A normalization based on the number of bins and number of data points
    centers = edges(1:end-1) + diff(edges)/2;
    miN = round(centers(1),3); %Get beginning and end points
    maX = round(centers(end),3);
    dist = interp1(centers, valueS, miN:precision:maX); %A vector describing population density at each level
    dist(isnan(dist))=0; %remove NaN values
    shift = round(-1*miN/precision)+1+length(dist); %define the position within dist of the original starting point
    dist = [mean(dist)*ones(size(dist))/10 dist mean(dist)*ones(size(dist))/10];
    %extend it on both sides to enable extrapolation outside
    
    basisScore = 0;
    
    for j = find(niceList)'
        fitScore = @(x)sum(-allPeaks{j}(:,2)'.*(dist(shift+round(x*allPeaks{j}(:,1)))));
        %     mult(j) = fminbnd(fitScore, 250, 1500);
        basisScore = basisScore-fitScore(mult(j));
    end
    figure; histogram(cell2mat(basisMatrix'));
    title(['Basis score: ' num2str(basisScore)]);
    
    satisfied = 0;
    iteration = 1;
    bestIteration = 1;
    multMatrix(1,:) = mult;
    penultimateMatrix = cell(size(basisMatrix));
    scoreMatrix = basisScore;
    
    YN = questdlg('Would you like to accept this fitting?  Otherwise the code will shuffle the traces and try again');
    try
        if YN(1) == 'Y'
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
            shift = round(-1*miN/precision)+1+length(dist);
            paddedDist = [mean(dist)*ones(size(dist))/10 dist mean(dist)*ones(size(dist))/10];
            dist = paddedDist;
            %repeat the scaling and fitting process for each trace
            scoreMatrix(iteration) = 0;
            for j = find(toFitList)'
                fitScore = @(x)sum(-allPeaks{j}(:,2)'.*(dist(shift+round(x*allPeaks{j}(:,1)))));
                multMatrix(iteration,j) = fminbnd(fitScore, .25/precision, 1.5/precision);
                % % % %             basisMatrix(j,:) = basisMatrix(j,:)*mult(j)*precision;
                scoreMatrix(iteration) = scoreMatrix(iteration)-fitScore(multMatrix(iteration,j));
                %Fitscore returns a negative number, but a higher scoreMatrix
                %is better, so subtract.
            end
            for j = find(fixedList)'
                multMatrix(iteration, j) = 1/precision; %don't change these
            end
        end
        [bestScore,bestIteration] = max(scoreMatrix);
        displayedMatrix = cell([N,1]);
        for j = find(niceList)'
            displayedMatrix{j} = originalMatrix{j}*multMatrix(bestIteration,j)*precision;
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
        penultimateMatrix{j} = originalMatrix{j}*multMatrix(bestIteration,j)*precision;
        allPeaks{j} = [allPeaks{j}(:,1)*mult(j)*precision allPeaks{j}(:,2)];
    end
    
else
    penultimateMatrix = goodMatrix;
end



YN = questdlg(['Would you like to select the baseline (or low-state) region?'...
    '  This helps to suppress low-state overfitting by ebFRET and allows an '...
    'alignment of traces which have 2 or 1 distinct states'...
    ],'Baseline');
if YN(1)=='Y'
    dataPoints = cell2mat(penultimateMatrix');
    [valueS,edges] = histcounts(dataPoints,min(50,round(sqrt(numel(dataPoints)))));
    dEdge = mean(diff(edges));
    centerList = edges(1:end-1)+dEdge/2;
    figure; plot(centerList,valueS);
    [~] = questdlg('Please select the region which contains the low state', 'Baseline',...
        'Ok','Ok');
    [x,~] = ginput(2);
    [~,indeX1] = min(abs(edges-x(1)));
    [~,indeX2] = min(abs(edges-x(2)));
    baselineLimits = sort(x);
    fit1 = fit(centerList(indeX1:indeX2)',valueS(indeX1:indeX2)','gauss1');
    baselineMean = fit1.b1;
    %         newBaseLine = fit1.b1+fit1.c1*2;
    %         valueS = histcounts(emFret,[-Inf 0:.01:1 Inf]);
    %         [~,maxX] = max(valueS(1:50));
    %         fit1 = fit((-.005:.01:(.01*(maxX+2)+.005))',valueS(1:(maxX+4))','gauss1');
    %         newBaseLine = fit1.b1+fit1.c1*2;
    %         emFret = max(emFret,newBaseLine);
    
    n1 = 0;
    n2 = 0;
    for j = find(~niceList)'
        if size(allPeaks{j},1)>1
            n2 = n2+1;
        elseif size(allPeaks{j},1)==1
            n1 = n1+1;
        end
    end
    
    if n1>0
        YN = questdlg(['It was determined that ' num2str(n1) ' traces were'...
            ' single-state; would you like to assign these to the baseline and save them?'...
            ],'Save all?','Fit them',...
            'Ignore them','Fit them');
        if YN(1)=='F'
            for j = find(~niceList)'
                if size(allPeaks{j},1)==1 %single-state trace
                    %try to make the trace fit the identified baseline.
                    trace1 = penultimateMatrix{j};
                    penultimateMatrix{j} = fit1.c1*(trace1-mean(trace1))/std(trace1);
                    niceList(j) = 1;
                end
            end
            %     for j = find(~niceList)'
            %         penultimateMatrix{j} = scale(2)*(matrix{j}-prctile(matrix{j},1))/(prctile(matrix{j},99)-prctile(matrix{j},1));
            %     end
            
            % else
            %     penultimateMatrix = penultimateMatrix(niceList);
            %     matrix = matrix(1:length(penultimateMatrix));
        end
    end
    
    if n2 > 0
        YN = questdlg(['It was determined that ' num2str(n2) ' traces were'...
            ' two-state; would you like to try to fit these to the baseline and save them?'...
            ],'Save all?','Fit them', 'Ignore them','Fit them');
        scale = [1E10,-1E10];
        if YN(1)=='F'
            for j = find(~niceList)'
                if size(allPeaks{j},1)==2
                    %Fitting these ill-behaved traces is not recommended if you expect your model to have more than two
                    %states in general, use with caution.
                    scale(1) = prctile(matrix{j},1);
                    scale(2) = prctile(matrix{j},99);
                    penultimateMatrix{j} = (matrix{j}-scale(1))/(scale(2)-scale(1));
                    niceList(j) = 1;
                end
            end
        end
    end
    
    YN = questdlg(['Would you like to smooth the baseline?  This will help suppress'...
        ' overfitting of low states by ebFRET'],'Baseline');
    
    switch YN
        case 'Yes'
            for j = find(niceList)'
                for i = 1:size(allPeaks{j},1)
                    if allPeaks{j}(i,1)>baselineLimits(1) && allPeaks{j}(i,1)<baselineLimits(2)
                        penultimateMatrix{j}(allPeakIndices{j}{i}) = baselineMean;
                    end
                end
            end
    end
    
end

scale = [1E10,-1E10];
for j = find(niceList)'
    scale(1) = min([prctile(penultimateMatrix{j},1) scale(1)]);
    scale(2) = max([prctile(penultimateMatrix{j},99) scale(2)]);
end
for j = find(niceList)'
    matrix{j} = (penultimateMatrix{j}-scale(1))/(-scale(1)+scale(2));
end



end


