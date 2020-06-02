function [finalRaw, finalDiscrete] = autoDeadTime(raw, discrete, deadFrames)
%Function to intelligently fill events which are shorter than a length of
%(deadFrames+1).  Mostly, this is intended to fill single-frame gaps due to
%noise, such as [1 1 1 1 1 2 1 1 1 1 ] where it is unambiguous where the
%jump belongs (replace 2 with 1 in the above example).  However, it is
%conceivable that an event such as [1 1 1 2 2 3 3 3 3 ] could become [1 1 1 1
%3 3 3 3 3].  In the cases where a short event is nearly the length of
%(deadFrames+1), it is fair to ask whether it should in fact be lengthened;
%In that case, [1 1 1 2 2 3 3 3 ] might become [1 1 1 2 2 2 3 3 3].
%Gaussian priors for each state based on the individual trace are used to
%create a maximum-likelihood estimate for the solution which eliminates
%short events

%raw: a 1xN array of raw trace values (the data before discretization)
%discrete: a 1xN array of integers (the discretized data; the states)
%deadFrames: the length of events to be eliminated (minimum: 1)

finalRaw = raw;
finalDiscrete = discrete;
if isempty(deadFrames) || ~isinteger(deadFrames) || deadFrames<1
    return %something is wrong
end
N = length(raw);
% if deadFrames>1
%     warning('deadTime function does not yet support event lengths longer than 1');
%     return
% end

discrete = reshape(discrete,[1 length(discrete)]);
raw = reshape(discrete,[1 length(raw)]);
indices = find(diff([0 discrete]));
meanState = zeros([1 max(discrete)]);
stdState = zeros([1 max(discrete)]);
for state = 1:max(discrete)
    meanState(state) = mean(raw(discrete==state));
    stdState(state) = std(raw(discrete==state));
end
I = zeros(size(raw));
for j = find(diff(indices)<=deadFrames)'
    segment = indices(j):(indices(j+1)-1);
    add = ones([1 (2+deadFrames-length(segment))]); 
    %holds the likelihood of the solutions which append points on either
    %side of the event
    remove = 1; %the likelihood of the solution which assigns all
    %points in the event to nearby states
    c = discrete(segment(1)); %the current state of the short event
    if length(segment)==1 && segment > 1 && segment < N
        if discrete(segment-1) == discrete(segment+1)
            discrete(segment) = discrete(segment-1);
        end
        continue %if this is an obvious single-frame spike, don't bother with the Likelihood stuff
    end
    
    
    for k = segment
        L = 1./(stdState).*exp(-.5*((raw(k)-meanState)./stdState).^2);
        L(c) = 0;
        [removeTerm,I(k)] = max(L);
        remove = remove*removeTerm;
    end
    
    for addI = 1:length(add)
        for addJ = (segment(1)-length(add)+addI):(segment(end)-1+addI)
            if addJ < 1 || addJ >= N
                add(addI) = 0; %we'd be adding a point that doesn't exist
            else
                L = 1/(stdState(c))*exp(-.5*((raw(addJ)-meanState(c))/stdState(c))^2);
                add(addI) = add(addI)*L; %a point already in the event or to be added
            end
        end
    end
    if all(remove>add)
        finalDiscrete(segment) = I(segment); %assign that event's values to nearby states
    else                             %OR
        [~,addI] = max(add);
        finalDiscrete((segment(1)-length(add)+addI):(segment(end)-1+addI)) = c;
        %fill nearby time points with same state to make the event longer
    end

end



end