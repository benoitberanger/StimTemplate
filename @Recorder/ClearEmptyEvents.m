function ClearEmptyEvents( self )
% self.ClearEmptyEvents()
%
% Delete empty rows. Useful when NumberOfEvents is not known
% precisey but set to a great value (better for prealocating
% memory).

empty_idx = cellfun( @isempty , self.Data(:,1) );
self.Data( empty_idx , : ) = [];

end % function
