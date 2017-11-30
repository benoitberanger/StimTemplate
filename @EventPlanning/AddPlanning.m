function AddPlanning( self , planning )
% self.AddPlanning( cell(1,n) = { 'eventName' onset duration ... } )
%
% Add planning, according to the dimensions given by the Header

if iscell(planning) && size( planning , 2 ) == self.Columns % Check input arguments
    self.EventCount = self.EventCount + size( planning , 1 );
    self.Data = [ self.Data ; planning ]; % == vertical concatenation
else
    error( 'Wrong number of arguments' )
end

end % function
