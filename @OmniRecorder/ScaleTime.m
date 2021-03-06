function ScaleTime( self, t0 )
% self.ScaleTime()
%
% Scale the time origin to the first entry in self.Data

if nargin < 2
    t0 = [];
end

% Onsets of events
time = cell2mat( self.Data( : , 2 ) );

className = class(self);

% Depending on the object calling the method, the display changes.
switch className
    case 'EventRecorder'
        column_to_write_scaled_onsets = 2;
        value = time(1);
    case 'KbLogger'
        column_to_write_scaled_onsets = 4;
        if ~isempty(t0)
            value = t0;
        else
            value = time(1);
        end
    case 'EventPlanning'
        column_to_write_scaled_onsets = 2;
        value = time(1);
    otherwise
        error('Unknown object caller. Check self.Description')
end

% Write scaled time
if ~isempty( time )
    self.Data( : , column_to_write_scaled_onsets ) = num2cell( time - value );
else
    warning( 'Recorder:ScaleTime' , 'No data in %s.Data (%s)' , inputname(1) , className )
end

end % function
