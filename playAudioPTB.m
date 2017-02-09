function playAudioPTB( wavedata, freq )

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2015

if nargin < 2
    freq = 44100;
end

if nargin < 1
    error('Not enough input arguments')
end

nrchannels = 1;
repetitions = 1;

InitializePsychSound(1);

pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);

PsychPortAudio('FillBuffer', pahandle, wavedata);

PsychPortAudio('Start', pahandle, repetitions, 0, 1);

PsychPortAudio('Stop', pahandle, 1, 1);

PsychPortAudio('Close',pahandle);

end
