function [fit1, bin1, chi1, fit2, bin2, chi2] = szoszkiewiczHistFit(x,order)
%methods from Szoszkiewicz et al 2008
%"order" currently only supports first- or second-order fitting
%x is the dwell time data as a list of numbers
%linear histogram
if numel(x)<6
    %definitely can't fit if there aren't enough data points
    fit1 = 0;
    bin1 = 0;
    chi1 = 0;
    fit2 = 0;
    bin2 = 0;
    chi2 = 0;
    return
end
dt = zeros([2 1]);
dt(1) = range(x,'all')/(numel(x)*10);
i = 1;
chiR = zeros([2 1]);
switch order
    case 1
        model = 'exp1';
    case 2
        model = 'exp2';
end
optimalBin = 0;
minX = min(x);
maxX = max(x);
while ~optimalBin
    [ordinate, edges] = histcounts(x,minX:dt(i):(maxX+dt(i)));
    abscissa = edges(1:end-1)+dt(i)/2;
%     ordinate = ordinate/sum(ordinate);
    f = fit(abscissa',ordinate',model);
    sigma = sqrt(ordinate);
    chiR(i) = reducedChi(abscissa, ordinate, f, sigma, order);
    dt(i+1) = dt(i)*1.05;
    i = i+1;
    if numel(ordinate)<sqrt(numel(x))/2
        %if we've gotten to the point where there are half as many bins as
        %the square root of the number of data points, then we should start
        %checking to see if we've hit the minimum chi-squared point yet
        smoothedDChi = smoothdata(diff(chiR),'movmean',10);
        if nnz(sign(smoothedDChi)==1)>numel(smoothedDChi)/4
            %make sure we've passed the minimum by seeing that the value of
            %reduced Chi has been increasing for at least the last 25% of
            %the trials
            %This is an acceptable emprical method because chiR should have
            %just one minimum
            [chi1, minI] = min(chiR);
            bin1 = minX:dt(minI):(maxX+dt(minI));
            [ordinate, edges] = histcounts(x,bin1);
            abscissa = edges(1:end-1)+dt(minI)/2;
            ordinate = ordinate/sum(ordinate);
            fit1 = fit(abscissa',ordinate',model);
            optimalBin = 1;
        end
    end
end

%logarithmic histogram

switch order
    case 1
        fitLower = [eps, eps];
        model = fittype(@(a1,k1,x) (a1*exp(x+log(k1)-exp(x+log(k1)))));
    case 2
        fitLower = [eps, eps];
        model = fittype(@(a1,k1,a2,k2,x) (a1*exp(x+log(k1)-exp(x+log(k1)))+...
            a2*exp(x+log(k2)-exp(x+log(k2)))));
end

x(x<=0)=[];
x = log(x);
dt = zeros([2 1]);
dt(1) = range(x,'all')/(10*numel(x));
i = 1;
chiR = zeros([2 1]);
optimalBin = 0;
minX = min(x);
maxX = max(x);
while ~optimalBin
    [ordinate, edges] = histcounts(x,minX:dt(i):(maxX+dt(i)));
    abscissa = edges(1:end-1)+dt(i)/2;
    ordinate = sqrt(ordinate);
    f = fit(abscissa',ordinate',model,'Lower',fitLower,'StartPoint',repmat([mean(x) max(ordinate)],[1 order]));
    sigma = .5;
    chiR(i) = reducedChi(abscissa, ordinate, f, sigma, order);
    dt(i+1) = dt(i)*1.05;
    i = i+1;
    if numel(ordinate)<sqrt(numel(x))/2
        %if we've gotten to the point where there are half as many bins as
        %the square root of the number of data points, then we should start
        %checking to see if we've hit the minimum chi-squared point yet
        smoothedDChi = smoothdata(diff(chiR),'movmean',10);
        if nnz(sign(smoothedDChi)==1)>numel(smoothedDChi)/4
            %make sure we've passed the minimum by seeing that the value of
            %reduced Chi has been increasing for at least the last 25% of
            %the trials
            %This is an acceptable emprical method because chiR should have
            %just one minimum
            [chi2, minI] = min(chiR);
            bin2 = round(range(x,'all')/dt(minI));
            [ordinate, edges] = histcounts(x,bin2);
            abscissa = edges(1:end-1)+dt(minI)/2;
            ordinate = ordinate/sum(ordinate);
            fit2 = fit(abscissa',ordinate',model,'Lower',fitLower,'StartPoint',repmat([mean(x) max(ordinate)],[1 order]));
            optimalBin = 1;
        end
    end
end



    function chiR = reducedChi(abscissa, ordinate, f, sigma, order)
        chiSquared = sum(((ordinate-(f(abscissa))')./max(sigma,.5)).^2);
        chiR = chiSquared/(numel(ordinate)-order);
    end


end

