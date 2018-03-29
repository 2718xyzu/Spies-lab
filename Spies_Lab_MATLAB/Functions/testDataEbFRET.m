function matrix = testDataEbFRET(channels, states, sets, trajectoryLength)
    if length(states)<channels
        warning('"states" must be a list of length channels');
        states = states(1)*ones(1,channels);
    end
    rows = 1;
    matrix = zeros(sets*channels,trajectoryLength);

    for i = 1:sets
        for j = 1:channels
            max = states(j);
            k=0;
            temp = zeros(1);
            while k<trajectoryLength
                dwell = randi(10);
                temp(nnz(temp)+1:nnz(temp)+dwell) = ones(1,dwell)*randi(states(channels));
                k = k+dwell;
            end
            matrix(rows,:) = temp(:,1:trajectoryLength);
            rows = rows+1;
        end
    end
end
