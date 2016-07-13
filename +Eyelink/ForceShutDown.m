function ForceShutDown

try
    Eyelink('StopRecording')
catch err1
end

try
    status = Eyelink('CloseFile');
catch err2
end

try
    Eyelink('Shutdown')
catch err3
end

end % function
