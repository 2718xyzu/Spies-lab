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
            gui.elements(label) = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', position, 'String', label);
        end

        function createTextbox(gui, label, position)
            gui.elements(label) = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', position, 'String', label);
        end

        function createPrimaryMenu(gui, label)
            gui.elements(label) = uimenu(gui.guiWindow, 'Text', label);
        end

        function createSeconaryMenu(gui, primaryLabel, label, varargin)
            p = inputParser;
            addRequired(p, 'primaryLabel');
            addRequired(p, 'label');
            addOptional(p, 'callback', '');
            parse(p,primaryLabel, label, varargin(:));
            gui.elements(label) = uimenu(gui.elements(p.Results.primaryLabel), 'Text', p.Results.label, 'Callback', p.Results.callback);
        end

        function toggle(gui, label)
            if strcmp(gui.elements(label).Enable,'on')
                set(gui.elements(label), 'Enable', 'off');
            else
                set(gui.elements(label), 'Enable', 'on');
            end
        end

        function remove(gui, label)
            set(gui.elements(label), 'Visible', 'off');
            remove(gui.elements, label);
        end

        function errorMessage(gui, errorMessage)
            gui.createText(errorMessage, [0 0 1 0.1]);
            errorTimer = timer;
            errorTimer.StartDelay = 5;
            errorTimer.TimerFcn = @(~,~) gui.remove(errorMessage);
            start(errorTimer);
        end
    end
end
