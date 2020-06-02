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
    
    handles.btn6 = uicontrol('Style', 'pushbutton', 'String', 'Reset',...
        'Position', [570 5 80 20],...
        'UserData', 7, 'Callback', @buttonCallback); 
 
    fig = gcf;
    uiwait(fig);
    if ~exist('output','var')
        output.Value = 6; % signal that it was closed without any buttons pushed
    end

    function buttonCallback(hObject,~)
        output.Value = hObject.UserData;
        switch output.Value
            case 4
                anS = inputdlg(['Please enter an integer number of frames; all'...
                    ' events of this length or less will be snapped to'...
                    ' a nearby state']);
                try
                    deadFrames = str2double(anS{:}); %if the user closes without answering
                    assert(isinteger(deadFrames)) %or gives something not an integer?
                catch
                    deadFrames = 0; %signal to not do the deadTime thing
                end
                output.deadFrames = deadFrames;
                close(gcf);
            case 5
                brush;
                set(handles.btn,'enable','off');
                set(handles.btn2,'enable','off');
                set(handles.btn3,'enable','off');
                set(handles.btn4,'enable','off');
                set(handles.btn5,'UserData',0);
                set(handles.btn5,'String','Assign Brushed');
                set(handles.btn6,'UserData',8);
                set(handles.btn6,'String','Cancel');
            case 0
                for i = 1:length(ax1)
                    output.brushing{i} = get(ax1{i}, 'BrushData');
                end
                close(gcf);
            case 8 %cancel that brushing
                for i = 1:length(ax1)
                    output.brushing{i} = [];
                end
                set(handles.btn,'enable','on');
                set(handles.btn2,'enable','on');
                set(handles.btn3,'enable','on');
                set(handles.btn4,'enable','on');
                set(handles.btn5,'UserData',5);
                set(handles.btn5,'String','Manual Set');
                set(handles.btn6,'UserData',7);
                set(handles.btn6,'String','Reset');
                brush off
            otherwise
                close(gcf);
        end
    end
end
