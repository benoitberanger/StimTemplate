opp_path = which('OpenParPort.m');

if isempty(opp_path)
    
    disp('Parallel port library NOT DETECTED')
    handles.ParPort = 'Off';
    set(hObject,'Value',0);
    
else
    
    switch get(hObject,'Value');
        
        case 0
            disp('Parallel port library OFF')
            handles.ParPort = 'Off';
            set(hObject,'Value',0);
            
        case 1
            disp('Parallel port library ON')
            handles.ParPort = 'On';
            set(hObject,'Value',1);
    end
    
end

guidata(hObject, handles);
