N = 300;
lengthTrace = 6000;
cy3Final = cell([N 1]);
cy5Final = cell([N 1]);
s3 = 3;
s5 = 2;
t = 30/6000;
t2 = 50/6000;
transition_matrix3 = cat(3, [ 1-t, t, 0; t, 1-2*t, t ; 0, t, 1-t],...
                            [ 1-2*t t t; .5*t  1-2*t 1.5*t ; 0 t 1-t]);
transition_matrix5 = cat(3, [ 1-t2 t2; t2 1-t2], ...
                            [ 1-2*t2 2*t2; t2 1-t2],...
                            [ 1-t2 t2; 3*t2 1-3*t2]);
                        

markovCell = cell([s3,s5]);

for i = 1:s3
    for j = 1:s5
        for i2 = 1:s3
            for j2 = 1:s5
                markovCell{i,j}(i2,j2) = transition_matrix3(i,i2,j)*transition_matrix5(j,j2,i);
            end
        end
    end
end
                        

for i = 1:N
    cy3 = zeros([1 lengthTrace]);
    cy5 = zeros([1 lengthTrace]);
    cy3(1) = randi(s3);
    cy5(1) = randi(s5);
    for j = 2:lengthTrace
        prob3 = markovCell{cy3(j-1),cy5(j-1)};
        accept = 0;
        while ~accept
            val3 = randi(s3);
            val5 = randi(s5);
            test = prob3(val3,val5);
            accept = rand<test;
        end
        cy3(j) = val3;
        cy5(j) = val5;
    end
    cy3Final{i} = cy3./s3+randn(size(cy5))/40;
    cy5Final{i} = cy5./s5+randn(size(cy5))/40;
end
filenames = cell([1 N]);
for i = 1:N
    filenames{i} = num2str(i);
end
saveEmFret(cy3Final,1, filenames);
saveEmFret(cy5Final,2, filenames);