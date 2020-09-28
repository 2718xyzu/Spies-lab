function [h,timeLengths] = rowAnalyze(row,Results,lettersBig,timeData,nonZeros,names)
    expr = strjoin(Results(row(1)).expr);
    out = regExAnalyzer(expr,lettersBig,timeData,nonZeros,names);
    timeLengths = out.timeLengths;
    figure(2);
    h = histogram(timeLengths,150:200:20050,'Normalization','countdensity');
    figure(3);
    histogram(log(timeLengths),5:.125:11,'Normalization','pdf');
    figure(4);
    histogram(log(timeLengths),5:12,'Normalization','pdf');
    figure(6);
    histogram(log(timeLengths),[log(150:100:550) log(650:300:1850) log(2150:1000:10550) log(11550:5000:61550)],'Normalization','pdf');
end
