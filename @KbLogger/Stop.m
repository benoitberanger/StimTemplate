function Stop( self )
% self.Stop()
%
% Stop collecting KeyBinds and Release the device

for index = 1 : length(self.Keyboard.keyboardIndices)
    
    KbQueueStop(self.Keyboard.keyboardIndices(index))
    KbQueueRelease(self.Keyboard.keyboardIndices(index))
    
end

end % function
