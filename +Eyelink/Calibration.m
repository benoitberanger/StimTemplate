function [ TaskData ] = Calibration( DataStruct )

try
    %% Assign wich window the eyelink will use
    
    TaskData.el = EyelinkInitDefaults(DataStruct.PTB.Window);
    
    
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
            error('EyelinkCalibrationNPI:EyelinkInit','EyelinkInit error')
            
    end
    if dummy
        disp('Dummy mode')
    end
    
    % Error and warnings
    Eyelink('Verbosity' , 4);
    
    
    %% Set parameters
    
    % Used for test : the mouse emulate the gaze if 'YES'
    Eyelink('Command','aux_mouse_simulation = NO');
    
    Eyelink('Command','elcl_select_configuration MLRR');
    Eyelink('Command','active_eye = RIGHT');
    Eyelink('Command','binocular_enabled = NO');
    Eyelink('Command','current_camera = RIGHT');
    Eyelink('Command','sample_rate = 1000');
    Eyelink('Command','lock_active_eye = YES');
    Eyelink('Command','lock_eye_after_calibration = YES');
    Eyelink('Command','calibration_type = HV9');
    Eyelink('Command','randomize_calibration_order = YES');
    Eyelink('Command','randomize_validation_order = YES');
    Eyelink('Command','enable_automatic_calibration = YES');
    Eyelink('Command','automatic_calibration_pacing = 1000');
    Eyelink('Command','pupil_size_diameter = DIAMETER');
    Eyelink('Command','cal_repeat_first_target = YES');
    Eyelink('Command','val_repeat_first_target = YES');
    Eyelink('Command','select_parser_configuration 0');
    Eyelink('Command','heuristic_filter 1 2');
    Eyelink('Command','aux_mouse_simulation = NO');
    Eyelink('Command','corneal_mode = YES');
    Eyelink('Command','use_high_speed = YES');
    Eyelink('Command','file_sample_data = LEFT,RIGHT,,GAZE,GAZERES,AREA,STATUS,INPUT,BUTTON,');
    Eyelink('Command','recording_parse_type = GAZE');
    Eyelink('Command','analog_out_data_type = GAZE');
    
    Eyelink('Command','autothreshold_click = YES');
    Eyelink('Command','autothreshold_repeat = YES');
    Eyelink('Command','enable_search_limits = YES');
    Eyelink('Command','track_search_limits = NO');
    
    
    %% Calivration & validation
    
    EyelinkDoTrackerSetup(TaskData.el);
    
    
    %% End of 'task'
    
    TaskData.ER.Data = {};
    
    TaskData.IsEyelinkRreadyToRecord = 1;
    
catch err
    
    WaitSecs(0.200);
    sca
    WaitSecs(0.200);
    rethrow(err)
    
end

end