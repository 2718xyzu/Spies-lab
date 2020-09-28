function call3 = FRETui
    btn = uicontrol('Style', 'pushbutton', 'String', 'Next',...
            'Position', [20 20 50 20],...
            'UserData', 10 ,'Callback', @buttonCallback); 
        
    btn2 = uicontrol('Style', 'pushbutton', 'String', 'Save Trace',...
            'Position', [80 20 70 20],...
            'UserData', 1, 'Callback', @buttonCallback); 
        
    btn3 = uicontrol('Style', 'pushbutton', 'String', 'Cut and Save Trace',...
        'Position', [160 20 110 20],...
        'UserData', 3, 'Callback', @buttonCallback); 

    btn4 = uicontrol('Style', 'pushbutton', 'String', 'Go to specific trace',...
            'Position', [280 20 110 20],...
            'UserData', 5, 'Callback', @buttonCallback); 
        
    btn5 = uicontrol('Style', 'pushbutton', 'String', 'Back',...
            'Position', [400 20 50 20],...
            'UserData', 0, 'Callback', @buttonCallback); 
    fig = gcf;
    uiwait(fig);
    if ~exist('call3')
        call3.Value = 6;
    end

    function buttonCallback(hObject,data)
        data2 = guidata(hObject); 
        call3.Value = hObject.UserData;
        if call3.Value == 3
            [x,~] = ginput(2);
            if round(x(1))==round(x(2))
                [x(2),~] = ginput(1);
            end
            call3.xValues = x;
        end
        close(gcf);
    end
end
