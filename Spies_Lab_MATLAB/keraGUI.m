classdef keraGUI < handle
    properties
        guiWindow
        elements = {}
    end
    methods
        function gui = keraGUI()
            guiWindow = figure('Visible', 'off');
            guiWindow.MenuBar = 'none';
            guiWindow.ToolBar = 'none';
        end

        function button = createButton(label, position, callback)
            button = uicontrol('Style', 'pushbutton', 'String', label, 'Position', position, 'Callback', callback)
        end

        function dropdown = createDropdown(labels, position, callback)
            dropdown = uicontrol('Style', 'popup', 'String', labels, 'Position', position, 'Callback', callback)
        end

        function slider = createSlider(minimum, maximum, position, callback)
            slider = uicontrol('Style', slider, 'Min', minimum, 'Max', maximum, 'Value', round((minimum+maximum)/2), 'Callback', callback)
        end
    end
end
