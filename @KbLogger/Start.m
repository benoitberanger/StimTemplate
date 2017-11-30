function Start(self)
% self.Start()
%
% Initialise the KeyBind Queue and start collecting the inputs

kbVect = zeros(1,256);
kbVect(self.KbList) = 1;

KbQueueCreate([],kbVect)
KbQueueStart

end % function
