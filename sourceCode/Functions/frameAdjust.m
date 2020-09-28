function [combinedFrame, BW, adjustedFrame] = frameAdjust(frame,brightness)
    adjustedFrame = zeros(size(frame));
    width = size(frame,2);
    height = size(frame,1);
    for i = 0:7
        for j=0:7
            xIndices = 1+i*width/8:(i+1)*width/8;
            yIndices = 1+j*height/8:(j+1)*height/8;
            [combinedFrameSmall, BWSmall, adjustedFrameSmall, ~] = imageAdjust2(frame(yIndices,xIndices,:),brightness);
            combinedFrame(yIndices,xIndices) = combinedFrameSmall;
            BW(yIndices,xIndices) = BWSmall;
            adjustedFrame(yIndices,xIndices,:) = adjustedFrameSmall;
        end
    end
end
