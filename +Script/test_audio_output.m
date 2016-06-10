%% Init

clear all
clc

%% Load wave file

filename = 'AudioBurst_10ms.wav';
[y, Fs] = wavread(filename);

%% Play

% playAudioPTB(signal,SamplingRate)

nrchannels = 2;
repetitions = 1;
lowlatency_mode = 1;

InitializePsychSound(1);

PsychPortAudio('Close');

pahandle = PsychPortAudio('Open', [], 1, lowlatency_mode, Fs, nrchannels);

PsychPortAudio('FillBuffer', pahandle, [y y]' );

while ~KbCheck
    
    PsychPortAudio('Start', pahandle, repetitions, 0, 1);
    
    WaitSecs(0.400);
    
end

PsychPortAudio('Close');

%% Plot 

% plot(y)
