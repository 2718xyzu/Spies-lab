function [outputText] = stateSetUi(channels,stateList)
    %This interface allows users to specify a sequence of states they would 
    %like to search for within the data
    %

    guiWindow = figure('Visible', 'on', 'Position', [1000 1000 500 200]);
    guiWindow.MenuBar = 'none';
    guiWindow.ToolBar = 'none';
    
    dropDownOpt = cell([1 channels]);
    dropDowns = cell([1 channels]);
    searchText = 'Baseline state: ';
    for i = 1:channels
        dropDownOpt{i}{1} = 'Any';
        for j = 1:stateList(i)
            dropDownOpt{i}{j+1} = num2str(j);
        end
    end

    btn = uicontrol('Style', 'pushbutton', 'String', 'Set',...
            'Position', [230 10 40 30],...
            'UserData', 1,'Callback', @searchCallback); 
        
%     btn2 = uicontrol('Style', 'pushbutton', 'String', 'Add to Search',...
%             'Position', [140 10 80 30],...
%             'UserData', 2,'Callback', @addCallback); 
        
%     btn3 = uicontrol('Style', 'pushbutton', 'String', 'Remove Previous',...
%             'Position', [50 10 80 30],...
%             'UserData', 3,'Callback', @removeCallback,'Enable','off'); 
    
    for dd = 1:channels
        dropDowns{dd} = uicontrol('Style', 'popupmenu', 'String', dropDownOpt{dd},  ...
            'Position', [-80+80*dd 40 70 30], 'Callback', @dropDownCallback);
    end

        
    instructions = uicontrol('Style', 'text', 'String', ['Select the ' ...
            'states desired for the beginning and ending of all default' ...
            ' search results (i.e. baseline state)'], ...
            'Units','normalized','Position', [.1 .7 .8 .27], 'FontSize', 16);
        
    searchString = uicontrol('Style', 'text', 'String', 'Search String Unspecified', ...
            'Units','normalized','Position', [.1 .4 .8 .2], 'FontSize', 14);
        
        fig = gcf;
        uiwait(fig);
        
    function dropDownCallback(~,~)
        stateSearch = zeros([1 channels]);
        stateText = [];
        for k = 1:channels
            stateSearch(k) = get(dropDowns{k},'Value')-1;
            stateText = ['  ' dropDownOpt{k}{(get(dropDowns{k},'Value'))} ' ' ];
            %puts stateText as a string of the format ' \d  \d  \d ... \d '
            %The number of spaces is important
        end
        set(searchString, 'String', [searchText stateText ]);
        stateSearch(stateSearch == 0) = NaN;
        outputText = mat2str(stateSearch);
    end

   

    function searchCallback(~,~)
        try
            delete(instructions);
            delete(btn);
        catch
        end
        close(gcf);
    end

end