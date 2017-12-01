function ScaleTime( self )
% self.ScaleTime()
%
% Scale the time origin to the first entry in self.Data

% Onsets of events
time = self.Data( : , 1 );

% Write scaled time
if ~isempty( time )
    self.Data( : , 1 ) = time - time(1);
else
    warning( 'SampleRecorder:ScaleTime' , 'No data in %s.Data (%s)' , inputname(1) )
end

end % function
