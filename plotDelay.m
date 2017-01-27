function plotDelay( eventplanning , eventrecorder )
%PLOTDELAY Plot delay for each event between the onset scheduled ans the
%onset timestamp
%
%  SYNTAX
%  plotDelay( eventplanning , eventrecorder )
%  plotDelay
%
%  INPUTS
%  1. eventplanning is an EventPlanning object
%  2. eventrecorder is an EventRecorder object
%
%  NOTES
%  1. Time unit is millisecond (ms)
%  2. Without input arguments, the function will try to use ER, EP from the
%  base workspace
%
%
% See also EventRecorder, EventPlanning, plotStim

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2015


%% Check input data

% Must be 2 input arguments, or try with the base workspace
if nargin > 0

    % narginchk(2,2)
    % narginchk introduced in R2011b
    if nargin ~= 2
        error('%s uses 2 input argument(s)',mfilename)
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

    end

    % Check if all vairables have been found in the base workspace
    if ~ ( exist('eventplanning','var') && exist('eventrecorder','var') )
        error('Even without input arguments, the function tries to use the base workspace variables, but failed.')
    end

end


if ~ isa ( eventplanning , 'EventPlanning' )
    error( 'First argument eventplanning must be an object of class EventPlanning ' )
end

if ~ isa ( eventrecorder , 'EventRecorder' )
    error( 'First argument eventrecorder must be an object of class EventRecorder ' )
end

% if size( eventplanning.Data , 1 ) ~= size( eventrecorder.Data , 1 )
%     error( 'EventPlanning.Data and EventRecorder.Data must have the same number of lines' )
% end


%% How many events can we use ?

range = min( eventplanning.EventCount , eventrecorder.EventCount );

% -1 to not take into acount StopTime
if eventplanning.EventCount > eventrecorder.EventCount
    range = range - 1 ;
end

[event_name, idx_data2envent , idx_event2data] = unique_stable( eventrecorder.Data(1:range,1) );

Colors = lines( length(event_name) );


%% Prepare curves

planned_onset     = cell2mat(eventplanning.Data(1:range,2));
recorded_onset    = cell2mat(eventrecorder.Data(1:range,2));
onset_delay       = (recorded_onset - planned_onset) * 1000;

planned_duration  = cell2mat(eventplanning.Data(1:range,3));
recorded_duration = cell2mat(eventrecorder.Data(1:range,3));
duration_delay    = (recorded_duration - planned_duration) * 1000;

% Build a structure to gather all infos ready to be plotted
CurvesDelay    = struct;
CurvesDuration = struct;
for c = 1 : length(event_name)

    CurvesDelay(c).name     = event_name{c};
    CurvesDelay(c).color    = Colors(c,:);
    CurvesDelay(c).X        = planned_onset((idx_event2data == c));
    CurvesDelay(c).Y        = onset_delay((idx_event2data == c));

    CurvesDuration(c).name  = event_name{c};
    CurvesDuration(c).color = Colors(c,:);
    CurvesDuration(c).X     = planned_onset((idx_event2data == c));
    CurvesDuration(c).Y     = duration_delay((idx_event2data == c));

end

%% Plot

% Command window display
hdr = { 'event_name' 'p_ons (s)' 'r_ons (s)' 'd_ons (ms)' 'p_dur (s)' 'r_dur (s)' 'd_dur (ms)' };
dsp = vertcat ( hdr ,  [...
    eventrecorder.Data(1:range,1) num2cell(planned_onset) num2cell(recorded_onset) num2cell(onset_delay) ...
    num2cell(planned_duration) num2cell(recorded_duration) num2cell(duration_delay) ...
    ] );
disp(dsp)

% Input names
if nargin ~= 0 % real function input

    all_ipn = [ inputname(1) ' + ' inputname(2) ];

else % import from base workspace

    all_ipn = 'EP + ER';

end

% Figure
figure( ...
    'Name'        , [ mfilename ' : ' all_ipn ] , ...
    'NumberTitle' , 'off'                         ...
    )

% --- First graph ---------------------------------------------------------
graph_parts(1) = subplot(2,1,1);
hold all

% Plot each event type
for c = 1 : length(event_name)

    stem( graph_parts(1) , CurvesDelay(c).X , CurvesDelay(c).Y , 's' , 'Color' , CurvesDelay(c).color )

end

% Curve that crosses each point
plot( planned_onset , onset_delay ,':' , 'Color' , [0 0 0] )

xlabel('time (s)','interpreter','none')
ylabel('onset_delay (ms)','interpreter','none')

lgd = legend([ event_name ; 'onset_delay(time)' ]);
set(lgd,'interpreter','none','Location','Best')

ScaleAxisLimits


% --- Second graph --------------------------------------------------------
graph_parts(2) = subplot(2,1,2);
hold all

% Plot each event type
for c = 1 : length(event_name)

    stem( graph_parts(2) , CurvesDuration(c).X , CurvesDuration(c).Y , 's' , 'Color' , CurvesDuration(c).color )

end

% Curve that crosses each point
plot( planned_onset , duration_delay ,':' , 'Color' , [0 0 0] )

xlabel('time (s)','interpreter','none')
ylabel('duration_delay (ms)','interpreter','none')

event_dur1 = num2str( planned_duration(idx_data2envent) );
event_dur2 = cellstr( event_dur1 );
event_dur3 = regexprep( event_dur2 , ' ' , '' );
event_dur4 = strcat(event_dur3, ' (s)');

lgd = legend([ event_dur4 ; 'duration_delay(time)' ]);
set(lgd,'interpreter','none','Location','Best')

ScaleAxisLimits


end
