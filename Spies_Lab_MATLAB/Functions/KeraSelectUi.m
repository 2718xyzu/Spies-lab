function output = KeraSelectUi(ax1)
    handles = struct;
    handles.btn = uicontrol('Style', 'pushbutton', 'String', 'Discard & Next',...
            'Position', [20 5 100 20],...
            'UserData', 1,'Callback', @buttonCallback); 
        
    handles.btn2 = uicontrol('Style', 'pushbutton', 'String', 'Next trace',...
            'Position', [130 5 90 20],...
            'UserData',  2,'Callback', @buttonCallback); 
        
    handles.btn3 = uicontrol('Style', 'pushbutton', 'String', 'Go back',...
            'Position', [230 5 90 20],...
            'UserData', 3,'Callback', @buttonCallback); 
        
    handles.btn4 = uicontrol('Style', 'pushbutton', 'String', 'Auto Deadtime',...
        'Position', [330 5 110 20],...
        'UserData', 4, 'Callback', @buttonCallback); 
    
    handles.btn5 = uicontrol('Style', 'pushbutton', 'String', 'Manual assign',...
        'Position', [450 5 110 20],...
        'UserData', 5, 'Callback', @buttonCallback); 
 
    fig = gcf;
    uiwait(fig);
    if ~exist('output','var')
        output.Value = 6;
    end

    function buttonCallback(hObject,~)
        output.Value = hObject.UserData;
        if output.Value == 4
            anS = inputdlg(['Please enter an integer number of frames; all'...
                ' events of this length or less will be snapped to'...
                ' a nearby state']);
            output.deadTime = str2double(anS{1});
        end
        if output.Value == 5
            brush;
            set(handles.btn,'enable','off');
            set(handles.btn2,'enable','off');
            set(handles.btn3,'enable','off');
            set(handles.btn4,'enable','off');
            set(handles.btn5,'UserData',0);
        end
        if output.Value == 0
            for i = 1:length(ax1)
                output.brushing{i} = get(ax1{i}, 'BrushData');
            end
        end
        if output.Value <= 3
            close(gcf);
        end
    end
end
