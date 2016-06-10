function Start(obj)
% obj.Start()
%
% Initialise the KeyBind Queue and start collecting the inputs

kbVect = zeros(1,256);
kbVect(obj.KbList) = 1;

KbQueueCreate([],kbVect)
KbQueueStart

end
