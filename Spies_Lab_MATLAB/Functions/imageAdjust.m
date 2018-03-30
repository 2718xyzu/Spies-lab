function [imageAdj, avg, maX] = imageAdjust(image,gain,contrastAdj)
    if length(size(image)) == 2
        avg = mean(image(:))+contrastAdj*std2(image);
        imageAdj = uint8(min(gain*((image-avg).*(uint8((image-avg)>0))),255));
        if nnz(imageAdj-254) > 100
            disp('Warning: over-exposure detected in image; decrease gain suggested');
        end
        maX = max(imageAdj(:));
        avg = mean2(imageAdj);
    elseif length(size(image)) == 3
         avg = mean(image(:))+contrastAdj*std2(image);
        imageAdj = uint8(min(gain*((image-avg).*(uint8((image-avg)>0))),255));
        if nnz(imageAdj-254) > 100*size(image,3)
            disp('Warning: over-exposure detected in image; decrease gain suggested');
        end
        maX = max(imageAdj(:));
        avg = mean2(imageAdj);
    end
end
