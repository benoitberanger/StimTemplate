function newObject = CopyObject( obj )
% newObject = obj.CopyObject()
%
% Deep copy of the object

% Class name ?
className = class( obj );

% Properties of this class ?
propOfClass = properties( obj );

% New instance of this class
newObject = eval(className);

% Copy each properties
for p = 1 : length(propOfClass);
    newObject.(propOfClass{p}) = obj.(propOfClass{p});
end
