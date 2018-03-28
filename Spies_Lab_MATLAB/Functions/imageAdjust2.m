% Joseph Tibbs
%Last updated 07/23/17
function [combinedFrame, BW, adjustedFrame, average] = imageAdjust2(frame,delThreshold)
sumFrame = mean(frame,3);
%sum2Frame = sum(frame.*frame,3)/size(frame,3);
maxFrame = squeeze(max(frame(:,:,1:10:end),[],3));
%percentileFrame = prctile(frame(:),96);
%percentile2Frame = prctile(sum2Frame(:),96);
percentileMax = prctile(maxFrame(:),95);
stdMatrix = std(double(frame),0,3);
percentileStd = prctile(stdMatrix(:),95);
percentileSum = prctile(sumFrame(:),95);
percentileBackground = prctile(maxFrame(:),25);
maxMat = maxFrame>percentileMax;
%maxMatEdge = imclearborder(~edge(maxMat));
stdMat = stdMatrix>percentileStd;
sumMat = sumFrame>percentileSum;
totalMat = maxMat + stdMat + sumMat;
%disp(nnz(totalMat));
%BW = generateBW(sumFrame,1:size(sumFrame,3));
%BW2 = generateBW(sum2Frame,1:size(sum2Frame,3));
for i = 1:size(frame,3)
    background(i) = sum(sum(double(frame(:,:,i)).*double((maxFrame<=percentileBackground))))/nnz(maxFrame<=percentileBackground);
%     test = max(max(frame(:,:,i)));
    adjustedFrame(:,:,i) = max(frame(:,:,i)-background(i),0);
end
combinedFrame = sum(adjustedFrame,3)/size(frame,3);
L = del2(combinedFrame);
BW = L < -delThreshold/5;
% BW = totalMat>=2;
average = sum(sum((BW.*combinedFrame)))/nnz(BW);
end