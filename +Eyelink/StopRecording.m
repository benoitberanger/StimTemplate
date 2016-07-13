function StopRecording( EyelinkFile , pathToSave )
%STOPRECORDING Check if Eyelink is recording, then stop recording.
% Syntax : StopRecording( EyelinkFile , pathToSave )

% Connection initilized ?
if Eyelink('IsConnected')
    
    % Recording ?
    err = Eyelink('CheckRecording');
    if err == 0 % 0 means recording
        
        % Stop recording
        Eyelink('Stoprecording')
        disp('Eyelink stopped recording')
        
        % Close file
        status = Eyelink('CloseFile');
        if status ~= 0
            error('CloseFile error, status : %d ',status);
        else
            disp(['Eyelink closed file : ' EyelinkFile])
        end
        
        % Receive file
        disp('Eyelink file transfer IN PROGRESS')
        disp('It might take a few seconds...')
        status = Eyelink('ReceiveFile', EyelinkFile, pathToSave, 1);
        if status > 0
            disp('Eyelink file transfer DONE')
            disp([ EyelinkFile ' size is ' num2str(status) ])
        elseif status == 0
            disp('File transfer cancelled')
        elseif status < 0
            error('ReceiveFile error, status : %d ',status);
        end
        
    elseif err == -1 % -1 means not recording
        
        disp('Eyelink not recording')
        
    else
        
        warning('Eyelink:CheckRecording','Eyelink(''CheckRecording'') error : %d',err)
        
    end
    
else % IsConnected
    
    warning('Eyelink:StopRecording','Eyelink not connected')
    
end

end % function
