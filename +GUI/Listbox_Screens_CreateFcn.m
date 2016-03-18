set(hObject,'TooltipString',sprintf('Select the display mode \n PTB : 0 for extended display (over all screens) , 1 for screen 1 , 2 for screen 2 , etc.'))

AvailableDisplays = Screen('Screens');

% Put screen 1 on the top : CENIR human MRI configuration
if length(AvailableDisplays) > 1
    AvailableDisplays = circshift(AvailableDisplays',length(AvailableDisplays)-1);
    ListOfScreens = num2str(AvailableDisplays);
else
    ListOfScreens = num2str(AvailableDisplays');
end

set(hObject,'String',ListOfScreens)
