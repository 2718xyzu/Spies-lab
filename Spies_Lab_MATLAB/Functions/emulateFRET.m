function [emFret] = emulateFRET(intensity)
% width = size(frameAvg,2);
% height = size(frameAvg,1);
% xQ = 8;
% yQ = 16;
% percMatrix = zeros(yQ,xQ);
% for i = 0:xQ-1
%     for j=0:yQ-1
%         xIndices = 1+i*width/xQ:(i+1)*width/xQ;
%         yIndices = 1+j*height/yQ:(j+1)*height/yQ;
%         values = frameAvg(yIndices,xIndices);
%         percMatrix(j+1,i+1) = prctile(values(:),50);
%     end
% end
% meshX = width/(2*xQ):width/xQ:(width-width/(2*xQ));
% meshY = height/(2*yQ):height/yQ:(height-height/(2*yQ));
% [xInt,yInt] = meshgrid(meshX,meshY);
% [xS,yS] = meshgrid(1:size(frameAvg,2),1:size(frameAvg,1));
% interpMatrix = interp2(xInt,yInt,percMatrix,xList,yList,'spline');
% for i = 1:length(xList)
%     weight(i) = interpMatrix(i);
%     intensityAdj(i,:) = intensity(i,:).*weight(i);
% end
% maxIntensity = prctile(intensityAdj(:),99);
% emFRET = intensityAdj/maxIntensity;
% emFRET = min(emFRET,1);

maxIntensities = prctile(intensity(:),98);
for i = 1:size(intensity,1);
emFret2(i,:) = smoothTrace(intensity(i,:)/maxIntensities*.85);
emFret2(i,:) = min(emFret2(i,:),1);
oneS = emFret2(i,:)==1;
noise = -abs(oneS.*randn(size(oneS))*.025);
emFret2(i,:) = emFret2(i,:)+noise;
end
emFret = emFret2;

answer = questdlg('Would you like to smooth the baseline (recommended to suppress low states)');
if answer(1) == 'Y'
    figure();
    handle1 = gcf;
    histEmFRET = histogram(emFret,'BinEdges',[-Inf 0:.01:1 Inf]);
    valueS = histEmFRET.Values;
    close(handle1);
    clear histEmFREt;
    [~,maxX] = max(valueS(1:50));
    gaussFit = 'a*exp(-((x-b)/c)^2)';
    fit1 = fit((-.005:.01:(.01*(maxX+2)+.005))',valueS(1:(maxX+4))','gauss1');
    newBaseLine = fit1.b1+fit1.c1*2;
    emFret = max(emFret,newBaseLine);
    emFret = emFret + rand(size(emFret))*.005;
end


end