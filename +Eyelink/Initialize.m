fprintf('\n Try to connect with the Eyelink ... \n')

status = Eyelink('Initialize');
fprintf(' Eyelink initialization status : \n')
switch status
    case 1
        fprintf(' OK \n')
    otherwise
        fprintf(' error %d \n',status)
        error('Eyelink:Connection','Eyelink not connected')
end
