function GetQueue( self )
% self.GetQueue()
%
% Fetch the queue and use AddEvent method to fill self.Data
% according to the KbList

while KbEventAvail
    [evt, ~] = KbEventGet; % Get all queued keys
    if any( evt.Keycode == self.KbList )
        key_idx = evt.Keycode == self.KbList;
        self.AddEvent( { self.Header{ key_idx } evt.Time evt.Pressed NaN } )
    end
end

end % function
