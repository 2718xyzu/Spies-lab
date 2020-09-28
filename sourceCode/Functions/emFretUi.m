function call3 = emFretUi
    btn = uicontrol('Style', 'pushbutton', 'String', 'Next',...
            'Position', [20 20 50 20],...
            'UserData', 10 ,'Callback', @buttonCallback); 
        
    btn3 = uicontrol('Style', 'pushbutton', 'String', 'Select baseline',...
        'Position', [160 20 110 20],...
        'UserData', 3, 'Callback', @buttonCallback); 
 
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
