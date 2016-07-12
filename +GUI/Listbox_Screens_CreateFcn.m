function Listbox_Screens_CreateFcn( hObject , eventdata )

AvailableDisplays = Screen('Screens');

% Put screen 1 on the top : CENIR human MRI configuration
if length(AvailableDisplays) > 1
    AvailableDisplays = circshift(AvailableDisplays',length(AvailableDisplays)-1);
    ListOfScreens = num2str(AvailableDisplays);
else
    ListOfScreens = num2str(AvailableDisplays');
end

set(hObject,'String',ListOfScreens)

end % function
