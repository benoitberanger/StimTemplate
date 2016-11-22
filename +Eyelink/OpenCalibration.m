function OpenCalibration

% Open PTB window
wPtr = Screen('OpenWindow',1); % 1 : stimulation screen @Cenir

% Do calibration
Eyelink.Calibration(wPtr);

% Close PTB window
sca

end
