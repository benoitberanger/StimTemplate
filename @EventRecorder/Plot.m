function Plot( obj , method )
% obj.Plot( [method] )
%
% Plot events over the time.
% method = 'normal' , 'block'

% Arguments ?
if nargin < 2
    method = 'normal';
else
    if ~ischar(method)
        error('method must be a char')
    end
end

switch lower(method)
    case 'normal'
        input  = 'GraphData';
    case 'block'
        input  = 'BlockGraphData';
    otherwise
        error( 'unknown method : %s' , method )
end

% =============== BuildGraph if necessary =====================

% Each subclass has its own BuildGraph method because Data
% properties are different. But each BuildGraph subclass method
% converge to a uniform GraphData.

if nargin < 2 % no input argument
    
    if ~isempty(obj.BlockData) && isempty(obj.BlockGraphData) % BlockData exists ?
        obj.BuildGraph('block')
        input  = 'BlockGraphData';
        
    elseif ~isempty(obj.BlockData)
        input  = 'BlockGraphData';
        
    elseif  isempty(obj.GraphData)
        obj.BuildGraph;
        
    end
    
end

% ======================== Plot ===============================

% Catch caller object
[~, name, ~] = fileparts(obj.Description);

% Depending on the object calling the method, the display changes.
switch name
    
    case 'EventRecorder'
        display_method = '+';
        
    case 'KbLogger'
        display_method = '*';
        
    case 'EventPlanning'
        display_method = '+';
        
    otherwise
        error('Unknown object caller')
        
end

% Figure
figure( ...
    'Name'        , [ inputname(1) ' : ' name ] , ...
    'NumberTitle' , 'off'                       , ...
    'Units'       , 'Normalized'                , ...
    'Position'    , [0.05, 0.05, 0.90, 0.80]      ...
    )
hold all

% For each Event, plot the curve
for e = 1 : size( obj.(input) , 1 )
    
    if ~isempty(obj.(input){e,2})
        
        switch display_method
            
            case '+'
                plot( obj.(input){e,3}(:,1) , obj.(input){e,3}(:,2) + e )
                
            case '*'
                plot( obj.(input){e,3}(:,1) , obj.(input){e,3}(:,2) * e )
                
            otherwise
                error('Unknown display_method')
        end
        
    else
        
        plot(0,NaN)
        
    end
    
end

% Legend
lgd = legend( obj.(input)(:,1) );
set(lgd,'Interpreter','none','Location','Best')

% ================ Adapt the graph axes limits ================

% Change the limit of the graph so we can clearly see the
% rectangles.

ScaleAxisLimits( gca , 1.1 )

% ================ Change YTick and YTickLabel ================

% Put 1 tick in the middle of each event
switch display_method
    case '+'
        set( gca , 'YTick' , (1:size( obj.(input) , 1 ))+0.5 )
    case '*'
        set( gca , 'YTick' , (1:size( obj.(input) , 1 )) )
end

% Set the tick label to the event name
set( gca , 'YTickLabel' , obj.(input)(:,1) )

end
