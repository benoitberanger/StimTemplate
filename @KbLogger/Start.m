function Start( self )
% self.Start()
%
% Initialise the KeyBind Queue and start collecting the inputs

kbVect = zeros(1,256);
kbVect(self.KbList) = 1;

for index = 1 : length(self.Keyboard.keyboardIndices)
    
    KbQueueCreate(self.Keyboard.keyboardIndices(index),kbVect)
    KbQueueStart(self.Keyboard.keyboardIndices(index))
    
end

end % function
