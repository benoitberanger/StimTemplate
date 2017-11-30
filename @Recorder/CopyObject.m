function newObject = CopyObject( self )
% newObject = self.CopyObject()
%
% Deep copy of the object

% Class name ?
className = class( self );

% Properties of this class ?
propOfClass = properties( self );

% New instance of this class
newObject = eval(className);

% Copy each properties
for p = 1 : length(propOfClass)
    newObject.(propOfClass{p}) = self.(propOfClass{p});
end

end % function
