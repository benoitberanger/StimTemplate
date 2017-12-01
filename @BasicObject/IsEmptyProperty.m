function IsEmptyProperty( self , propertyname )
% self.IsEmptyProperty( PropertyName )
%
% Raise an error if self.'PropertyName' is empty

% Fetch caller object
[~, objName, ~] = fileparts(self.Description);

if isempty(self.(propertyname))
    error( 'Recorder:ScaleTime' , 'No data in %s.%s' , objName , propertyname )
end

end % function
