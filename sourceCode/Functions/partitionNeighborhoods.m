function statusList = partitionNeighborhoods(xList, yList, nSize, fieldSize,nDots)
    %a microscope analysis code; not part of Kera
    neighborhoods = zeros(2*ceil(ceil(prod(fieldSize)/nSize)/nSize),8,'int16');
    statusList = zeros(nDots,1);
    n = zeros(1,8);
    nDots = length(xList);
    for i = 1:nDots
        if xList(i)*yList(i)~=0
            x = xList(i);
            y = yList(i);
            n(1,1) = (ceil(fieldSize(1)/nSize)+1)*ceil(x/nSize)+ceil(y/nSize);
            n(1,2) = (ceil(fieldSize(1)/nSize)+1)*round(x/nSize)+ceil(y/nSize);
            n(1,3) = (ceil(fieldSize(1)/nSize)+1)*ceil(x/nSize)+round(y/nSize);
            n(1,4) = (ceil(fieldSize(1)/nSize)+1)*round(x/nSize)+round(y/nSize)+1;
            for j = 1:4
                nj = n(1,j);
                if neighborhoods(nj,j) == 0
                    neighborhoods(nj,j) = i;
                else
                    statusList(i) = 1;
                    statusList(neighborhoods(nj,j)) = 1;
                end
            end
        end
    end
end
