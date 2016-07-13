function StartRecording( EyelinkFile )
%STARTRECORDINGEYELINK Start recording the Eyelink after making some
%checks.
% Syntax : StartRecording( EyelinkFile )

try
    
    % Check EyelinkFile
    if ~ischar(EyelinkFile) || length(EyelinkFile) > 8
        error('EyelinkFile must be string : 8 characters maximum')
    end
    
    % Check if connected (assume the Eyelink is calibrated)
    Eyelink.IsConnected;
    
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
    
catch err
    
    sca
    rethrow(err)
    
end

end
