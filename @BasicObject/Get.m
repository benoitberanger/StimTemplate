function [ output ] = Get( self, str, evt )
%GET is not a classc "get" method
%
% Here, this method is a way to fetch :
% 1) a column number      in slef.data . Syntax : columnNumber = obj.Get('regex'            )
% 2) an element contained in self.Data . Syntax : element      = obj.Get('regex', lineNumber)
%    lineNumber=integer ... => 1 element // lineNumber=vector => N elements // lineNumber=[] => all the column
%
% The 'regex' is a regular expression that will be found in obj.Header
%

column = ~cellfun(@isempty,regexp(self.Header,str,'once'));
assert(any(column), 'Get method did not find ''%s'' in the Header', str)

column = find(column);

if nargin < 3
    output = column;
    return
end

assert( isnumeric(evt), 'evt, if is defined, mut be numeric' )

if isempty(evt)
    output = self.Data(:,column);
    return
end

if isscalar(evt)
    switch class(self.Data)
        case 'cell'
            output = self.Data{evt,column};
        case 'double'
            output = self.Data(evt,column);
        otherwise
            output = self.Data{evt,column};
    end
    return
end

if isvector(evt)
    output = self.Data(evt,column);
    return
end

error('evt ?')

end % function
