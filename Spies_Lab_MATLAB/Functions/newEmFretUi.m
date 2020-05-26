function output = newEmFretUi
    btn = uicontrol('Style', 'pushbutton', 'String', 'Discard & Next',...
            'Position', [20 5 100 20],...
            'UserData', 1,'Callback', @buttonCallback); 
        
    btn2 = uicontrol('Style', 'pushbutton', 'String', 'Next trace',...
            'Position', [130 5 90 20],...
            'UserData',  2,'Callback', @buttonCallback); 
        
    btn3 = uicontrol('Style', 'pushbutton', 'String', 'Trim trace',...
            'Position', [230 5 90 20],...
            'UserData', 3,'Callback', @buttonCallback); 
        
    btn4 = uicontrol('Style', 'pushbutton', 'String', 'Select baseline',...
        'Position', [330 5 110 20],...
        'UserData', 4, 'Callback', @buttonCallback); 
    
    btn5 = uicontrol('Style', 'pushbutton', 'String', 'Go back',...
        'Position', [450 5 90 20],...
        'UserData', 0, 'Callback', @buttonCallback); 
 
    fig = gcf;
    uiwait(fig);
    if ~exist('output')
        output.Value = 6;
    end

    function buttonCallback(hObject,data)
        data2 = guidata(hObject); 
        output.Value = hObject.UserData;
        if output.Value == 3
            [x,~] = ginput(2);
            if round(x(1))==round(x(2))
                [x(2),~] = ginput(1);
            end
            output.trim = max(round(x),1);
        end
        if output.Value == 4
            [x,~] = ginput(2);
            if round(x(1))==round(x(2))
                [x(2),~] = ginput(1);
            end
            output.baseline = round(x);
        end
        if output.Value <= 2
            close(gcf);
        end
    end
end
