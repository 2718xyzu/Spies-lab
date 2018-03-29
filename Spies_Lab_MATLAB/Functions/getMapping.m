%Joseph Tibbs
%Last updated: 6/12

function [matrix,pairs] = getMapping(mapI,structI,viableDots,mapFile)
    pairs = zeros(1,1);
    figure(6);
    xShiftList = zeros(1);
    yShiftList = zeros(1);
    xShift = 256;
    yShift = 0;
    pairs = 0;
    continuE = 0;

    if continuE == 0 
        choice = questdlg('Do you have mapping data to input, or would you like to select points?', ...
            'Manual Map','Data','Select points','Select points');
        continuE = (choice(1)=='S');
        if continuE
            colormap 'gray';
            mapI = 255-mapI;
            imshow(mapI,[min(mapI(:)),max(mapI(:))]);
            disp('Click a point on the left');
            [x0,y0] = ginput(1);
            hold on;
            plot(x0,y0,'bo');
            plot(x0+256,y0,'ro');
            disp('Click its corresponding dot on the right; the red circle is a guess')
            [x1,y1] = ginput(1);
            plot(x1,y1,'bo');
            disp('Click a second point');
            [x2,y2] = ginput(1);
            plot(x2,y2,'bo');
            plot(x2+256,y2,'ro');
            disp('Click its corresponding dot on the right; the red circle is a guess');
            [x3,y3] = ginput(1);
            plot(x3,y3,'bo');
            disp('Click a third point');
            [x4,y4] = ginput(1);
            plot(x4,y4,'bo');
            plot(x4+256,y4,'ro');
            disp('Click its corresponding dot on the right; the red circle is a guess');
            [x5,y5] = ginput(1);
            plot(x5,y5,'bo');
            disp('Getting mapping from approximate centers...');
            xList = [x0, x1, x2, x3, x4, x5];
            yList = [y0, y1, y2, y3, y4, y5];
            s = structI;
            for i = 1:6
                for k = 1:numel(s)
                    r = sqrt((s(k).WeightedCentroid(1)-xList(i))^2+((s(k).WeightedCentroid(2)-yList(i))^2));
                    if r<3.5
                        xList(i) = s(k).WeightedCentroid(1);
                        yList(i) = s(k).WeightedCentroid(2);
                    end
                end
            end
            xShift = ((xList(2)+xList(4)+xList(6))-(xList(1)+xList(3)+xList(5)))/3;
            yShift = ((yList(2)+yList(4)+yList(6))-(yList(1)+yList(3)+yList(5)))/3;
        else
            mapping = extractMapFile(mapFile);
            xShift = mapping(1);
            yShift = mapping(2);
        end
    else
        xShift = mean(xShiftList);
        yShift = mean(yShiftList);
    end

    for i = 1:length(viableDots)
        if viableDots(i,1) < 256
            targetX = viableDots(i,1) + xShift;
            targetY = viableDots(i,2) + yShift;
        else
            targetX = viableDots(i,1)-xShift;
            targetY = viableDots(i,2) - yShift;
        end

        for j = 1:length(viableDots)
            r = sqrt((viableDots(j,1)-targetX)^2+(viableDots(j,2)-targetY)^2);
            if r < 2.25
                pairs(i) = j;
            end
        end
    end
    
    errCount = 0;
    for j = 1:length(pairs)
        if pairs(j) ~= 0 and pairs(pairs(j) != j
            errCount = 1 + errCount;
        end

    end
    
    pairsTemp = pairs;
    pairs = zeros(1,2);
    i = 1;
    j = 1;
    while i <= length(pairsTemp)
        if pairsTemp(i) ~= 0
            if pairsTemp(pairsTemp(i))~=0
                pairs(j,1) = i;
                pairs(j,2) = pairsTemp(i);
                pairsTemp(pairsTemp(i)) = 0;
                pairsTemp(i) = 0;
                j = j+1;
            end
        end
        i = i+1;
    end
    display([num2str(errCount) ' dots in error and discarded']);
    disp(['There were ' num2str(length(pairs)) ' good pairs of dots']);
    
    matrix = [xShift, yShift];
end
