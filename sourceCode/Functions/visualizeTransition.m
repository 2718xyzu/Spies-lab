function [x, y] = visualizeTransition(stateRecord, channels)
    %no longer used; see "createTransitionVisual" in the kera.m file
    %instead

%     transition = regexprep(transition, '[^\d ;]+','0');
%     stateRecord = eval(['[' transition ']']);
    
%     stateRecord = stateRecord';
%     [stateRecord, text] = parseTransition(transition, channels, stateList);
    y = reshape(repmat(reshape(stateRecord,[1 numel(stateRecord)]),[2 1]),[2*size(stateRecord,1) channels]);
    x = 1; 
    for i = 1:size(y,1)/2-1
        x(2*i:2*i+1) = i+1;
    end
    x = [x x(end)+1];
    x = repmat(x',[1 channels]);
    
    %x and y are arrays of column vectors
end
