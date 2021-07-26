function ExportToTSV( self, filename, withHeader )

if nargin < 3
    withHeader = 1;
end

self.ExportToTxt(filename,'tsv',withHeader)

end % function
