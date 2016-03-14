function STOP( DataStruct )

% Eyelink mode 'On' ?
if strcmp(DataStruct.EyelinkMode,'On')
    
    % Eyelink toolbox avalable ?
    if DataStruct.EyelinkToolboxAvailable
        
        % Connection initilized ?
        if Eyelink('IsConnected')
            
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
            
        end
        
    end
    
end

end
