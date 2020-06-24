function [fitModel, rateText] = getFitHistogram(h1,fitType,order)
    x = h1.BinEdges(1:end-1)+diff(h1.BinEdges)/2;
    y = h1.Values;
    rateText = '';
    switch fitType
        case 1
            model = ['exp' num2str(order)];
            fitModel = fit(x',y',model);
            switch order
                case 1
                    rate = fitModel.b;
                case 2
                    rate = [fitModel.b fitModel.d];
            end
            for i = 1:order
                rateText = [rateText 'k' num2str(order) ' = ' num2str(rate(i)) newline];
            end
        case 2
            model = ['gauss' num2str(order)];
            fitModel = fit(x',y',model);
    end

    
end
