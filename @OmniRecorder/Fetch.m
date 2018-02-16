function [ output ] = Fetch( self, str, column )
%FETCH will fetch the lines containing 'str' in the column 'column'
%
% Exemple : self.Fetch( '+', self.Get('reward') )
%
% If 'column' is not defined, it will fetch in the culumn=1;
% To easily get a column index, use self.Get('columnRegex') method

if nargin < 3
    column = 1;
end

assert( nargin>=2 , 'str must be defined')
assert( ischar(str) && isvector(str), 'str must be char' )

try
    lines = ~cellfun(@isempty,regexp(self.Data(:,column),str,'once'));
catch err
    error('self.Data(:,column) must be char')
end

output = self.Data(lines,:);

end % function
