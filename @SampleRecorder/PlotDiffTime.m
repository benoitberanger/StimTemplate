function PlotDiffTime( self )
% self.PlotDiffTime()
%
% Plot diff(time).

% Check if not empty
self.IsEmptyProperty('Data');

% Figure
figure( ...
    'Name'        , [ inputname(1) ' : ' class(self) ] , ...
    'NumberTitle' , 'off'                         ...
    )
hold all


plot(self.Data(1:end-1,1),diff(self.Data(:,1)));


% Legend
lgd = legend( 'diff(time)' );
set(lgd,'Interpreter','none','Location','Best')

xlabel(self.Header{1})

% ================ Adapt the graph axes limits ================

% Change the limit of the graph so we can clearly see the
% rectangles.

ScaleAxisLimits( gca , 1.1 )

end % function
