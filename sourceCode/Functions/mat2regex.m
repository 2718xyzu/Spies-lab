function outStr = mat2regex(stateMat)
c = size(stateMat,2); %number of channels
outStr = "";
for i = 1:size(stateMat,1)
    if any(isinf(stateMat(i,:)))
        outStr = outStr+"[^\]]+?";
    else
        for j = 1:size(stateMat,2)
            if ~isnan(stateMat(i,j))
                outStr = outStr+" "+string(num2str(stateMat(i,j)))+" ";
            else
                outStr = outStr+" \d+ ";
            end
        end
        outStr = outStr+";";
    end
end