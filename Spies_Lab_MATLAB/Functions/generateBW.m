function BW = generateBW(fMatrix,frameList)
if length(size(fMatrix)) == 2
    meaN = mean(fMatrix(:));
    stD = std(double(fMatrix(:)));
    BW = fMatrix > meaN+stD;
end
if length(size(fMatrix)) == 3
    fMatrix = fMatrix(:,:,frameList);
    meaN = mean(fMatrix(:));
    stD = std(double(fMatrix(:)));
    fMatrix = fMatrix > meaN+stD;
    fMatrix = squeeze(sum(fMatrix,3));
    meaN = mean(fMatrix(:));
    stD = std(double(fMatrix(:)));
    BW = fMatrix > meaN + stD;
end
end