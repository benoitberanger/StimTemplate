function Plot( self , method )
% self.Plot( [method] )
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
    
    if isprop(self,'BlockData') && ~isempty(self.BlockData) && isempty(self.BlockGraphData) % BlockData exists ?
        self.BuildGraph('block')
        input  = 'BlockGraphData';
        
    elseif isprop(self,'BlockData') && ~isempty(self.BlockData)
        input  = 'BlockGraphData';
        
    elseif  isempty(self.GraphData)
        self.BuildGraph;
        
    end
    
end

% ======================== Plot ===============================


className = class(self);

% Depending on the object calling the method, the display changes.
switch className
    case 'EventRecorder'
        display_method = '+';
    case 'KbLogger'
        display_method = '*';
    case 'EventPlanning'
        display_method = '+';
    otherwise
        error('Unknown object caller. Check self.Description')
end

% Figure
figure( ...
    'Name'        , [ inputname(1) ' : ' className ] , ...
    'NumberTitle' , 'off'                         ...
    )
hold all

% For each Event, plot the curve
for e = 1 : size( self.(input) , 1 )
    
    if ~isempty(self.(input){e,2})
        
        switch display_method
            
            case '+'
                plot( self.(input){e,3}(:,1) , self.(input){e,3}(:,2) + e )
                
            case '*'
                plot( self.(input){e,3}(:,1) , self.(input){e,3}(:,2) * e )
                
            otherwise
                error('Unknown display_method')
        end
        
    else
        
        plot(0,NaN)
        
    end
    
end

% Legend
lgd = legend( self.(input)(:,1) );
set(lgd,'Interpreter','none','Location','Best')


% ================ Adapt the graph axes limits ================

% Change the limit of the graph so we can clearly see the
% rectangles.

ScaleAxisLimits( gca , 1.1 )

% ================ Change YTick and YTickLabel ================

% Put 1 tick in the middle of each event
switch display_method
    case '+'
        set( gca , 'YTick' , (1:size( self.(input) , 1 ))+0.5 )
    case '*'
        set( gca , 'YTick' , (1:size( self.(input) , 1 )) )
end

% Set the tick label to the event name
set( gca , 'YTickLabel' , self.(input)(:,1) )

% Not all versions of MATLAB have this option
try
    set(gca, 'TickLabelInterpreter', 'none')
catch %#ok<CTCH>
end

end % function
