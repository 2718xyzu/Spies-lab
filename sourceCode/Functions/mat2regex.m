function outChar = mat2regex(stateMat)
N = size(stateMat,1); %number of lines to analyze
c = size(stateMat,2); %number of channels
outStr = "";
for i = 1:N
    if any(isinf(stateMat(i,:)))
        if i~=1 && i ~=N %including this wildcard at the beginning or end of a search doesn't make sense
            outStr = outStr+"[^\]]+?";
        end
    else
        if i == 1 && N>2
            outStr = outStr+"(?<="; %make the first state a positive lookbehind
        end
        if i == N && N>2
            outStr = outStr+"(?="; %make the last state a positive lookahead
        end
        for j = 1:size(stateMat,2)
            if ~isnan(stateMat(i,j))
                outStr = outStr+" "+string(num2str(stateMat(i,j)))+" ";
            else
                outStr = outStr+" \d+ ";
            end
        end
        outStr = outStr+";";
        if i == 1 || i == N && N>2
            outStr = outStr+")";
        end
    end
end
outChar = char(outStr);
end
