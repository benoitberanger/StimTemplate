function [ Sequence ] = PsedoRand2Conditions( C0 , C1 , nodisplay )
%PSEDORAND2CONDITIONS Generates a sequences of 0 and 1 where there is  no
%two 1 in a row
%
%   C0 is the number of the 0 in the sequence
%   C1 is the number of the 1 in the sequence
%   nodisplay is 0 or 1 (flag)
%
%   WARNING : the method is adapted for C0|C1 not too big (<500|250) and
%   for C1/C0~0.5.

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2016

if nargin < 3
    nodisplay = 0;
end

maxiteration = 10000;

L = C0 + C1; % length of the sequence

StreamRand = 0; % initialization of stram
exit_randomization = 0; % flag
iteration = 0; % counter

while ~exit_randomization
    
    StreamRand(end+1) = round(rand); %#ok<AGROW> add a random value to the stream
    if StreamRand(end-1) == 1 && StreamRand(end) == 1 % two 1 in a row
        StreamRand(end) = 0; % change the new 1 into 0
    end
    
    if length(StreamRand) > L % enouth stream
        
        iteration = iteration + 1;
        
        if ~nodisplay
            fprintf('iteration = %d \n',iteration)
        end
        
        for idx = 1:(length(StreamRand)-L)
            
            window = StreamRand(idx:idx+L-1); % sliding window inside the stream
            res = sum(window); % sum of 1
            
            if res == C1 % "le compte est bon"
                exit_randomization = 1;
                break
            end
            
        end
        
    end
    
    if iteration == maxiteration % security
        error('maxiteration rached')
    end
    
end

Sequence = window;

end
