% ../
upperDir = fullfile( fileparts( pwd ) );

% ../data/
dataDir = fullfile( upperDir , 'data' );

% ../data/ exists ?
if ~isdir( dataDir )
    error( 'MATLAB:DataDirExists' , ' \n ---> data directory not found in the upper dir : %s <--- \n ' , upperDir )
end

SubjectID = get(handles.edit_SubjectID,'String');

% ../data/(SubjectID)
SubjectIDDir = fullfile( dataDir , SubjectID );

% ../data/(SubjectID) exists ?
if ~isdir( SubjectIDDir )
    warning( 'MATLAB:SubjectIDDirExists' ,  ' \n ---> SubjectID directory not found in : %s <--- \n ' , dataDir )
end

% Content order : older to newer
dirContent = struct2cell( dir(SubjectIDDir) );
[~,IX] = sort( cell2mat( dirContent(end,:) ) );
dirContentSorted = dirContent(:,IX);

% Display dir
fprintf('\n\n SubjectID data dir : %s \n', SubjectIDDir)

% Display content
for f = 1 : size(dirContentSorted,2)
    if regexp(dirContentSorted{1,f},'^\.$')
    elseif regexp(dirContentSorted{1,f},'^\.\.$')
    else
        fprintf('  %s \n', dirContentSorted{1,f})
    end
end
