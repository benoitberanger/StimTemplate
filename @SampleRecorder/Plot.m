function Plot( self )
% self.Plot()
%
% Plot samples over the time.

% Check if not empty
self.IsEmptyProperty(input);

% Figure
figure( ...
    'Name'        , [ inputname(1) ' : ' class(self) ] , ...
    'NumberTitle' , 'off'                         ...
    )
hold all

% For each Event, plot the curve
for signal = 2 : size( self.Data , 2 )
    plot(self.Data(:,1),self.Data(:,signal));    
end

% Legend
lgd = legend( self.Header(2:end) );
set(lgd,'Interpreter','none','Location','Best')

xlabel(self.Header{1})

% ================ Adapt the graph axes limits ================

% Change the limit of the graph so we can clearly see the
% rectangles.

ScaleAxisLimits( gca , 1.1 )

end % function
