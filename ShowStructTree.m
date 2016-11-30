function ShowStructTree(run,toprint)

%Richard Moore
%December 4, 2012

%example usage: ShowStructureTree(run,'run');

%This will be a simple recursive function to display the fields in a
%struct as a tree.  For some reason there doesn't appear to be any easy way
%to do this already.  It explores the tree with a simple depth-first
%method.  

% -------------------------------------------------------------------------
% modif not from the author

if nargin<1
    error('Not enough input arguments.')
end

a = whos;

if nargin<2
    toprint = inputname(1);
end

% -------------------------------------------------------------------------

dots = find(toprint=='.');
if numel(dots)>0
    toshow = toprint((dots(end)+1):end);
    disp([char(repmat([124 9],1,numel(dots)-1)) char([124 45 45 45]) toshow]);
else
    disp(toprint);
end  

if isstruct(run)
    namesout = fieldnames(run);
    for x = 1:numel(namesout)
        ShowStructTree(eval([a(1).name '.' namesout{x}]),[toprint '.' namesout{x}]);
    end
end

%% Licence

% Copyright (c) 2013, Richard Moore
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

