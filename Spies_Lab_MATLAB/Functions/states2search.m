function searchExpr = states2search(stateList, channel, transitionList)
    channelS = length(stateList);
    matriX = getTransitionDesignationMatrix(stateList);
    searchExpr = ' ';
    for i = 1:length(transitionList)-1
        S.subs = repmat({1},1,ndims(matriX));
        S.subs(channel) = {transitionList(i)};
        S.subs(channelS+channel) = {transitionList(i+1)};
        S.type = '()';
        searchExpr = [searchExpr num2str(subsref(matriX,S)) '  '];
    end
    searchExpr = [' ' searchExpr '[^,]'];
end
