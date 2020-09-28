function [A,path,name,extension] = openFileGeneric(directionsPath,directionsFile)
    path = strjoin(inputdlg(directionsPath));
    if path(length(path)) ~= '\' && path(length(path)) ~= '/'
        path(length(path)+1) = path(1);
    end

    fileName = strjoin(inputdlg(directionsFile));
    A = fopen([path fileName]);
    for i = 1:length(fileName)
        if fileName(i) == '.'
            j = i;
        end
    end

    name = fileName(1:j-1);
    extension = fileName(j:length(fileName));
end
