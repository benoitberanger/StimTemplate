function playAudio( signal, freq )

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2015

if nargin < 2
    freq = 44100;
end
    
if nargin < 1
    error('Not enough input arguments')
end

player = audioplayer(signal,freq);
playblocking(player);
play(player);
