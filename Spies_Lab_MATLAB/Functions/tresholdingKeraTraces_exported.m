classdef tresholdingKeraTraces_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        LeftPanel                      matlab.ui.container.Panel
        EditchannelDropDownLabel       matlab.ui.control.Label
        EditchannelDropDown            matlab.ui.control.DropDown
        SnapallregionswithcenterLabel  matlab.ui.control.Label
        DropDown                       matlab.ui.control.DropDown
        EditField                      matlab.ui.control.NumericEditField
        EditField_2                    matlab.ui.control.NumericEditField
        andLabel                       matlab.ui.control.Label
        TostateLabel                   matlab.ui.control.Label
        EditField_3                    matlab.ui.control.NumericEditField
        SetButton                      matlab.ui.control.Button
        ByDropDownLabel                matlab.ui.control.Label
        ByDropDown                     matlab.ui.control.DropDown
        valueLabel                     matlab.ui.control.Label
        RightPanel                     matlab.ui.container.Panel
        UIAxes                         matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        histVal % Input argument containing the heights of the histogram
        edgeVal % Input argument containing the edges of the histogram bins
        channels %Input argument containing the number of channels
        channel % The channel currently selected to edit
        method  % The method currently selected: 1 to compare the absolute
                % value of the traces, 2 to normalize each one and use the 
                % relative values within each trace
        threshold %the threshold value(s) eventually chosen
        boundDirection % 1 if "above", 2 if "below", 3 if "between"
        stateSet %Integer, state which the 
    end
    
    methods (Access = private)
        function updateHistogram(app)
            histogram(app.UIAxes,'BinEdges',app.edgeVal{app.channel,app.method},'BinCounts',app.histVal{app.channel,app.method});
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, histVal, edgeVal, channels)
            app.histVal = histVal;
            app.edgeVal = edgeVal;
            app.channels = channels;
            ddOpt = cell([1 channels]);
            for j = 1:channels
                ddOpt{j} = num2str(j);
            end
            app.EditchannelDropDown.Items = ddOpt;
            app.EditchannelDropDown.ItemsData = 1:channels;
            app.DropDown.ItemsData = [ 1 2 3 ];
            app.ByDropDown.ItemsData = [ 1 2 ];
            
            app.EditField_2.Enable = 'off';
            app.andLabel.Text = '';
            app.method = app.ByDropDown.Value;
            app.channel = app.EditchannelDropDown.Value;
            updateHistogram(app);
        end

        % Value changed function: EditchannelDropDown
        function EditchannelDropDownValueChanged(app, event)
            value = app.EditchannelDropDown.Value;
            app.channel = value;
            updateHistogram(app);
        end

        % Value changed function: DropDown
        function DropDownValueChanged(app, event)
            value = app.DropDown.Value;
            if value == 3
                app.EditField_2.Enable = 'on';
                app.andLabel.Text = 'and';
            else
                app.EditField_2.Enable = 'off';
                app.andLabel.Text = '';
            end
            app.boundDirection = value;
        end

        % Value changed function: EditField
        function EditFieldValueChanged(app, event)
            value = app.EditField.Value;
            app.threshold(1) = value;
        end

        % Value changed function: EditField_2
        function EditField_2ValueChanged(app, event)
            value = app.EditField_2.Value;
            app.threshold(2) = value;
        end

        % Value changed function: EditField_3
        function EditField_3ValueChanged(app, event)
            value = app.EditField_3.Value;
            app.stateSet = value;
        end

        % Button pushed function: SetButton
        function SetButtonPushed(app, event)
            close(gcf);
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)

            
            
        end

        % Value changed function: ByDropDown
        function ByDropDownValueChanged(app, event)
            value = app.ByDropDown.Value;
            app.method = value;
            updateHistogram(app);
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {480, 480};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {220, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {220, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create EditchannelDropDownLabel
            app.EditchannelDropDownLabel = uilabel(app.LeftPanel);
            app.EditchannelDropDownLabel.HorizontalAlignment = 'right';
            app.EditchannelDropDownLabel.Position = [14 405 72 22];
            app.EditchannelDropDownLabel.Text = 'Edit channel';

            % Create EditchannelDropDown
            app.EditchannelDropDown = uidropdown(app.LeftPanel);
            app.EditchannelDropDown.ValueChangedFcn = createCallbackFcn(app, @EditchannelDropDownValueChanged, true);
            app.EditchannelDropDown.Position = [101 405 100 22];

            % Create SnapallregionswithcenterLabel
            app.SnapallregionswithcenterLabel = uilabel(app.LeftPanel);
            app.SnapallregionswithcenterLabel.Position = [14 367 154 22];
            app.SnapallregionswithcenterLabel.Text = 'Snap all regions with center';

            % Create DropDown
            app.DropDown = uidropdown(app.LeftPanel);
            app.DropDown.Items = {'Above', 'Below', 'Between'};
            app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
            app.DropDown.Position = [14 334 100 22];
            app.DropDown.Value = 'Above';

            % Create EditField
            app.EditField = uieditfield(app.LeftPanel, 'numeric');
            app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.EditField.Position = [14 295 100 22];

            % Create EditField_2
            app.EditField_2 = uieditfield(app.LeftPanel, 'numeric');
            app.EditField_2.ValueChangedFcn = createCallbackFcn(app, @EditField_2ValueChanged, true);
            app.EditField_2.Position = [14 220 100 22];
            app.EditField_2.Value = 1;

            % Create andLabel
            app.andLabel = uilabel(app.LeftPanel);
            app.andLabel.Position = [14 262 26 22];
            app.andLabel.Text = 'and';

            % Create TostateLabel
            app.TostateLabel = uilabel(app.LeftPanel);
            app.TostateLabel.Position = [14 137 48 22];
            app.TostateLabel.Text = 'To state';

            % Create EditField_3
            app.EditField_3 = uieditfield(app.LeftPanel, 'numeric');
            app.EditField_3.ValueChangedFcn = createCallbackFcn(app, @EditField_3ValueChanged, true);
            app.EditField_3.Position = [14 98 100 22];

            % Create SetButton
            app.SetButton = uibutton(app.LeftPanel, 'push');
            app.SetButton.ButtonPushedFcn = createCallbackFcn(app, @SetButtonPushed, true);
            app.SetButton.Position = [14 51 100 22];
            app.SetButton.Text = 'Set';

            % Create ByDropDownLabel
            app.ByDropDownLabel = uilabel(app.LeftPanel);
            app.ByDropDownLabel.HorizontalAlignment = 'right';
            app.ByDropDownLabel.Position = [14 176 25 22];
            app.ByDropDownLabel.Text = 'By';

            % Create ByDropDown
            app.ByDropDown = uidropdown(app.LeftPanel);
            app.ByDropDown.Items = {'Absolute', 'Relative'};
            app.ByDropDown.ValueChangedFcn = createCallbackFcn(app, @ByDropDownValueChanged, true);
            app.ByDropDown.Position = [54 176 100 22];
            app.ByDropDown.Value = 'Absolute';

            % Create valueLabel
            app.valueLabel = uilabel(app.LeftPanel);
            app.valueLabel.Position = [167 176 34 22];
            app.valueLabel.Text = 'value';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Set distribution')
            xlabel(app.UIAxes, 'Bin center')
            ylabel(app.UIAxes, 'Counts')
            app.UIAxes.Position = [23 185 370 242];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = tresholdingKeraTraces_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end