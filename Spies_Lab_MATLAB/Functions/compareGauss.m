function [xShift,yShift,errs] = compareGauss(xData, yData, frame,Gauss)
k = 1;
fail = zeros(1,length(xData));
while k <= length(xData)
    x = round(xData(k));
    y = round(yData(k));
    if x<size(frame,2)-2 && x>2 && y<510 && y>2
    slice = frame(y-2:y+2,x-2:x+2);
    total = sum(sum(slice));
    slice = double(slice);
    factor = total/3.08;
    for i = -6:6
        for j = -6:6
            gaussTemp = squeeze(Gauss(i+7,j+7,:,:));
            erfM = slice - gaussTemp*factor;
            erfM = erfM.*gaussTemp;
            err(13*(i+6)+j+7) = sum(abs(erfM(:)));
    %         errM(i+7,j+7) = sum(abs(erfM(:)));
        end
    end
    [M,I] = min(err);
    yShift1 = (floor((I-.01)/13)-6)*.2;
    xShift1 = (mod(I-1,13)-6)*.2;
    yShift(k) = round(yData(k))+(floor((I-.01)/13)-6)*.2;
    xShift(k) = round(xData(k))+(mod(I-1,13)-6)*.2;
    errs(k) = M;
%     if abs(xShift1) >= .8 || abs(yShift1) >= .8 % && fail(k)<4
%         yData(k) = yShift(k);
%         xData(k) = xShift(k);
%         fail(k) = fail(k)+1;
%         k = k-1;
%         disp(k+1);
%         if fail(k+1) >= 4
%             yShift(k+1) = 0;
%             xShift(k+1) = 0;
%             k = k+1;
%         end
%     end
    
%     if fail(k+1) >= 4
% 
%     end

    end
    k = k+1;
end
% temp = err(85);
% disp(M);
end