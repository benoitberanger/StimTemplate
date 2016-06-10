function AddPlanning( obj , planning )
% obj.AddPlanning( cell(1,n) = { 'eventName' onset duration ... } )
%
% Add planning, according to the dimensions given by the Header

if iscell(planning) && size( planning , 2 ) == obj.Columns % Check input arguments
    obj.EventCount = obj.EventCount + size( planning , 1 );
    obj.Data = [ obj.Data ; planning ]; % == vertical concatenation
else
    error( 'Wrong number of arguments' )
end

end
