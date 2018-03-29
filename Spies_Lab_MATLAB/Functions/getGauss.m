function [x,y,c,w,gof] = getGauss(known,gaussFit,fo,c0,xS,yS,zS)
    if known(1) == 0
        [myfit,gof] = fit([xS,yS],zS(:),gaussFit,fo);
    else
        a = known(1);
        b = known(2);
        fo = fitoptions('Method','NonlinearLeastSquares','Lower',[0,.5],'Upper',[1.5*(max(zS)),2],'StartPoint',[47,1],'Weights',zS);
        gaussFit = fittype(@(c,w,a,b,x,y) c*exp(-((x-a).^2+(y-b).^2)/w),...
            'problem',{'a','b'}, 'coefficients',{'c','w'},'dependent',{'z'},'independent',{'x','y'});
        [myfit,gof] = fit([xS,yS],zS,gaussFit,fo,'problem',{a,b});
    end
    c = myfit.c;
    w = myfit.w;
    x = myfit.a;
    y = myfit.b;
    gof = 1/gof.rsquare;
end
