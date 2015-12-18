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
% See also EventRecorder, EventPlanning, plotStim

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2015


%% Check input data

% Must be 2 input arguments, or try with the base workspace
if nargin > 0
    
    narginchk(1,2)
    
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

[event_name,idx_event2data] = unique_stable( eventrecorder.Data(1:range,1) );

Colors = lines( length(event_name) + 1  );


%% Prepare curves

planned_onset = cell2mat(eventplanning.Data(1:range,2));
recorded_onset = cell2mat(eventrecorder.Data(1:range,2));
delay = (recorded_onset - planned_onset) * 1000;

% Build a structure to gather all infos ready to be plotted
Curves = struct;
for c = 1 : length(event_name)
    
    Curves(c).name = event_name{c};
    Curves(c).color = Colors(c,:);
    Curves(c).X = planned_onset((idx_event2data == c));
    Curves(c).Y = delay((idx_event2data == c));
    
end

%% Plot

% Command window display
disp( [ eventrecorder.Data(1:range,1) num2cell(planned_onset) num2cell(recorded_onset) num2cell(delay) ] )

% Input names
if nargin ~= 0 % real function input
    
    all_ipn = [ inputname(1) ' + ' inputname(2) ];
    
else % import from base workspace
    
    all_ipn = 'EP + ER';
    
end

% Figure
figure( 'Name' , [ mfilename ' : ' all_ipn ] , 'NumberTitle' , 'off' )
hold all

% Plot each event type
for c = 1 : length(event_name)
    
    stem( Curves(c).X , Curves(c).Y , 's' , 'Color' , Curves(c).color )
    
end

% Curve that crosses each point
plot( planned_onset , delay ,':' , 'Color' , [0 0 0] )

xlabel('time (s)')
ylabel('delay (ms)')

lgd = legend([ event_name ; 'delay(t)' ]);
set(lgd,'interpreter','none')

ScaleAxisLimits

end
