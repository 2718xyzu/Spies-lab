function output = newEmFretUi
    btn{1} = uicontrol('Style', 'pushbutton', 'String', 'Discard & Next',...
            'Position', [20 5 100 20],...
            'UserData', 1,'Callback', @buttonCallback); 
        
    btn{2} = uicontrol('Style', 'pushbutton', 'String', 'Next trace',...
            'Position', [130 5 90 20],...
            'UserData',  2,'Callback', @buttonCallback); 
        
    btn{3} = uicontrol('Style', 'pushbutton', 'String', 'Trim trace',...
            'Position', [230 5 90 20],...
            'UserData', 3,'Callback', @buttonCallback); 
        
    btn{4} = uicontrol('Style', 'pushbutton', 'String', 'Select low',...
        'Position', [330 5 95 20],...
        'UserData', 4, 'Callback', @buttonCallback); 
    
    btn{5} = uicontrol('Style', 'pushbutton', 'String', 'Select high',...
        'Position', [435 5 100 20],...
        'UserData', 5, 'Callback', @buttonCallback);
    
    btn{6} = uicontrol('Style', 'pushbutton', 'String', 'Go back',...
        'Position', [545 5 90 20],...
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
            x = sort(x);
            output.trim = max(round(x),1);
        end
        if output.Value == 4
            [x,~] = ginput(2);
            if round(x(1))==round(x(2))
                [x(2),~] = ginput(1);
            end
            x = sort(x);
            output.low = round(x);
        end
        if output.Value == 5
            [x,~] = ginput(2);
            if round(x(1))==round(x(2))
                [x(2),~] = ginput(1);
            end
            x = sort(x);
            output.high = round(x);
        end
        if output.Value <= 2
            close(gcf);
        end
    end
end
