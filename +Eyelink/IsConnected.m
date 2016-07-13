function IsConnected

status = Eyelink('IsConnected');
fprintf('\n Eyelink connection status : \n')
switch status
    case 1
        fprintf('connected \n')
    case -1
        fprintf('dummy-connected \n')
    case 2
        fprintf('broadcast-connected \n')
    case 0
        fprintf('NOT CONNECTED \n')
        error('Eyelink:Connection','Eyelink not connected')
end

end % function
