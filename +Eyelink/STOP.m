function STOP
%STOP Stops recording the Eyelink but don't retrieve the file
% Syntax : STOP()

% Connection initilized ?
if Eyelink('IsConnected') ~= 0
    
    % Recording ?
    err = Eyelink('CheckRecording');
    if err == 0 % 0 means recording
        
        % Stop recording
        Eyelink('Stoprecording')
        
        % Close file
        status = Eyelink('CloseFile');
        if status ~= 0
            error('CloseFile error, status : %d ',status);
        end
        
    elseif err == -1 % -1 means not recording
        
        disp('Eyelink not recording')
        
    else
        
        warning('Eyelink:CheckRecording','Eyelink(''CheckRecording'') error : %d',err)
        
    end
    
else % IsConnected
    
    warning('Eyelink:STOP','Eyelink not connected')
    
end

end % function
