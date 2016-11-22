function Calibration( wPtr )
%CALIBRATION Start the Eyelink calibration onto the psychtoolbox window
%pointer (wPtr)
% Syntax : Calibration( wPtr )

try
    %% Assign wich window the eyelink will use
    
    el = EyelinkInitDefaults(wPtr);
    
    
    %% Initialize Eyelink connection:
    
    % Parameters
    dummymode = 0; % ??
    enableCallbacks = 1; % Very important to be 1;
    
    % Initialization
    [result dummy] = EyelinkInit(dummymode,enableCallbacks);
    switch result
        case 1
            disp('EyelinkInit successful')
        case 0
            error('EyelinkCalibration:EyelinkInit','EyelinkInit error')
    end
    
    if dummy
        disp('Dummy mode')
    end
    
    % Error and warnings
    Eyelink('Verbosity' , 4);
    
    
    %% Set parameters
    
    Eyelink.LoadParameters
    
    
    %% Calivration & validation
    
    EyelinkDoTrackerSetup(el);
    
    
catch err
    
    sca
    rethrow(err)
    
end

end % function
