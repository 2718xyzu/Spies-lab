s3 = 3;
s5 = 2;
t = 30/6000;
t2 = 50/6000;
transition_matrix3 = cat(3, [ 1-t, t, 0; t, 1-2*t, t ; 0, t, 1-t],...
                            [ 1-2*t t t; .5*t  1-2*t 1.5*t ; 0 t 1-t]);
transition_matrix5 = cat(3, [ 1-t2 t2; t2 1-t2], ...
                            [ 1-2*t2 2*t2; t2 1-t2],...
                            [ 1-t2 t2; 3*t2 1-3*t2]);

markovMat = zeros([s3,s5,s3,s5]);

for i = 1:s3
    for j = 1:s5
        for i2 = 1:s3
            for j2 = 1:s5
                markovMat(i2,j2,i,j) = transition_matrix3(i,i2,j)*transition_matrix5(j,j2,i);
            end
        end
    end
end

start = rand([s3,s5]);
start = start./(sum(start,'all'));



for k = 1:10000
    start = markovMultidimensional(start,markovMat);
    start = start./(sum(start,'all'));
end

