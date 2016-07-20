function ScaleTime( obj )
% obj.ScaleTime()
%
% Scale the time origin to the first entry in obj.Data

% Onsets of events
oldOnsets = cell2mat( obj.Data(:,2) );

% Shift all onsets by the minimum
newOnsets = oldOnsets - min(oldOnsets);

% Write scaled time
if ~isempty( newOnsets )
    obj.Data( : , 4 ) = num2cell( newOnsets );
else
    warning( 'KbLogger:ScaleTime' , 'No data in %s.Data' , inputname(1) )
end

end
