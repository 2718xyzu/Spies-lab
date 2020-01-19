function [stateCell] = stateSearchUi(channels,stateList)
    %This interface allows users to specify a sequence of states they would 
    %like to search for within the data
    %

    dropDownOpt = cell([1 channels]);
    dropDowns = cell([1 channels]);
    channel = 1;
    stateCell = {};
    lengtH = 0;
    for i = 1:channels
        dropDownOpt{i}{1} = '.';
        for j = 1:stateList(i)
            dropDownOpt{i}{j+1} = num2str(j);
        end
    end

    btn = uicontrol('Style', 'pushbutton', 'String', 'Search',...
            'Position', [230 10 40 30],...
            'UserData', 1,'Callback', @searchCallback); 
        
    btn2 = uicontrol('Style', 'pushbutton', 'String', 'Add to Search',...
            'Position', [180 10 40 30],...
            'UserData', 2,'Callback', @addCallback); 
        
    btn3 = uicontrol('Style', 'pushbutton', 'String', 'Remove Previous',...
            'Position', [180 10 40 30],...
            'UserData', 3,'Callback', @removeCallback,'Enable','off'); 
        
    dropdown = uicontrol('Style', 'popupmenu', 'String', dropDownOpt,  ...
            'Position', [10 10 80 30], 'Callback', @dropDownCallback);

        
    instructions = uicontrol('Style', 'text', 'String', ['Select the ' ...
            'channel you wish to search within, and enter a comma-' ...
            'separated list of the states transitioned between'], ...
            'Position', [10 45 200 40]);
        
    searchString = uicontrol('Style', 'text', 'String', '....', ...
            'Position', [10 45 200 40]);
        
        fig = gcf;
        uiwait(fig);
    function dropDownCallback(hObject,data)
        stateSearch = zeros([1 channels]);
        stateText = [];
        for k = 1:channels
            stateSearch(k) = str2double(get(dropDowns{k},'Value'));
            stateText = [stateText ' ' get(dropDowns{k},'Value')]
        end
        searchArray{lengtH+1} = stateSearch;
        searchText{lengtH+1} = stateText;
        set(searchString, 'String', strjoin(searchText,' ;'));
    end

    function addCallback(hObject,data)
        lengtH = lengtH+1;
        set(btn3,'Enable','on');
    end
    
    function removeCallback(hObject,data)
        lengtH = lengtH-1;
    end    



end