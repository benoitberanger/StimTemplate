function plotStim( eventplanning , eventrecorder , kblogger )
%PLOTSTIM Plot all events from a run : events planned, events recorded, mri
%triggers
%
%  SYNTAX
%  plotStim( eventplanning , eventrecorder , kblogger )
%  plotStim
%
%  INPUTS
%  1. eventplanning is an EventPlanning object
%  2. eventrecorder is an EventRecorder object
%  3. kblogger is a KbLogger object
%
%  NOTES
%  1. All objects must have a non-empty GraphData property
%  2. Without input arguments, the function will try to use ER, EP, KL from
%  the base workspace
%
%
% See also EventRecorder, EventPlanning, KbLogger, plotDelay

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2015


%% Check input data

% Must be 3 input arguments, or try with the base workspace
if nargin > 0
    
    % narginchk(2,3)
    % narginchk introduced in R2011b
    if nargin < 2 || nargin > 3
        error('%s uses 2 or 3 input argument(s)',mfilename)
    end
    
else
    
    % Import variables from base workspace
    vars = evalin('base','whos');
    
    % Check each variable from base workspace
    for v = 1 : length(vars)
        
        % EventPlanning ?
        if strcmp ( vars(v).name , 'EP' ) && strcmp ( vars(v).class , 'EventPlanning' )
            eventplanning = evalin('base','EP');
        end
        % EventRecorder ?
        if strcmp ( vars(v).name , 'ER' ) && strcmp ( vars(v).class , 'EventRecorder' )
            eventrecorder = evalin('base','ER');
        end
        % KbLogger ?
        if strcmp ( vars(v).name , 'KL' ) && strcmp ( vars(v).class , 'KbLogger' )
            kblogger = evalin('base','KL');
        end
        
    end
    
    % Check if all vairables have been found in the base workspace
    if ~ ( exist('eventplanning','var') && exist('eventrecorder','var') && exist('kblogger','var') )
        error('Even without input arguments, the function tries to use the base workspace variables, but failed.')
    end
    
end


if ~ isa ( eventplanning , 'EventPlanning' )
    error( 'First argument eventplanning must be an object of class EventPlanning ' )
end

if ~ isa ( eventrecorder , 'EventRecorder' )
    error( 'First argument eventrecorder must be an object of class EventRecorder ' )
end

if ~isprop( eventplanning , 'GraphData' ) || isempty( eventplanning.GraphData )
    error( 'eventplanning must have a non-empty GraphData property' )
end

if ~isprop( eventrecorder , 'GraphData' ) || isempty( eventrecorder.GraphData )
    error( 'eventrecorder must have a non-empty GraphData property' )
end

if exist('kblogger','var')
    
    if ~ isa ( kblogger , 'KbLogger' )
        error( 'First argument kblogger must be an object of class KbLogger ' )
    end
    
    if ~isprop( kblogger , 'GraphData' ) || isempty( kblogger.GraphData )
        error( 'kblogger must have a non-empty GraphData property' )
    end
    
end

% if size( eventplanning.Data , 1 ) ~= size( eventrecorder.Data , 1 )
%     error( 'EventPlanning.Data and EventRecorder.Data must have the same number of lines' )
% end

if isempty(kblogger.Data)
    warning('plotStim:NoDataInKbLogger','kblogger.Data is empty')
end


%% Preparation of curves

nb_lines = size(eventplanning.GraphData,1) + size(eventrecorder.GraphData,1);
if exist('kblogger','var') && ~isempty(kblogger.Data)
    nb_lines = nb_lines + size(kblogger.GraphData,1);
end
Colors = lines( nb_lines  );
color_count = 0;

% Link between curves

for ep = 1 : size(eventplanning.GraphData,1)
    color_count = color_count + 1;
    EP(ep).object = 'EP'; %#ok<*AGROW>
    EP(ep).index = ep;
    EP(ep).color = Colors(ep,:);
    EP(ep).linestyle = '-';
end

% Is EventRecorder entry in EventPlanning ?
for er = 1 : size(eventrecorder.GraphData,1)
    idx_ep_in_er = regexp( eventrecorder.GraphData(:,1) , [ '^' eventplanning.GraphData{er,1} '$' ] );
    idx_ep_in_er = ~cellfun( @isempty , idx_ep_in_er );
    idx_ep_in_er = find( idx_ep_in_er );
    
    % Yes, so add it into PlotData
    if idx_ep_in_er
        ER(er).object = 'ER';
        ER(er).index = idx_ep_in_er;
        ER(er).color = EP(er).color;
        ER(er).linestyle = ':';
    end
    
end

