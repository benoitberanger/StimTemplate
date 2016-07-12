function spm2bv( names , onsets , durations , filename )
%SPM2BV transform  'names', 'onsets', 'durations' cells (for SPM) to
%BrainVoyager *.prt text file


%% Open file in write mod

fileID = fopen( [ filename '.prt' ] , 'w' , 'n' , 'UTF-8' );


%% Fill the file

fprintf( fileID , 'NrOfConditions:  %d\r\n' , length(names) );
fprintf( fileID , '\r\n' );

for n = 1 : length(names)
    
    fprintf( fileID , '%s\r\n' , names{n} );
    fprintf( fileID , '%d\r\n' , length(onsets{n}) );
    
    for e = 1 : length(onsets{n})
        
        fprintf( fileID , '%f\t%f\r\n' , onsets{n}(e) , onsets{n}(e) + durations{n}(e) );
        
    end
    
    fprintf( fileID , '\r\n' );
    
end


%% Close the file

fclose( fileID );


end
