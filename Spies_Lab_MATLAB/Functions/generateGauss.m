function Gauss = generateGauss()
for i = 1:13
    i0 = (i-7)*.2;
    for j = 1:13
        j0 = (j-7)*.2;
        for i1 = 1:5
            i2 = i1-3;
            for j1 = 1:5  
                j2 = j1-3;
                fun = @(x,y) exp(-((x-i0).^2+(y-j0).^2));
                Gauss(i,j,i1,j1) = integral2(fun,i2-.5,i2+.5,j2-.5,j2+.5);
            end
        end
    end
end
end