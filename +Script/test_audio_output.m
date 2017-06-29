%% Init

clear all
clc

%% Load wave file

filename = 'AudioBurst_10ms.wav';
[y, Fs] = psychwavread(filename);

%% Prepare audio & other config

% playAudioPTB(signal,SamplingRate)

nrchannels = 2;
repetitions = 1;
lowlatency_mode = 1;

InitializePsychSound(1);

PsychPortAudio('Close');

pahandle = PsychPortAudio('Open', [], 1, lowlatency_mode, Fs, nrchannels);

win = IsWin;
glnx = IsLinux;

if win
    OpenParPort;
end


%% Play

top = GetSecs;
while ~KbCheck
    
    PsychPortAudio('FillBuffer', pahandle, [y y]' );
    top = PsychPortAudio('Start', pahandle, repetitions, top+0.400, 1);
    
    if win
        WriteParPort(255);
        WaitSecs(0.001);
        WriteParPort(0);
    elseif glnx
        parport_dev(255);
        WaitSecs(0.001);
        parport_dev(0);
    end 
    
end

PsychPortAudio('Close');

%% Plot 

% plot(y)
