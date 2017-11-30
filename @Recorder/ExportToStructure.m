function savestruct = ExportToStructure( self )
% StructureToSave = self.ExportToStructure()
%
% Export all proporties of the object into a structure, so it
% can be saved.
% WARNING : it does not save the methods, just transform the
% object into a common structure.

ListProperties = properties(self);

for prop_number = 1:length(ListProperties)
    savestruct.(ListProperties{prop_number}) = self.(ListProperties{prop_number});
end

end % function
