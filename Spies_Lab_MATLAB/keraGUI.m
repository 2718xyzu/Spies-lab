classdef keraGUI < handle
    properties
        ui
    end
    methods
        function ui = keraGUI()
            ui = figure('Visible', 'off');
            ui.MenuBar = 'none';
            ui.ToolBar = 'none';
            popup = uicontrol('Style', 'popup',...
                   'String', {'parula','jet','hsv','hot','cool','gray'},...
                   'Position', [20 340 100 50],...
                   'Callback', @setmap);

            btn = uicontrol('Style', 'pushbutton', 'String', 'Clear',...
                'Position', [20 20 50 20],...
                'Callback', 'cla');

            sld = uicontrol('Style', 'slider',...
                'Min',1,'Max',50,'Value',41,...
                'Position', [400 20 120 20],...
                'Callback', @surfzlim); 
        end
        function createButton(label, position, callback)
            
        end
    end
end