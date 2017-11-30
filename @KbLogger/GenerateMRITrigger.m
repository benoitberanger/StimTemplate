function GenerateMRITrigger( self , tr, volumes, starttime )
% self.GenerateMRITrigger( TR = positive number , Volumes = positive integer, StartTime = onset of the first volume )
%
% Generate MRI trigger according to he given number of Volumes
% and the TR.

% ================ Check input argument =======================

% narginchk(3,3)
% narginchk introduced in R2011b
if nargin > 4 || nargin < 3
    error('%s uses 3 or 4 input argument(s)','GenerateMRITrigger')
end

if nargin == 3
    starttime = 0;
end

% --- tr ----
if ~( isnumeric(tr) && tr > 0 )
    error('TR must be positive')
end

% --- volumes ----
if ~( isnumeric(volumes) && volumes > 0 && volumes == round(volumes) )
    error('Volumes must be a positive integer')
end
    
% --- starttime ----
if ~( isnumeric(starttime) && starttime >= 0 )
    error('StartTime must be positive or null')
end


% ======================= Callback ============================

% MRI_trigger_tag = '5%'; % fORP in USB
MRI_trigger_tag = self.Header{1};
pulse_duration = 0.020; % seconds

% Check if TR is compatible with the pulse duration
if tr < pulse_duration
    error('pulse_duration is set to %.3f, but TR must be such as TR > pulse_duration',pulse_duration)
end

% Fill Data whith MRI trigger events

for v = 1 : volumes
    
    self.AddEvent({ MRI_trigger_tag starttime+(v-1)*tr                1 starttime+(v-1)*tr                 })
    self.AddEvent({ MRI_trigger_tag starttime+(v-1)*tr+pulse_duration 0 starttime+(v-1)*tr+pulse_duration  })
    
end

end % function
