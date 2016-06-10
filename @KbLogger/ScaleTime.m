function ScaleTime( obj , StartTime )
% obj.ScaleTime()
%
% Scale the time origin to the first entry in obj.Data

if nargin < 2
    
    
else
    
    % --- StartTime ----
    if ~( isnumeric(StartTime) && StartTime > 0 )
        error('StartTime must be positive')
    end
    
    % Add StartTime at the top of obj.Data
    obj.Data = [ ...
        { obj.Header{1} StartTime       1 NaN } ; ...
        { obj.Header{1} StartTime+0.001 0 NaN } ; ...
        obj.Data...
        ];
    obj.IncreaseEventCount;
    obj.IncreaseEventCount;
    
end

% Apply upper class method
ScaleTime@EventRecorder(obj);

end
