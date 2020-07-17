function closeGuiSaveRequest(~, ~, ~)
   selection = questdlg('Close KERA?  This will delete unsaved progress', ...
              'Warning', ...
              'Yes','No','Yes');
    switch selection
        case 'Yes'
            delete(gcf)
        case 'No'
            return
    end
end