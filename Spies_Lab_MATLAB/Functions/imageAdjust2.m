function [combinedFrame, BW, adjustedFrame, average] = imageAdjust2(frame,delThreshold)
    sumFrame = mean(frame,3);
    maxFrame = squeeze(max(frame(:,:,1:10:end),[],3));
    percentileMax = prctile(maxFrame(:),95);
    stdMatrix = std(double(frame),0,3);
    percentileStd = prctile(stdMatrix(:),95);
    percentileSum = prctile(sumFrame(:),95);
    percentileBackground = prctile(maxFrame(:),25);
    maxMat = maxFrame>percentileMax;
    stdMat = stdMatrix>percentileStd;
    sumMat = sumFrame>percentileSum;
    totalMat = maxMat + stdMat + sumMat;
    for i = 1:size(frame,3)
        background(i) = sum(sum(double(frame(:,:,i)).*double((maxFrame<=percentileBackground))))/nnz(maxFrame<=percentileBackground);
        adjustedFrame(:,:,i) = max(frame(:,:,i)-background(i),0);
    end
    combinedFrame = sum(adjustedFrame,3)/size(frame,3);
    L = del2(combinedFrame);
    BW = L < -delThreshold/5;
    average = sum(sum((BW.*combinedFrame)))/nnz(BW);
end
