function ExportToCSV( self, filename, withHeader )
%EXPORTTOCSV print the self.Header and self.Data in a CSV file, with ';' as separator
% withHeader=1 prints header (default), withHeader=0 does not.

if nargin < 3
    withHeader = 1;
end


%% Open file in write mod

fileID = fopen( [ filename '.csv' ] , 'w' , 'n' , 'UTF-8' );
if fileID < 0
    error('%d cannot be opened', filename)
end


%% Fill the file

% Print header
if withHeader
    fprintf(fileID, '%s;', self.Header{:});
    fprintf(fileID, '\n'); % end of line
end

% Print data
for i = 1 : size(self.Data,1)
    for j = 1 : size(self.Data,2)
        
        % Apply conversion if necessary
        
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
        fprintf(fileID, '%s;', toprint);
        
        % End of line
        if j == size(self.Data,2)
            fprintf(fileID, '\n');
        end
        
    end
end


%% Close the file

fclose( fileID );


end % function
