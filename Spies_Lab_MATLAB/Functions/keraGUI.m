classdef keraGUI < handle
    properties
        guiWindow
        elements = {}
    end
    methods
        function gui = keraGUI()
            guiWindow = figure('Visible', 'on');
            guiWindow.MenuBar = 'none';
            guiWindow.ToolBar = 'none';
        end

        function button = createButton(gui, label, position, callback)
            button = uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', label, 'Position', position, 'Callback', callback);
        end

        function dropdown = createDropdown(gui, labels, position)
            dropdown = uicontrol('Style', 'popup', 'Units', 'normalized', 'String', labels, 'Position', position);
        end

        function slider = createSlider(gui, minimum, maximum, position, callback)
            slider = uicontrol('Style', 'slider', 'Units', 'normalized', 'Min', minimum, 'Max', maximum, 'Value', round((minimum+maximum)/2), 'Callback', callback);
        end

        function text_obj = createText(gui, text_to_show, position)
            text_obj = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', position, 'String', text_to_show);
        end

        function textbox = createTextbox(gui, default_text, position)
            textbox = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', position, 'String', default_text);
        end
    end
end
