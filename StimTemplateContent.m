function StimTemplateContent

file_location = which(mfilename);

path_location = fileparts(file_location);

fprintf(' LOCATION : \n%s \n\n',path_location)

dirContent = dir(path_location);

% dirContent_char = char(dirContent.name);
% ln = size(dirContent_char,2)+1;
% dirContent_category = '';

fprintf(' CONTENT : \n')
for c = 1 : length(dirContent)
    
    if dirContent(c).isdir
        %         dirContent_category(c,1:4) = 'dir ';
        %         dirContent_char(c,ln) = filesep;
        fprintf('%s%s\n',dirContent(c).name,filesep)
        
    else
        %         dirContent_category(c,1:4) = 'file';
        %         dirContent_char(c,ln) = ' ';
        fprintf('%s\n',dirContent(c).name)
        
    end
    
end
% disp(dirContent_char)

end % function
