function [stateRecord, text] = parseTransition(transition, channels, stateList)

powerAddition = repmat([0 cumsum(stateList(1:end-1))],[1,2]);
matrix = zeros([stateList stateList]);
matrixFinal = matrix;
    for j = 1:channels*2
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

if transition(1) == '_' && transition(end) == '_'
    transition(1) = '[';
    transition(end) = ']';
else
    transition = ['[' transition ']'];
end
transition = eval(transition); %turning the text back into an array
text = ''; 
initialText = '';
stateRecord = zeros([channels,length(transition)+1]);
for i=1:length(transition)
    subs = cell(1,length(size(matrixFinal)));
    textAdd = '';
    index = find(transition(i) == matrixFinal,1);
    if ~isempty(index)
        [subs{:}] = ind2sub(size(matrixFinal),index);
        for k = find(diff(cell2mat([subs(1:channels); subs(channels+1:end)])))
            if stateRecord(k,1) == 0 
                stateRecord(k,1:i) = subs{k};
                initialText = [initialText 'Channel ' num2str(k) ' starts in state ' num2str(subs{k}) '; '];
            end
            stateRecord(k,i+1:end) = subs{channels+k};
            textAdd = ['Channel ' num2str(k) ' transitions to state ' num2str(subs{channels+k})];
        end
    
    else
        textAdd = 'invalid transition number';
    end
    text = [text '; ' textAdd];
end
text = [initialText, text];
stateRecord = stateRecord';
end
