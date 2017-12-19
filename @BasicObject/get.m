function [ output ] = get( self, evt, str )
%GET is not a classc "get" method
% Here, this method is a way to fetch an element in self.Data

column = ~cellfun(@isempty,regexp(self.Header,str,'once'));
output = self.Data{evt,column};

end % function
