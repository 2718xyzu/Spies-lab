function smoothed = smoothTrace(trace)
    v = version('-release');
    if str2double(v(1:4))<2017
        lengtH = length(trace);
        stairs = zeros(7,lengtH);
        A = [.06 .12 .2 .24 .2 .12 .06];

        for i = 1:7
            stairs(i,i+2:(lengtH-10+i)) = trace(6:lengtH-6)*A(i);
        end
        smoothed = sum(stairs,1);
        smoothed(1:8) = trace(1:8);
        smoothed(length(trace)-8:length(trace)) = trace(length(trace)-8:length(trace));
    else
        smoothed = smoothdata(trace,2,'movmean',5);
    end
end
