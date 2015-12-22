function [c,indA,indC] = unique_stable( a )
% 'stable' flag of "unique" matlab function appeared after R2012. So here
% we use a part of this R2012 code, for cross-version compatibility.
% Real syntax ( matlab version >= R2012 ) should be :
% [c,indA,indC] = unique( a , 'stable' )

%% Check input arguments

narginchk(1,1)

validateattributes(a,{'cell'},{'column'},mfilename,'cellColumn',1)


%% Filter

numelA = numel(a);

% Sort A and get indices.
[sortA,indSortA] = sort(a);

% groupsSortA indicates the location of non-matching entries.
groupsSortA = ~strcmp(sortA(1:end-1),sortA(2:end));
groupsSortA = groupsSortA(:);

groupsSortA = [true;groupsSortA];       % First element is always a member of unique list.

% Extract unique elements
invIndSortA = indSortA;
invIndSortA(invIndSortA) = 1:numelA;    % Find inverse permutation.
logIndA = groupsSortA(invIndSortA);     % Create new logical by indexing into groupsSortA.
c = a(logIndA);                         % Create unique list by indexing into unsorted a.

% Find indA.

indA = find(logIndA);               % Find the indices of the unsorted logical.

% Find indC.

[~,indSortC] = sort(c);                         % Sort C to get index.

lengthGroupsSortA = diff(find([groupsSortA; true]));    % Determine how many of each of the above indices there are in IC.

diffIndSortC = diff(indSortC);                          % Get the correct amount of each index.
diffIndSortC = [indSortC(1); diffIndSortC];

indLengthGroupsSortA = cumsum([1; lengthGroupsSortA]);
indLengthGroupsSortA(end) = [];

indCOrderedBySortA(indLengthGroupsSortA) = diffIndSortC;        % Since indCOrderedBySortA is not already established as a column,
indCOrderedBySortA = indCOrderedBySortA.';                      % it becomes a row and that it needs to be transposed.

if sum(lengthGroupsSortA) ~= length(indCOrderedBySortA);
    indCOrderedBySortA(sum(lengthGroupsSortA)) = 0;
end

indCOrderedBySortA = cumsum(indCOrderedBySortA);
indC = indCOrderedBySortA(invIndSortA);                 % Reorder the list of indices to the unsorted order.


end
