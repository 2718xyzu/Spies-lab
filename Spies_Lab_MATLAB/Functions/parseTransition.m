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
            value = sign(i-stateList(j)-1)*2.^(powerAddition(j)+abs(state)-1);
            matrix = subsasgn(matrix,S,value); 
        end
        matrixFinal = matrixFinal + matrix;
    end


transition(1) = '[';
transition(end) = ']';
transition = eval(transition);
text = ''; 

for i=1:length(transition)
    subs = cell(1,length(size(matrixFinal)));
    textAdd = '';
    index = find(transition(i) == matrixFinal);
    if ~isempty(index)
    [subs{:}] = ind2sub(size(matrixFinal),index);
    if a ~= 0
        
    end
    
    else
        textAdd = 'complex';
    end
    text = [text '; ' textAdd];
end

end
