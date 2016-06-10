function ScaleTime( obj )
% obj.ScaleTime()
%
% Scale the time origin to the first entry in obj.Data

% Fetch caller object
[~, name, ~] = fileparts(obj.Description);

% Onsets of events
time = cell2mat( obj.Data( : , 2 ) );

% Depending on the object calling the method, the display changes.
switch name
    
    case 'EventRecorder'
        column_to_write_scaled_onsets = 2;
        
    case 'KbLogger'
        column_to_write_scaled_onsets = 4;
        
    case 'EventPlanning'
        column_to_write_scaled_onsets = 2;
        
    otherwise
        error('Unknown object caller')
        
end

% Write scaled time
if ~isempty( time )
    obj.Data( : , column_to_write_scaled_onsets ) = num2cell( time - time(1) );
else
    warning( 'EventRecorder:ScaleTime' , 'No data in %s.Data (%s)' , inputname(1) , name )
end

end
