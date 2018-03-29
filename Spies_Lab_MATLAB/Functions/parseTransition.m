function parseTransition(transition, channels, stateList)
    powerAddition = [0 cumsum(stateList)];
    matrix = zeros(1+stateList*2);
    matrixFinal = matrix;
        for j = 1:channels
            for i = 1:size(matrix,j)
                state = i-stateList(j)-1;
                S.subs = repmat({':'},1,ndims(matrix));
                S.subs(j) = {i};
                S.type = '()';
                if state > stateList(j)
                    value = 2.^(powerAddition(j)+state-1);
                elseif state < stateList(j)
                    value = -1*2.^(powerAddition(j)+state-1);
                else
                    value = 0;
                end
                matrix = subsasgn(matrix,S,value); %all states represented as binary #'s
                i=i+1; %move to the next row
            end
            matrixFinal = matrixFinal + matrix;
        end


    transition(1) = '[';
    transition(end) = ']';
    transition = eval(transition);
    for i=1:length(transition)
        %Was this meant to be finished?
    end
end
