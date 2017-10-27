function Initialize

ffprintf('Try to connect with the Eyelink ... \n')

status = Eyelink('Initialize');
ffprintf(' Eyelink initialization status : \n')
switch status
    case 0
        ffprintf(' OK \n')
    otherwise
        ffprintf(' error %d \n',status)
        error('Eyelink:Connection','Eyelink not connected')
end

end % function
