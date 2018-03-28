function smoothed = smoothTrace3Point(trace)
lengtH = length(trace);
stairs = zeros(3,lengtH);
A = [.25 .5 .25];

for i = 1:3
    stairs(i,i+2:(lengtH-4+i)) = trace(3:lengtH-3)*A(i);
end

% 
% for i = 6:(length(trace)-6)
%     
%     %smoothed(i) = trace(i-3:i+3)*A;
% end
smoothed = sum(stairs,1);
smoothed(1:4) = trace(1:4);
smoothed(length(trace)-4:length(trace)) = trace(length(trace)-4:length(trace));
end