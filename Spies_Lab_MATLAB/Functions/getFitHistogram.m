function fitModel = getFitHistogram(h1,fitType,order)
    x = h1.BinEdges(1:end-1)+diff(h1.BinEdges)/2;
    y = h1.Values;
    if fitType == 1
        model = ['exp' num2str(order)];
    else
        model = ['gauss' num2str(order)];
    end

    fitModel = fit(x',y',model);
end
