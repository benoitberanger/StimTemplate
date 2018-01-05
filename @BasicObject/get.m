function [ output ] = get( self, evt, str )
%GET is not a classc "get" method
% Here, this method is a way to fetch an element in self.Data

column = ~cellfun(@isempty,regexp(self.Header,str,'once'));
assert(any(column), 'get method did not find ''%s'' in the Header', str)
output = self.Data{evt,column};

end % function
