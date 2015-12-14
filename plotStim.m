function plotStim( eventplanning , eventrecorder , kblogger )
%PLOTSTIM Plot all events from a run : events planned, events recorded, mri
%triggers
%
%  SYNTAX
%  plotStim( eventplanning , eventrecorder , kblogger )
%
%  INPUTS
%  1. eventplanning is an EventPlanning object
%  2. eventrecorder is an EventRecorder object
%  3. kblogger is a KbLogger object
%
%  NOTES
%  1. All objects must have a non-empty GraphData property
%
%
% See also EventRecorder, EventPlanning, KbLogger

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2015


%% Check input data

% Must be 3 input arguments
narginchk(2,3)

if ~ isa ( eventplanning , 'EventPlanning' )
    error( 'First argument eventplanning must be an object of class EventPlanning ' )
end

if ~ isa ( eventrecorder , 'EventRecorder' )
    error( 'First argument eventrecorder must be an object of class EventRecorder ' )
end

if ~isprop(eventplanning,'GraphData') || isempty(eventplanning.GraphData)
    error('eventplanning must have a non-empty GraphData property')
end

if ~isprop(eventrecorder,'GraphData') || isempty(eventrecorder.GraphData)
    error('eventrecorder must have a non-empty GraphData property')
end

if nargin > 2
    
    if ~ isa ( kblogger , 'KbLogger' )
        error( 'First argument kblogger must be an object of class KbLogger ' )
    end
    
    if ~isprop(kblogger,'GraphData') || isempty(kblogger.GraphData)
        error('kblogger must have a non-empty GraphData property')
    end
    
end

%% Preparation of curves

nb_lines = size(eventplanning.GraphData,1) + size(eventrecorder.GraphData,1) + 1;
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
for er = 1: size(eventrecorder.GraphData,1)
    idx_ep_in_er = regexp( eventrecorder.GraphData(:,1) , eventplanning.GraphData{er,1} );
    idx_ep_in_er = ~cellfun( @isempty , idx_ep_in_er );
    idx_ep_in_er = find(idx_ep_in_er);
    
    % Yes, so add it into PlotData
    if idx_ep_in_er
        ER(er).object = 'ER';
        ER(er).index = idx_ep_in_er;
        ER(er).color = EP(er).color;
        ER(er).linestyle = '-.';
    end
    
end

if nargin > 2
    
    % Prepare MRI trigger curve
    MRI_trigger_kb_input = '5%'; % fORP in USB mode
    MRI_trigger_reference = regexp(kblogger.GraphData(:,1),MRI_trigger_kb_input);
    MRI_trigger_reference = ~cellfun(@isempty,MRI_trigger_reference);
    MRI_trigger_reference = find(MRI_trigger_reference);
    
    color_count = color_count + 1;
    KL.object = 'KL';
    KL.index = MRI_trigger_reference;
    KL.color = Colors(color_count,:);
    KL.linestyle = '-';
    
end

%% Plot

% Input names
all_ipn = '';
for ipn = 1 : nargin
   
    if ipn == 1
        all_ipn = [ all_ipn inputname(ipn) ];
    else
        all_ipn = [ all_ipn ' + ' inputname(ipn) ];
    end

end

% Figure
figure( 'Name' , [ mfilename ' : ' all_ipn ] , 'NumberTitle' , 'off' )
hold all

% Prepare the loop to plot each curves
PlotData.EP = EP;
PlotData.ER = ER;
if nargin > 2
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
                    eventplanning.GraphData{current_curve_data.index,3}(:,2) + current_curve_data.index ,...
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
                plot(kblogger.GraphData{current_curve_data.index,3}(:,1) ,...
                    kblogger.GraphData{current_curve_data.index,3}(:,2) * color_count ,...
                    'Color' , current_curve_data.color ,...
                    'LineStyle' , current_curve_data.linestyle )
                
                % current_curve_name = kblogger.GraphData{current_curve_data.index,1};
                current_curve_name = 'MRI_trigger';
                
        end
        
        % Prepare curve name
        current_curve_name = [ current_curve_data.object '.' current_curve_name ];
        
        % Store curve name
        CurvesNames{curve_count} = current_curve_name;
        
    end
    
end

% Legend
lgd = legend(CurvesNames);
set(lgd,'interpreter','none')


%%  Adapt the graph axes limits

% Change the limit of the graph so we can clearly see the
% rectangles.

scale = 1.1;

old_xlim = xlim;
range_x  = old_xlim(2) - old_xlim(1);
center_x = mean( old_xlim );
new_xlim = [ (center_x - range_x*scale/2 ) center_x + range_x*scale/2 ];

old_ylim = ylim;
range_y  = old_ylim(2) - old_ylim(1);
center_y = mean( old_ylim );
new_ylim = [ ( center_y - range_y*scale/2 ) center_y + range_y*scale/2 ];

% Set new limits
xlim( new_xlim )
ylim( new_ylim )


end
