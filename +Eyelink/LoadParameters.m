function LoadParameters

% Check connection
Eyelink.IsConnected

% Error and warnings
Eyelink('Verbosity' , 4);

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

fprintf('\n')
fprintf('Eyelink parameters loaded \n')

end
