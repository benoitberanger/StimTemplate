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
    warning( 'MATLAB:SubjectIDDirExists' ,  ' \n ---> SubjectID directory not found in the : %s <--- \n ' , dataDir )
end

% Display dir
disp(SubjectIDDir)

% Display content
dir(SubjectIDDir)
