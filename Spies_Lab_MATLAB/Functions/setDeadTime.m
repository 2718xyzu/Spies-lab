function modifiedStruct = setDeadTime(struct, deadTime)
%     deadTime = questdlg('What dead',{'0 (no action)','1 frame','2 frames','3 frames'});
% 
%     deadTime = str2double(deadTime(1));
    for i = 1:size(struct,2)
        if isstruct(struct)
        states = struct.states(i,:);
        fret = struct.fret(i,:);
        average = struct.average(i,:);
        else
            states = struct;
        end
        flagged = [];
        for j = 1:(length(states)-deadTime-1)
            slide = states(j:j+deadTime+1);
            if sum(diff(slide)~=0)>=2
                flagged = [flagged find(diff(slide)~=0,1)+1+j];
            end
        end
        flagged = unique(flagged);
        
    end
    modifiedStruct = struct;
end