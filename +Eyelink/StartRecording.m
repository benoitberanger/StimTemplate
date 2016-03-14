function StartRecording( DataStruct )
%STARTRECORDINGEYELINK Check if Eyelink is available, then start recording.

try
    
    % Eyelink mode 'On' ?
    switch DataStruct.EyelinkMode
        
        case 'On'
            
            % Eyelink toolbox avalable ?
            if DataStruct.EyelinkToolboxAvailable
                
                % Acquisition ?
                switch DataStruct.OperationMode
                    
                    case 'Acquisition'
                        
                        % Check if connected (assume the Eyelink is calibrated)
                        status = Eyelink('IsConnected');
                        switch status
                            case 1
                                disp('Eyelink connected')
                            case -1
                                disp('Eyelink dummy-connected')
                            case 2
                                disp('Eyelink broadcast-connected')
                            case 0
                                error('Eyelink is not connected')
                        end
                        
                        % Check EyelinkFile
                        if ~ishcar(DataStruct.EyelinkFile) || length(DataStruct.EyelinkFile) > 8
                            error('DataStruct.EyelinkFile must be string : 8 characters maximum')
                        end
                        
                        % Open file
                        status = Eyelink('OpenFile',EyelinkFile);
                        if status ~= 0
                            error('OpenFile error, status : %d ',status)
                        end
                        
                        % Start recording
                        startrecording_error = Eyelink('StartRecording');
                        if startrecording_error ~= 0
                            error('StartRecording error, startrecording_error : %d ',startrecording_error)
                        end
                        
                    otherwise
                        
                        error('StartRecordingEyelink:EyelinkModeOnWithoutAcquisition','\n Eyelink mode should be ''Off'' if not in Acquisition mode \n')
                        
                end
                
            end
            
        case 'Off'
            
    end
    
    
catch err
    
    sca
    rethrow(err)
    
    
end

end