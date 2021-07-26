function ExportToTxt( self, filename, filetype, withHeader )
%ExportToTxt print the self.Header and self.Data in a text file
% withHeader=1 prints header (default), withHeader=0 does not.

switch filetype
    case 'csv'
        ext = '.csv';
        sep = ';';
    case 'tsv'
        ext = '.tsv';
        sep = sprintf('\t');
    otherwise
        error('unmapped filetype')
end
    

%% Open file in write mod

fileID = fopen( [ filename ext ] , 'w' , 'n' , 'UTF-8' );
if fileID < 0
    error('%d cannot be opened', filename)
end


%% Fill the file

% Print header
if withHeader
    for h = 1 : length(self.Header)
        fprintf(fileID, '%s%s', self.Header{h},sep);
    end
    fprintf(fileID, '\n'); % end of line
end

% Print data
for i = 1 : size(self.Data,1)
    for j = 1 : size(self.Data,2)
        
        % Apply conversion if necessary
        
        switch class(self.Data)
            
            case 'cell'
                
                if ischar(self.Data{i,j})
                    toprint = self.Data{i,j};
                    
                elseif isnumeric(self.Data{i,j})
                    toprint = num2str(self.Data{i,j});
                    
                elseif islogical(self.Data{i,j})
                    switch self.Data{i,j}
                        case true
                            toprint = 'TRUE';
                        case false
                            toprint = 'FALSE';
                    end
                    
                end
                
                
            case 'double'
                
                if isnumeric(self.Data(i,j))
                    toprint = num2str(self.Data(i,j));
                    
                elseif islogical(self.Data(i,j))
                    switch self.Data(i,j)
                        case true
                            toprint = 'TRUE';
                        case false
                            toprint = 'FALSE';
                    end
                    
                end
                
            otherwise
                warning('unmapped input type')
        end
        
        fprintf(fileID, '%s%s', toprint,sep);
        
        % End of line
        if j == size(self.Data,2)
            fprintf(fileID, '\n');
        end
        
    end
end


%% Close the file

fclose( fileID );


end % function
