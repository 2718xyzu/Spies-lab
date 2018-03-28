%Joseph Tibbs
%Last updated: 6/12

function trace = getIntensity(slice,x0,y0)
expM = zeros(5);
for i1 = -2:2
    for i2 = -2:2
        expM(i1+3,i2+3) = exp(-(abs(-i1+x0)-round(x0))^2-(abs(-i2+y0)-round(y0))^2);
    end
end
for i = 1:length(slice)
    slice(:,:,i) = slice(:,:,i).*expM;
end
slice = sum(slice,1);
trace = squeeze(sum(slice,2));
end