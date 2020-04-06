function [searchText] = stateSearchUi(channels,stateList)
    %This interface allows users to specify a sequence of states they would 
    %like to search for within the data
    %

    dropDownOpt = cell([1 channels]);
    dropDowns = cell([1 channels]);
    stateCell = {};
    searchArray = {};
    searchText = {'Search text'};
    lengtH = 0;
    for i = 1:channels
        dropDownOpt{i}{1} = 'any';
        for j = 1:stateList(i)
            dropDownOpt{i}{j+1} = num2str(j);
        end
    end

    btn = uicontrol('Style', 'pushbutton', 'String', 'Search',...
            'Position', [230 10 40 30],...
            'UserData', 1,'Callback', @searchCallback); 
        
    btn2 = uicontrol('Style', 'pushbutton', 'String', 'Add to Search',...
            'Position', [140 10 80 30],...
            'UserData', 2,'Callback', @addCallback); 
        
    btn3 = uicontrol('Style', 'pushbutton', 'String', 'Remove Previous',...
            'Position', [50 10 80 30],...
            'UserData', 3,'Callback', @removeCallback,'Enable','off'); 
    
    for dd = 1:channels
        dropDowns{dd} = uicontrol('Style', 'popupmenu', 'String', dropDownOpt{dd},  ...
            'Position', [-80+80*dd 40 70 30], 'Callback', @dropDownCallback);
    end

        
    instructions = uicontrol('Style', 'text', 'String', ['Select the ' ...
            'states desired for the beginning of the event, then click' ...
            ' "add" to specify sequential transitions'], ...
            'Units','normalized','Position', [.1 .8 .8 .17]);
        
    searchString = uicontrol('Style', 'text', 'String', 'Search String Unspecified', ...
            'Units','normalized','Position', [.1 .4 .8 .2]);
        
        fig = gcf;
        uiwait(fig);
    function dropDownCallback(~,~)
        stateSearch = zeros([1 channels]);
        stateText = [] ;
        for k = 1:channels
            stateSearch(k) = get(dropDowns{k},'Value')-1;
            stateText = [stateText ' ' dropDownOpt{k}{(get(dropDowns{k},'Value'))} ' '];
        end
        searchArray{lengtH+1} = stateSearch;
        searchText{lengtH+2} = stateText;
        set(searchString, 'String', strjoin(searchText,';'));
    end

    function addCallback(~,~)
        dropDownCallback;
        lengtH = lengtH+1;
        set(btn3,'Enable','on');
    end
    
    function removeCallback(hObject,~)
        searchText(end) = [];
        searchArray(end) = [];
        set(searchString, 'String', strjoin(searchText,' ;'));
        lengtH = length(searchArray);
        if lengtH == 0
            set(hObject,'Enable','off');
        end
    end    

    function searchCallback(~,~)
        try
            stateCell = searchText(2:end);
            searchText = strjoin(stateCell,';');
            searchText = regexprep(searchText,'any', '\\d+');
            delete(instructions);
            delete(btn);
            delete(btn2);
        catch
        end
        close(gcf);
    end

end