if exist('kblogger','var') && ~isempty(kblogger.Data)
    
    for kb = 1 : size(kblogger.GraphData,1)
        
        % Prepare MRI trigger curve
        MRI_trigger_kb_input = '5%'; % fORP in USB mode
        MRI_trigger_reference = regexp( kblogger.GraphData(:,1) , [ '^' MRI_trigger_kb_input '$' ] );
        MRI_trigger_reference = ~cellfun( @isempty , MRI_trigger_reference );
        MRI_trigger_reference = find( MRI_trigger_reference );
        
        if kb == MRI_trigger_reference
            
            color_count = color_count + 1;
            KL(kb).object = 'KL';
            KL(kb).index = MRI_trigger_reference;
            KL(kb).color = Colors(color_count,:);
            KL(kb).linestyle = '-';
            
        else
            
            color_count = color_count + 1;
            KL(kb).object = 'KL';
            KL(kb).index = kb;
            KL(kb).color = Colors(color_count,:);
            KL(kb).linestyle = ':';
            
        end
        
    end
    
end

%% Plot

% Input names
all_ipn = '';

if nargin ~= 0 % real function input
    
    for ipn = 1 : nargin
        
        if ipn == 1
            all_ipn = [ all_ipn inputname(ipn) ];
        else
            all_ipn = [ all_ipn ' + ' inputname(ipn) ];
        end
        
    end
    
else % import from base workspace
    
    all_ipn = 'EP + ER + KL';
    
end

% Figure
figure( ...
    'Name'        , [ mfilename ' : ' all_ipn ] , ...
    'NumberTitle' , 'off'                       , ...
    'Units'       , 'Normalized'                , ...
    'Position'    , [0.05, 0.05, 0.90, 0.80]      ...
    )

hold all

% Prepare the loop to plot each curves
PlotData.EP = EP;
PlotData.ER = ER;
if exist('kblogger','var') && ~isempty(kblogger.Data)
    PlotData.KL = KL;
end
PlotDataFields = fieldnames(PlotData);

% How many curves ?
nb_curves = 0;
for pdf = 1:length(PlotDataFields)
    nb_curves = nb_curves + length( PlotData.(PlotDataFields{pdf}) );
end

% Prepare the legend
CurvesNames = cell(nb_curves,1);
curve_count = 0;

% Plot loop
for pdf = 1:length(PlotDataFields)
    
    % Shortcut : easier to read
    current_plot_data = PlotData.(PlotDataFields{pdf});
    
    for cpd = 1 : length(current_plot_data)
        
        % Shortcut : easier to read
        current_curve_data = current_plot_data(cpd);
        
        curve_count = curve_count + 1;
        
        % Curve comes from which object ?
        switch current_curve_data.object
            
            case 'EP'
                
                plot(eventplanning.GraphData{current_curve_data.index,3}(:,1) ,...
                    eventplanning.GraphData{current_curve_data.index,3}(:,2)*0.9 + current_curve_data.index ,...
                    'Color' , current_curve_data.color ,...
                    'LineStyle' , current_curve_data.linestyle )
                
                current_curve_name = eventplanning.GraphData{current_curve_data.index,1};
                
            case 'ER'
                
                plot(eventrecorder.GraphData{current_curve_data.index,3}(:,1) ,...
                    eventrecorder.GraphData{current_curve_data.index,3}(:,2) + current_curve_data.index ,...
                    'Color' , current_curve_data.color ,...
                    'LineStyle' , current_curve_data.linestyle )
                
                current_curve_name = eventrecorder.GraphData{current_curve_data.index,1};
                
            case 'KL'
                
                if isempty( kblogger.GraphData{current_curve_data.index,3} )
                    
                    plot( 0 ,...
                        0 ,...
                        'Color' , current_curve_data.color ,...
                        'LineStyle' , current_curve_data.linestyle )
                    
                else
                    
                    plot( kblogger.GraphData{current_curve_data.index,3}(:,1) ,...
                        kblogger.GraphData{current_curve_data.index,3}(:,2) * color_count ,...
                        'Color' , current_curve_data.color ,...
                        'LineStyle' , current_curve_data.linestyle )
                    
                end
                
                if current_curve_data.index == MRI_trigger_reference
                    current_curve_name = 'MRI_trigger';
                else
                    current_curve_name = kblogger.GraphData{current_curve_data.index,1};
                end
                
        end
        
        % Store curve name
        CurvesNames{curve_count} = current_curve_name;
        
    end
    
end

% Legend
lgd = legend(CurvesNames);
set(lgd,'interpreter','none','Location','Best')


%%  Adapt the graph axes limits

% Change the limit of the graph so we can clearly see the
% rectangles.

ScaleAxisLimits( gca , 1.1 )


%% Change YTick and YTickLabel

% Put 1 tick in the middle of each event
set( gca , 'YTick' , (1:size( CurvesNames , 1 ))+0.5 )

% Set the tick label to the event name
set( gca , 'YTickLabel' , CurvesNames )


end
