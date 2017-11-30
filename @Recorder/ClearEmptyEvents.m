function ClearEmptyEvents( obj )
% obj.ClearEmptyEvents()
%
% Delete empty rows. Useful when NumberOfEvents is not known
% precisey but set to a great value (better for prealocating
% memory).

empty_idx = cellfun( @isempty , obj.Data(:,1) );
obj.Data( empty_idx , : ) = [];
end
