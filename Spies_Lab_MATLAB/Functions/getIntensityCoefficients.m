function [baseline,standardDev] = getIntensityCoefficients(validDots,frame)
%validDots is a variable in the calling function which contains the
%locations and identities of all dots being saved
%It is important to remember to call this function using the unadjusted
%version of the pma file, called frame2, as the second argument
for i = 1:size(validDots,1)
    x0 = validDots(i,1);
    y0 = validDots(i,2);
    x1 = round(x0);
    y1 = round(y0);
    slice = double(frame(y1-2:y1+2,x1-2:x1+2,:));
    intensityi = getIntensity(slice, x0, y0); %Intensity at every frame
    standardDev(i) = std(intensityi);
    baseline(i) = mean(intensityi); %mean of those intensities; every trace
    %is then divided by its respective baseline (happens outside the
    %function)
end

end
