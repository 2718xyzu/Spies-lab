function [dataCy3,dataCy5] = bulkOpen()
    numCol = str2double(strjoin(inputdlg('How many colors are being analyzed?')));
    directories = cell(1,numCol);
    dir3 = {0};

    for color = 1:numCol
        directories(color) = inputdlg(['Please paste the path of the folder with the appropriate color of traces.  The folder'...
            ' itself must be in the path. \n Terminate the path with a slash']);

        dir2 = dir([strjoin(directories(color)) '*.dwt']);
        dir3(color,1:numel({dir2.name})) = { dir2.name };
        lengtH = length(dir3(color,:));
        lengtH = length(dir3(color,:));
        startIndex = 3;
        endIndex = 0;
        for i=1:lengtH
            if ~isempty(dir3{color,i})
                max = [0,0,0];
                string = strjoin(dir3(color,i));
                lengthStr = length(string);
                if endIndex == 0
                    endIndex = lengthStr;
                end
                names(color,i) = cellstr(string);
                for j = startIndex:endIndex
                    for k = j:(lengthStr)
                        y = str2double(string(j:k));
                        if y >= max(1)
                        max = [y,j,k];
                        end
                    end
                end
                nums(color, i) = max(1);
            end
        end
    end

    pairs = zeros(length(dir3),numCol);
    for i = 1:length(dir3)
        if ~isempty(dir3{1,i})
            for j = 2:size(nums,1)
                for k = 1:length(nums)
                    if nums(j,k) == nums(1,i)
                        pairs(i,1) = i;
                        pairs(i,j) = k;
                    end
                end
            end
        end
    end

    pairs = reshape(nonzeros(pairs),[],numCol);
    dataCy3 = zeros(10,2,length(pairs));
    dataCy5 = zeros(10,2,length(pairs));
    for i = 1:length(pairs);
        for j = 1:numCol
            if pairs(i,j) ~= 0
                imported = importdata([strjoin(directories(j)) strjoin(dir3(j,pairs(i,j)))],'\t',1);
                lengtH = size(imported.data,1);
                if j == 1
                    dataCy3(1:lengtH,:,i) = imported.data;
                else
                    dataCy5(1:lengtH,:,i) = imported.data;
                end
            end
        end
    end
end
