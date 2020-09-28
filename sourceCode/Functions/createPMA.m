function createPMA(matrix)
    a=1;
    assignin('base','a',a);
    file = 'raw5.pma';
    save(file,'a');
    A = fopen(file,'wb');
    frewind(A);
    fwrite(A,512,'uint16');
    fwrite(A,512,'uint16');
    for j=1:size(matrix,3)
        for i = 1:512
            a = max(matrix(i,:,j));
            fwrite(A,matrix(i,:,j),'uint8');
        end
    end
    fclose(A);
end
