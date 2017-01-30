%% Parallel port : send message from the stim computer

% Beginig of script
OpenParPort;

% After each onset
message = 255; % integer from 0 to 255
WriteParPort(message)
WaitSecs(0.003) % in seconds; use minium samplingRate x2, usually x3
WriteParPort(0)

% End of script
CloseParPort; % not required

%% Higher level wrappers

% Open equivalent of Track.exe but in PTB
Eyelink.OpenCalibration

% Lost connection : reset
Eyelink.ForceShutDown


%% Low level

% Connect
Eyelink.Initialize

% Need parameters ?
Eyelink.LoadParameters

% is connected ?
Eyelink.IsConnected


%% In you experiment script :

Eyelink.StartRecording('nameOfFile'), % open file, start recording

Eyelink.STOP % In case of emergency : Stop recording, close file

Eyelink.StopRecording('nameOfFile','pathToDirectoryToDownload') % stop recording, close file, download the file into the directory

movefile('myDir/nameOfFile.edf','myDir/NewNameOfTheFile.edf') % rename / move file

