function ComputeDurations( self )
% self.ComputeDurations()
%
% Compute durations for each onsets

onsets               = cell2mat( self.Data (:,2) ); % Get the times
duration             = diff(onsets);               % Compute the differences
self.Data(1:end-1,3) = num2cell( duration );       % Save durations

% For the last event, usually StopTime, we need an exception.
if strcmp( self.Data{end,1} , 'StopTime' )
    self.Data{end,3} = 0;
end

end % function
