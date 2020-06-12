function [threshold, method] = thresholdKeraTraces(histVal, edgeVal, channels)

figure('Units', 'Normalized','Position',[.25 .4 .5 .5]);
hold on;

for j = 1:channels
    ddOpt{j} = num2str(j);
end
method = 1;
channel = 1;
h1 = subplot('Position', [0.05 0.35 0.9 0.45]);
histogram('BinEdges',edgeVal{channel,method},'BinCounts',histVal{channel,method});

btn = uicontrol('Style', 'pushbutton', 'String', 'Set',...
    'Position', [0.8 0.05 0.1 0.1],...
    'UserData', 1,'Callback', @setCallback);

channelDropDown = uicontrol('Style', 'popupmenu', 'String', ddOpt,  ...
    'Position', [0.15 0.05 0.09 0.06], 'Callback', @channelEdit);

channelDropDown = uicontrol('Style', 'popupmenu', 'String', ddOpt,  ...
    'Position', [0.15 0.05 0.09 0.06], 'Callback', @channelEdit);

thresh1 = uicontrol('Style', 'edit', 'String', "0.5",  ...
    'Position', [0.35 0.05 0.1 0.06]);

thresh2 = uicontrol('Style', 'edit', 'String', "0.5",  ...
    'Position', [0.50 0.05 0.1 0.06],'enable', 'off');


    function channelEdit(hObject,~)
        channel = str2double(get(hObject,'Value'));
        histogram('BinEdges',edgeVal{channel,method},'BinCounts',histVal{channel,method});
    end




    function setCallback(~,~)
        close(gcf)
        threshold = 1;
        method = 1;
    end
end