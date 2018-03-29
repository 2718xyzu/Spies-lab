function mapping = extractMapFile(fileName)
    A = fopen(fileName);
    fseek(A,4,-1);
    frame1 = zeros(512,512,10,'uint8');
    %Vectorized reading of file:
    frame1(:,:,:) = permute(reshape(fread(A,512*512*10,'uint8'),512,512,10),[2 1 3]);
    combinedI = sum(frame1,3);
    BW = generateBW(frame1,1:10);
    s = regionprops(BW, combinedI, {'WeightedCentroid', 'MaxIntensity', 'Area'});
    numObj = numel(s);

    for k = 1 : numel(s) %Locate dots
        s1(k,1) = s(k).WeightedCentroid(1);
        s1(k,2) = s(k).WeightedCentroid(2);
    end

    statusList = partitionNeighborhoods(s1(:,1),s1(:,2),6,[512 512],numObj);
    validDots = zeros(1,10); %Columns: x, y, MaxIntensity
    i = 1;
    for k = 1: numObj %Throw out junk dots 
        if statusList(k) == 0; %All dots which are too close to another dot get marked in statusList as "1"
            if s1(k,1) < 508 && s1(k,1) > 4 && s1(k,2) < 508 && s1(k,2) > 4 %They are not too close to an edge
                if s(k).Area < 3*std([s(:).Area])+mean([s(:).Area])
                    if s(k).MaxIntensity < 3*std([s(:).MaxIntensity])+mean([s(:).MaxIntensity])
                        validDots(i,1:3) = [s(k).WeightedCentroid(1), s(k).WeightedCentroid(2), s(k).MaxIntensity(1)];
                        i = i+1;
                    end
                end
            end
        end
    end

    pairs = zeros(1,1);
    xShiftList = zeros(1);
    yShiftList = zeros(1);
    xShift = 256;
    yShift = 0;
    pairs = 0;
    while pairs < 10
        i = randi(length(validDots));
        possibleDot = zeros(1,1);
        if validDots(i,1) < 256
            targetX = validDots(i,1) + xShift;
            targetY = validDots(i,2) + yShift;
        else
            targetX = validDots(i,1)-xShift;
            targetY = validDots(i,2) - yShift;
        end

        for j = 1:length(validDots)
            r = sqrt((validDots(j,1)-targetX)^2+(validDots(j,2)-targetY)^2);
            if r < 3.5
                possibleDot(nnz(possibleDot)+1) = j;
            end
        end
        if nnz(possibleDot) == 1 
            pairs = pairs+1;
            xShiftList(nnz(xShiftList)+1) = abs(validDots(possibleDot,1)-validDots(i,1));
            yShiftList(nnz(yShiftList)+1) = abs(validDots(possibleDot,2)-validDots(i,2));
        end
    end

    error = 1-(std(xShiftList)+std(yShiftList))/10;
    disp(error);
    xShift = mean(xShiftList);
    yShift = mean(yShiftList);
    mapping = [xShift yShift];
end
