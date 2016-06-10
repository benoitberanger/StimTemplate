function ComputeDurations( obj )
% obj.ComputeDurations()
%
% Compute durations for each onsets

onsets              = cell2mat( obj.Data (:,2) ); % Get the times
duration            = diff(onsets);               % Compute the differences
obj.Data(1:end-1,3) = num2cell( duration );       % Save durations

% For the last event, usually StopTime, we need an exception.
if strcmp( obj.Data{end,1} , 'StopTime' )
    obj.Data{end,3} = 0;
end

end
