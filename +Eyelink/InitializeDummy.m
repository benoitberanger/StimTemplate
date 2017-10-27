function InitializeDummy

ffprintf('Try to DUMMY connect with the Eyelink ... \n')

status = Eyelink('InitializeDummy');
ffprintf(' Eyelink DUMMY initialization status : \n')
switch status
    case 0
        ffprintf(' OK \n')
    case -1
        error('Eyelink:DummyConnection','Eyelink could not DUMMY initialize')
    otherwise
        ffprintf(' error %d \n',status)
        error('Eyelink:DummyConnection','Eyelink other error...')
end

end % function
