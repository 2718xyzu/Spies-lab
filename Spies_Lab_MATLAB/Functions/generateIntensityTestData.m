%Generates fake intensity data, to test the normalizer
N = 100;
states = [.1 .3, .5, .9];
noise = .01;
baseline = 0.1;
lengtH = 600;
testDataMatrix = zeros(N,lengtH);
baselines = zeros(N,2);
baselineIndices = 550:600;
for j = 1:N
    mult = rand+.3;
    trace = [];
    while length(trace)<baselineIndices(1)
        trace = [trace mult*(noise*randn(1,randi([10,90]))+.05*rand+states(randi([1,length(states)])))];
    end
    testDataMatrix(j,1:length(trace)) = trace;
    testDataMatrix(j,baselineIndices) = baseline+noise*randn(size(baselineIndices));
    baselines(j,:) = [min(baselineIndices),max(baselineIndices)];
end
testDataMatrix = testDataMatrix(:,1:lengtH);
testDataCell = cell(size(testDataMatrix,1),1);
for i = 1:size(testDataMatrix,1)
    testDataCell{i} = testDataMatrix(i,:);
end
