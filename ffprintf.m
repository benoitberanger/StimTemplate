function ffprintf( varargin )
%FFPRINTF print function name, for diagnostic

stack = dbstack;

fprintf( ['[%s]: ' varargin{1}] , stack(2).file(1:end-2), varargin{2:end} )

end % function
