function [stateRecord, text] = parseTransition(transition, channels, stateList)
% a function which takes in an arbitrary transition designation (in text
% form) and determines which states the system had to go through to achieve
% that designation.  Prints out description of the transitions to command
% window.
%StateList is the list of the number of states in each channel
matrixFinal = getTransitionDesignationMatrix(stateList);

if strcmp(transition,'_[^_,]{3,}_')
    stateRecord = zeros([channels 1]);
    text = 'Wildcard: any event beginning and ending at baseline';
    return
end

transition = regexprep(transition,'[^0-9 -]','');
transition = ['[' transition ']'];
    %many searches begin and end with the '_' character, indicating
    %baseline events, or contain the wildcard or other special characters '.'.
    %This removes those, and adds the necessary brackets
    %to make the text into a readable list.
transition = eval(transition); %turning the text back into an array

text = ''; 
initialText = '';
stateRecord = zeros([channels,length(transition)+1]);
%a channels-by-transition length matrix showing the state location of each
%channel through the time of the transition.  If it is ever inconclusive
%where a channel was during this transition (because its state did not
%matter to the searcher) it will remain a row of zeroes.
for i=1:length(transition)
    subs = cell(1,length(size(matrixFinal)));
    textAdd = '';
    index = find(transition(i) == matrixFinal,1);
    if ~isempty(index)
        [subs{:}] = ind2sub(size(matrixFinal),index);
        channelsChanged = find(diff(cell2mat([subs(1:channels); subs(channels+1:end)])));
        for k = channelsChanged
            if stateRecord(k,1) == 0 
                stateRecord(k,1:i) = subs{k};
                initialText = [initialText 'Channel ' num2str(k) ' starts in state ' num2str(subs{k}) '; '];
            end
            stateRecord(k,i+1:end) = subs{channels+k};
            textAdd = [textAdd 'Channel ' num2str(k) ' transitions to state ' num2str(subs{channels+k})];
            if k<max(channelsChanged)
                textAdd = [textAdd ' at the same time as '];
            end
        end
    
    else
        textAdd = 'invalid transition number';
        warning(['Reached invalid transition number; searched for "'...
            num2str(transition(i)) '" and could not locate in matrixFinal.  Make sure the '...
            'transition designation (number) is valid for this system']);
        %hopefully unreachable if they only search for things reachable by
        %their system
    end
    text = [text '; ' textAdd];
end
text = [initialText, text];
stateRecord = stateRecord';
end
