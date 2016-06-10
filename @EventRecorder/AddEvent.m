function AddEvent( obj , event )
% obj.AddEvent( cell(1,n) = { 'eventName' data1 date2 ... } )
%
% Add event, according to the dimensions given by the Header

if length( event ) == obj.Columns % Check input arguments
    if size( event , 1 ) > 0 && size( event , 2 ) == 1 % if iscolumn( event )
        event = event';
    end
    obj.IncreaseEventCount;
    obj.Data( obj.EventCount , : ) = event;
else
    error( 'Wrong number of arguments' )
end

end
