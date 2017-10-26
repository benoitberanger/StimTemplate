function ShowCellTree(C)
% SHOWCELLTREE display the content of cells recursively, such as celldisp
% (form matlab) but with a "tree" look.
%
% See also celldisp (official MATLAB function) ShowStructTree (created by a
% user and published on Mathworks)


%% Paramters

if nargin<1
    error('Not enough input arguments.')
end


%% Initialize global variables

global cell_level % a counter for the levels (branches of the tree)

% Reset the variable only if the caller of the function is not herself
stacks = dbstack;
if length(stacks)>1
    if ~strcmp(stacks(2).name,mfilename)
        cell_level = 0;
    end
else
    cell_level = 0;
end


%% Recursive print

if iscell(C) && ~isempty(C)
    
    % Here I use linear indexing so the function can deal whith unknown
    % multidimentional cells.
    
    Size = size(C);
    N    = numel(C);
    
    % Pretty display of the "trunk", the input cell
    if cell_level == 0
        fprintf('%s%s \n',inputname(1),subs(N,Size))
    end
    
    % Time to go deeper ?
    cell_level = cell_level + 1;
    for i = 1:N
        fprintf('\n %s%s%s',char(repmat([124 9],[1 cell_level-1])),char([124 45 45 45]),subs(i,Size)) % Print the current element of the cell
        ShowCellTree(C{i}) % Go deeper : gi inside the current element of the cell (here is the recursivity)
    end
    cell_level = cell_level - 1;
    
else
    
    % Display the content of the cell (non-empty)
    if ~isempty(C)
        if ischar(C)
            for i = 1:size(C,1)
                fprintf(' = %s',C(i,:))
            end
        elseif isnumeric(C)
            fprintf(' = %g',C)
        else
            [m,n] = size(C);
            fprintf(' = %0.f-by-%0.f %s',m,n,class(C))
        end
        
    else % Display the content of the cell (empty)
        if iscell(C)
            fprintf(' = {}')
        elseif ischar(C)
            fprintf(' = ''''')
        elseif isnumeric(C)
            fprintf(' = []')
        else
            [m,n] = size(C);
            fprintf(' = %0.f-by-%0.f %s',m,n,class(C))
        end
        
    end
    
end

if cell_level == 0 % Only at the first stack of this recursive function.
    fprintf('\n')
end

end % function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This sub-function was taken from 'celldisp.m' from MATLAB R2011b

function s = subs(i,siz)
%SUBS Display subscripts

if length(siz)==2 && any(any(siz==1))
    v = cell(1,1);
else
    v = cell(size(siz));
end
[v{1:end}] = ind2sub(siz,i);

s = ['{' int2str(v{1})];
for i=2:length(v)
    s = [s ',' int2str(v{i})]; %#ok<AGROW>
end
s = [s '}'];

end % function
