CurrentRunNumber_str = get(handles.edit_RunNumber,'String');
CurrentRunNumber = str2double(CurrentRunNumber_str) - 1;

set(handles.edit_RunNumber,'String', num2str( CurrentRunNumber ) )
