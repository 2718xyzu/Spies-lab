classdef keraGUI
    %This function defines a variety of methods which may be used in a KERA
    %window, but does not itself "set up" the window; that is done by the
    %lines of code in "openKERA" and various lines in the methods of Kera.m
    
    
    properties
        guiWindow
        error = 0
        elements = containers.Map()
    end
    
    methods (Static)

    end
    
    
    methods
        function gui = keraGUI()
            gui.guiWindow = figure('Visible', 'on');
            gui.guiWindow.MenuBar = 'none';
            gui.guiWindow.ToolBar = 'none';
            gui.guiWindow.Units = 'normalized';
            gui.guiWindow.CloseRequestFcn = @closeGuiSaveRequest;
        end
        
        function createButton(gui, label, position, callback)
            gui.elements(label) = uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', label, 'Position', position, 'Callback', callback);
        end

        function createDropdown(gui, name, labels, position, callback)
            gui.elements(name) = uicontrol('Style', 'popup', 'Units', 'normalized', 'String', labels, 'Position', position, 'Callback', callback);
        end

        function slider = createSlider(gui, minimum, maximum, position, callback)
            slider = uicontrol('Style', 'slider', 'Units', 'normalized', 'Min', minimum, 'Max', maximum, 'Value', round((minimum+maximum)/2), 'Callback', callback);
        end

        function createText(gui, label, position, varargin)
            p = inputParser;
            addRequired(p, 'label');
            addRequired(p, 'position');
            addOptional(p, 'color', '');
            parse(p, label, position, varargin(:));
            gui.elements(p.Results.label) = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', p.Results.position, 'String', p.Results.label);
        end

        function createTextbox(gui, label, position)
            gui.elements(label) = uicontrol('Style', 'edit', 'Units', 'normalized', 'Position', position, 'String', label);
        end

        function createPrimaryMenu(gui, label, varargin)
            p = inputParser;
            addRequired(p, 'label');
            addOptional(p, 'callback', '');
            parse(p, label, varargin(:));
            gui.elements(label) = uimenu(gui.guiWindow, 'Text', label, 'Callback', p.Results.callback);
        end

        function createSecondaryMenu(gui, primaryLabel, label, varargin)
            p = inputParser;
            addRequired(p, 'primaryLabel');
            addRequired(p, 'label');
            addOptional(p, 'callback', '');
            parse(p,primaryLabel, label, varargin(:));
            gui.elements(p.Results.label) = uimenu(gui.elements(p.Results.primaryLabel), 'Text', p.Results.label, 'Callback', p.Results.callback);
        end

        function out = inputdlg(gui, title, prompt, defaultValues)
            dims = [1 10];
            out = inputdlg(prompt, title, dims, defaultValues);
        end

        function toggle(gui, label)
            if strcmp(gui.elements(label).Enable,'on')
                set(gui.elements(label), 'Enable', 'off');
            else
                set(gui.elements(label), 'Enable', 'on');
            end
        end

        function enable(gui, label)
            set(gui.elements(label), 'Enable', 'on');
        end

        function disable(gui, label)
            set(gui.elements(label), 'Enable', 'off');
        end

        function remove(gui, label)
            set(gui.elements(label), 'Visible', 'off');
            remove(gui.elements, label);
        end

        function errorMessage(gui, errorMessage)
            gui.error = 1;
            gui.createText(errorMessage, [0 0 1 0.1]);
            errorTimer = timer;
            errorTimer.StartDelay = 10;
            errorTimer.TimerFcn = @(~,~) gui.remove(errorMessage);
            start(errorTimer);
        end

        function resetError(gui)
            gui.error = 0;
        end
    end
end
