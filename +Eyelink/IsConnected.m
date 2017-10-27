function IsConnected

status = Eyelink('IsConnected');
ffprintf('Eyelink connection status : \n')
switch status
    case 1
        ffprintf('connected \n')
    case -1
        ffprintf('dummy-connected \n')
    case 2
        ffprintf('broadcast-connected \n')
    case 0
        ffprintf('NOT CONNECTED \n')
        error('Eyelink:Connection','Eyelink not connected')
end

end % function
