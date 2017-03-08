function storeELfilename( where, ELfilename, destfilename )
%STOREELFILENAME

%% Check input parameters

assert(ischar(where)        && isvector(where),        'where is not a valid char(1,n)')
assert(ischar(ELfilename)   && isvector(ELfilename),   'ELfilename is not a valid char(1,n)')
assert(ischar(destfilename) && isvector(destfilename), 'destfilename is not a valid char(1,n)')

% The last character must bu a file separator
if ~( strcmp(where(end),'\') || strcmp(where(end),'/') )
    where = [where filesep];
end

%% Print in a file

listfile = [where 'eyelink_files_to_download.txt'];

fid = fopen(listfile,'a','n','UTF-8'); % open in 'append' mode, in UTF-8 encoding
if fid == -1
    error('eyelink_files_to_download.txt cannot be opened')
end
fprintf(fid,'%s %s\n',ELfilename,[where destfilename]); % write in a file
fclose(fid);

fprintf('In the file ''%s'' was wrote ''%s'' has to be transfered into ''%s'' \n', listfile, ELfilename, [where destfilename]);

end
