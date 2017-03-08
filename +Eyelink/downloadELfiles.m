function downloadELfiles( where )
%DOWNLOADELFILES

%% Check input parameters

assert(ischar(where) && isvector(where), 'where is not a valid char(1,n)')

% The last character must bu a file separator
if ~( strcmp(where(end),'\') || strcmp(where(end),'/') )
    where = [where filesep];
end


%% Load the list of eyelink files

listfile = [where 'eyelink_files_to_download.txt'];

fid = fopen(listfile,'r','n','UTF-8'); % open in 'read' mode, in UTF-8 encoding
if fid == -1
    error('eyelink_files_to_download.txt cannot be opened')
end
A = textscan(fid,'%s %s');
fclose(fid);


%% Dowload eyelink files

for file = 1 : size(A{1},1)
    
    source = A{1}{file}; % in the eyelink
    dest   = A{2}{file}; % on the display computer (stim computer)
    
    fprintf('Eyelink file transfer IN PROGRESS \n')
    fprintf('Transfering ''%s'' into ''%s'' \n', source, dest);
    fprintf('It might take a few seconds... \n')
    status = Eyelink('ReceiveFile',source,[dest '.edf'],0);
    if status > 0
        fprintf('Eyelink file transfer DONE \n')
        fprintf('%s size is %d \n',dest,status)
    elseif status == 0
        fprintf('File transfer cancelled \n')
    elseif status < 0
        error('ReceiveFile error, status : %d ',status);
    end
    
    fprintf('\n')
    
end


end
