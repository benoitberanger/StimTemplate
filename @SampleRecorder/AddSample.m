function AddSample( self , sample )
% self.AddSample( double(1,n) = ( timestamp data1 date2 ... ) )
%
% Add sample, according to the dimensions given by the Header

if length( sample ) == self.Columns % Check input arguments
    if size( sample , 1 ) > 0 && size( sample , 2 ) == 1 % if iscolumn( event )
        sample = sample';
    end
    self.IncreaseEventCount;
    self.Data( self.EventCount , : ) = sample;
else
    error( 'Wrong number of arguments' )
end

end % function
