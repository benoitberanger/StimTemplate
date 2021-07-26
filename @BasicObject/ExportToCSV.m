function ExportToCSV( self, filename, withHeader )

if nargin < 3
    withHeader = 1;
end

self.ExportToTxt(filename,'csv',withHeader)

end % function
