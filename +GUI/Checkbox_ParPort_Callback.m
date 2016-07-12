function Checkbox_ParPort_Callback ( hObject , eventdata )

opp_path = which('OpenParPort.m');

if isempty(opp_path)
    
    disp('Parallel port library NOT DETECTED')
    set(hObject,'Value',0);
    
else
    
    switch get(hObject,'Value');
        
        case 0
            disp('Parallel port library OFF')
            set(hObject,'Value',0);
            
        case 1
            disp('Parallel port library ON')
            set(hObject,'Value',1);
    end
    
end


end  % function
