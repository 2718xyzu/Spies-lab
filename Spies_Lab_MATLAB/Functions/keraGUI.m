classdef keraGUI < handle
    properties
        guiWindow
        elements = containers.Map()
    end
    methods
        function gui = keraGUI()
            gui.guiWindow = figure('Visible', 'on');
            gui.guiWindow.MenuBar = 'none';
            gui.guiWindow.ToolBar = 'none';
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

        function createText(gui, label, position)
            uicontrol('Style', 'text', 'Units', 'normalized', 'Position', position, 'String', label);
        end

        function createTextbox(gui, label, position)
            gui.elements(label) = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', position, 'String', label);
        end

        function createPrimaryMenu(gui, label)
            gui.elements(label) = uimenu(gui.guiWindow, 'Text', label);
        end

        function createSeconaryMenu(gui, primaryLabel, label, callback)
            gui.elements(label) = uimenu(gui.elements(primaryLabel), 'Text', label, 'Callback', callback);
        end
    end
end
