function [searchArray] = stateSearchUi(channels,stateList)
    %This interface allows users to specify a sequence of states they would 
    %like to search for within the data
    %

    dropDownOpt = cell([1 channels]);
    dropDowns = cell([1 channels]);
    stateCell = {};
    searchArray = [];
    searchText = {'Search text'};
    lengtH = 0;
    for i = 1:channels
        dropDownOpt{i}{1} = 'Any';
        for j = 1:stateList(i)
            dropDownOpt{i}{j+1} = num2str(j);
        end
    end

    btn = uicontrol('Style', 'pushbutton', 'String', 'Search',...
            'Position', [380 10 50 30],...
            'UserData', 1,'Callback', @searchCallback); 
        
    btn2 = uicontrol('Style', 'pushbutton', 'String', 'Add to Search',...
            'Position', [140 10 80 30],...
            'UserData', 2,'Callback', @addCallback); 
        
    btn3 = uicontrol('Style', 'pushbutton', 'String', 'Remove Previous',...
            'Position', [50 10 90 30],...
            'UserData', 3,'Callback', @removeCallback,'Enable','off'); 
        
    btn4 = uicontrol('Style', 'pushbutton', 'String', 'Add N-state wildcard',...
            'Position', [230 10 140 30],...
            'UserData', 4,'Callback', @nStateCallback);
    
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
            tempText = [stateText ' ' dropDownOpt{k}{(get(dropDowns{k},'Value'))} ' '];
            stateText = tempText;
        end
        searchArray(lengtH+1,:) = stateSearch;
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
        searchArray(end,:) = [];
        set(searchString, 'String', strjoin(searchText,' ;'));
        lengtH = size(searchArray,1);
        if lengtH == 0
            set(hObject,'Enable','off');
        end
    end    

    function nStateCallback(~,~)
        stateText = repmat('Inf ',[1 channels]);
        searchArray(lengtH+1,:) = Inf([1 channels]);
        searchText{lengtH+2} = stateText;
        set(searchString, 'String', strjoin(searchText,';'));
        lengtH = lengtH+1;
        set(btn3,'Enable','on');
    end


    function searchCallback(~,~)
        try
            stateCell = searchText(2:end);
            searchText = strjoin(stateCell,';');
            searchText = regexprep(searchText,'Any', 'NaN');
            searchText = ['[' searchText ']'];
            searchArray(searchArray==0) = NaN;
            delete(instructions);
            delete(btn);
            delete(btn2);
            delete(btn4);
        catch
        end
        close(gcf);
    end

end