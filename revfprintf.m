function revfprintf( newStr , reset )
%REVFPRINTF Summary of this function goes here
%   Detailed explanation goes here

% source from http://undocumentedmatlab.com/blog/command-window-text-manipulation

if nargin<2
    reset = 0;
end

global reverseStr

% Only for initilization
if ~ischar(reverseStr) || reset
    reverseStr = '';
end

fprintf([reverseStr, newStr]);
reverseStr = repmat(sprintf('\b'), 1, length(newStr));

end
