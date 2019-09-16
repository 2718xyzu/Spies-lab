function matrixFinal = getTransitionDesignationMatrix(stateList)
    channels = length(stateList);
    powerAddition = repmat([0 cumsum(stateList(1:end-1))],[1,2]);
    matrix = zeros([stateList stateList]); %creates matrix which has channels*2 dimensions
    %This matrix's elements contain the unique transition number for
    %transitions from each state to each possible state.  If the channel j
    %state is initially at cji and transitions to cjf, the designator for the
    %transition will be found at matrixFinal(c1i,c2i,c3i ... c1f,c2f,c3f ...)
    %Hence the channels*2 dimensionality of the matrix.  If there is only one channel,
    %This simplifies considerably to matrixFinal(i,f).
    matrixFinal = matrix;
    for j = 1:length(stateList)*2
        for i = 1:size(matrix,j)
            state = i;
            S.subs = repmat({':'},1,ndims(matrix));
            S.subs(j) = {i};
            S.type = '()';
            value = ((j>channels)*2-1)*2.^(powerAddition(j)+state-1);
            matrix = subsasgn(matrix,S,value);
        end
        matrixFinal = matrixFinal + matrix;
    end

end