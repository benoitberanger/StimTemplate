function Stop
% obj.Stop()
%
% Stop collecting KeyBinds and Release the device

KbQueueStop
KbQueueRelease

end
