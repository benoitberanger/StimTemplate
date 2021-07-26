function StimTemplateContent

file_location = which(mfilename);

path_location = fileparts(file_location);

fprintf(' LOCATION : \n%s \n\n',path_location)

dirContent = dir(path_location);

fprintf(' CONTENT : \n')
for c = 1 : length(dirContent)
    
    if dirContent(c).isdir
        fprintf('%s%s\n',dirContent(c).name,filesep)
    else
        fprintf('%s\n',dirContent(c).name)
        
    end
    
end

end % function
