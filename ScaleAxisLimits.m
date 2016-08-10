function ScaleAxisLimits( axis_handle , ScaleFactor )
%SCALEAXISLIMITS apply a scaling factor on X and Y axes
%
%  SYNTAX
%  ScaleAxisLimits( axis_handle , ScaleFactor )
%  ScaleAxisLimits
%
%  INPUTS
%  1. axis_handle : axis handle pointer
%  2. ScaleFactor : numeric positive
%
%  NOTES
%  Works without arguments, using default values
%
%
% See also gca, xlim, ylim

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2015


%% Check input arguments

% narginchk(0,2)
% narginchk introduced in R2011b
if nargin < 0 || nargin > 2
    error('%s uses 0, 1 or 2 input argument(s)',mfilename)
end

if nargin < 2
    % 1.1 means +10%, so we can se clearly see horizontal and vertical
    % elements on the border of the axis
    ScaleFactor = 1.1;
end

if nargin < 1
    % Get Current Axis
    axis_handle = gca;
end

% Validate input arguments
% validateattributes(axis_handle,{'numeric'},{'scalar';'positive'},mfilename,'axis_handle',1)
% if or( isnumeric( axis_handle ) && axis_handle > 0 , isa( axis_handle , 'matlab.graphics.axis.Axes' ) )
%    error('axis_handle error')
% end
validateattributes(ScaleFactor,{'numeric'},{'scalar';'positive'},mfilename,'ScaleFactor',2)


%% X

% Fetch current xlim
old_xlim = xlim(axis_handle);

% Compute new xlim
range_x  = old_xlim(2) - old_xlim(1);
center_x = mean( old_xlim );
new_xlim = [ (center_x - range_x*ScaleFactor/2 ) center_x + range_x*ScaleFactor/2 ];


%% Y

% Fetch current ulim
old_ylim = ylim(axis_handle);

% Compute new ylim
range_y  = old_ylim(2) - old_ylim(1);
center_y = mean( old_ylim );
new_ylim = [ ( center_y - range_y*ScaleFactor/2 ) center_y + range_y*ScaleFactor/2 ];


%% Apply transformation

% Set new limits
xlim( axis_handle , new_xlim )
ylim( axis_handle , new_ylim )


end
