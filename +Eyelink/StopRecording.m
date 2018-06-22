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
        ffprintf('Eyelink stopped recording \n')
        
        if nargin < 1
            EyelinkFile = '...';
        end
        
        % Close file
        status = Eyelink('CloseFile');
        if status ~= 0
            error('CloseFile error, status : %d ',status);
        else
            ffprintf(['Eyelink closed file : ' EyelinkFile '\n' ])
        end
        
        if nargin > 1
            
            % Receive file
            ffprintf('Eyelink file transfer IN PROGRESS \n')
            ffprintf('It might take a few seconds... \n')
            status = Eyelink('ReceiveFile', EyelinkFile, pathToSave, 1);
            if status > 0
                ffprintf('Eyelink file transfer DONE \n')
                ffprintf([ EyelinkFile ' size is ' num2str(status) '\n' ])
            elseif status == 0
                ffprintf('File transfer cancelled \n')
            elseif status < 0
                error('ReceiveFile error, status : %d ',status);
            end
            
        end
        
    elseif err == -1 % -1 means not recording
        
        ffprintf('Eyelink not recording \n')
        
    else
        
        warning('Eyelink:CheckRecording','Eyelink(''CheckRecording'') error : %d',err)
        
    end
    
else % IsConnected
    
    warning('Eyelink:StopRecording','Eyelink not connected')
    
end

end % function
