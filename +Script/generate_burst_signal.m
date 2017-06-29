%% Init

close all
clear all
clc


%% Parameters

SamplingRate = 44100; % Hz

Length = 10; % milliseconds

t = (0:1:(Length/1000*SamplingRate))/SamplingRate  ;

phase = 0; % radian

Frequency = 440; % Hz

signal = sin( 2*pi*Frequency*t + phase );
% window = hann(length(t))';
window = hamming(length(t))';
% window = ones(1,length(t));

% y = conv(signal,window);
y = signal.*window;

%% Plot

figure

subplot(3,1,1)
plot(signal)
legend('sin')

subplot(3,1,2)
plot(window)
legend('window')

subplot(3,1,3)
plot(y)
legend('burst')

drawnow

%% Play

% playAudioPTB(signal,SamplingRate)

nrchannels = 2;
repetitions = 1;
lowlatency_mode = 1;

InitializePsychSound(1);

PsychPortAudio('Close');

pahandle = PsychPortAudio('Open', [], 1, lowlatency_mode, SamplingRate, nrchannels);

PsychPortAudio('FillBuffer', pahandle, [y;y]);

PsychPortAudio('Start', pahandle, repetitions, 0, 1);
    
WaitSecs(0.400);
    

%% Save .wav

name = sprintf('AudioBurst_%dms.wav',Length);
psychwavwrite(y,SamplingRate,24,name);
