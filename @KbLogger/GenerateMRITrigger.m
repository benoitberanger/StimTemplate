function GenerateMRITrigger( obj , tr, volumes )
% obj.GenerateMRITrigger( TR = positive number , Volumes = positive integer )
%
% Generate MRI trigger according to he given number of Volumes
% and the TR.

% ================ Check input argument =======================

if nargin > 0
    
    % --- tr ----
    if ~( isnumeric(tr) && tr > 0 )
        error('TR must be positive')
    end
    
    % --- volumes ----
    if ~( isnumeric(volumes) && volumes > 0 && volumes == round(volumes) )
        error('Volumes must be a positive integer')
    end
    
else
    
    % narginchk(3,3)
    % narginchk introduced in R2011b
    if nargin ~=3
        error('%s uses 3 input argument(s)','GenerateMRITrigger')
    end
    
end

% ======================= Callback ============================

% MRI_trigger_tag = '5%'; % fORP in USB
MRI_trigger_tag = obj.Header{1};
pulse_duration = 0.020; % seconds

% Check if TR is compatible with the pulse duration
if tr < pulse_duration
    error('pulse_duration is set to %.3f, but TR must be such as TR > pulse_duration',pulse_duration)
end

% Fill Data whith MRI trigger events

for v = 1 : volumes
    
    obj.AddEvent({ MRI_trigger_tag (v-1)*tr                1 (v-1)*tr                 })
    obj.AddEvent({ MRI_trigger_tag (v-1)*tr+pulse_duration 0 (v-1)*tr+pulse_duration  })
    
end

end
