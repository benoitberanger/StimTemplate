function OpenCalibration(screenNumber)

if nargin < 1
    screenNumber = 1; % 1 : stimulation screen @ Cenir MRI lab
end

% PTB opening screen will be empty = black screen
Screen('Preference', 'VisualDebugLevel', 1);

% Open PTB window
wPtr = Screen('OpenWindow',screenNumber);

% Do calibration
Eyelink.Calibration(wPtr);

% Close PTB window
sca

end % function
