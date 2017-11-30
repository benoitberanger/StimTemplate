function IncreaseEventCount( obj )
% obj.IncreaseEventCount()
%
% Method used by other methods of the class. Usually, it's not
% used from outside of the class.

obj.EventCount = obj.EventCount + 1;

end
