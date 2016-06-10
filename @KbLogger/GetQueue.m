function GetQueue( obj )
% obj.GetQueue()
%
% Fetch the queue and use AddEvent method to fill obj.Data
% according to the KbList

while KbEventAvail
    [evt, ~] = KbEventGet; % Get all queued keys
    if any( evt.Keycode == obj.KbList )
        key_idx = evt.Keycode == obj.KbList;
        obj.AddEvent( { obj.Header{ key_idx } evt.Time evt.Pressed NaN } )
    end
end

end
