function [combinedFrame, BW, adjustedFrame] = frameAdjust2(frame,brightness)
    width = size(frame,2);
    height = size(frame,1);
    xQ = 8;
    yQ = 16;
    for i = 0:xQ-1
        for j=0:yQ-1
            xIndices = 1+i*width/xQ:(i+1)*width/xQ;
            yIndices = 1+j*height/yQ:(j+1)*height/yQ;
            maxFrame = squeeze(max(frame(yIndices,xIndices,1:10:end),[],3));
            backgroundCutoff = prctile(maxFrame(:),25);
            backgroundFrame = maxFrame<=backgroundCutoff;
            for k = 1:size(frame,3)
                background(j+1,i+1,k) = sum(sum(frame(yIndices,xIndices,k).*backgroundFrame))/nnz(backgroundFrame);
            end
        end
    end

    meshX = width/(2*xQ):width/xQ:(width-width/(2*xQ));
    meshY = height/(2*yQ):height/yQ:(height-height/(2*yQ));
    meshZ = 1:size(frame,3);

    [X1,X2,X3] = ndgrid(meshY,meshX,meshZ);

    F = griddedInterpolant(X1,X2,X3,background);
    xS = 1:size(frame,2);
    yS = 1:size(frame,1);
    zS = 1:size(frame,3);
end
