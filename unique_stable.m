function [ uniqueValues , idx_uniqueValues2cellColumns ] = unique_stable( cellColumn )
% 'stable' flag of "unique" matlab function appeared after R2012. So here
% we use a part of this R2012 code, for cross-version compatibility.
% Real syntax should be :
% [uniqueValues,~,idx_uniqueValues2cellColumns] = unique(cellColumn,'stable')

% Sort C and get indices.
[sortC,indSortC] = sort(cellColumn);

% groupsSortC indicates the location of non-matching entries.
groupsSortC = ~strcmp(sortC(1:end-1),sortC(2:end));
groupsSortC = groupsSortC(:);

groupsSortC = [true;groupsSortC];       % First element is always a member of unique list.

invIndSortC = indSortC;
invIndSortC(invIndSortC) = 1:numel(cellColumn);    % Find inverse permutation.
logIndC = groupsSortC(invIndSortC);     % Create new logical by indexing into groupsSortC.

indC = logIndC;               % Find the indices of the unsorted logical.

uniqueValues = cellColumn(indC);

idx_uniqueValues2cellColumns = zeros(size(uniqueValues));

for evn = 1 : length(uniqueValues)
    
    idx =  ~cellfun( @isempty , regexp(cellColumn,uniqueValues{evn}) ) ;
    idx_uniqueValues2cellColumns(idx) = evn;
    
end

end

