function AddStartTime( obj, starttime_name , starttime )
% obj.AddStartTime( StartTime_name = str , StartTime = double )
%
% Add special event { StartTime_name starttime }

if ~ischar( starttime_name )
    error( 'StartTime_name must be string' )
end

if ~isnumeric( starttime )
    error( 'StartTime must be numeric' )
end

obj.IncreaseEventCount;
obj.Data( obj.EventCount , 1:2 ) = { starttime_name starttime };
% ex : Add T_start = 0 on the next line (usually first line)

end
