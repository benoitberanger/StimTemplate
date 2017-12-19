function AddStartTime( self, starttime_name , starttime )
% self.AddStartTime( StartTime_name = str , StartTime = double )
%
% Add special event { StartTime_name starttime }

if ~ischar( starttime_name )
    error( 'StartTime_name must be string' )
end

if ~isnumeric( starttime )
    error( 'StartTime must be numeric' )
end

self.IncreaseEventCount;
self.Data( self.EventCount , 1:3 ) = { starttime_name starttime 0 };
% ex : Add T_start = 0 on the next line (usually first line)

end % function
