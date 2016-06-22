clc
close all
clear

%% Keybind logger

% Prepare
KbName('UnifyKeyNames');
if ~IsLinux
    keys = {'5%' 'space' 'escape'};
    KL = KbLogger(KbName(keys) , keys);
else
    keys = {'parenleft' 'space' 'escape'};
    KL = KbLogger( [15 66 10 ] , keys);
end
KL.Start;

% Stim
% [...] => any code you want

% Post stim
KL.GetQueue;
KL.Stop;
KL.GenerateMRITrigger( 2.140 , 10 , 0 ); % => in debug mode
KL.ScaleTime;
KL.ComputeDurations;

KL.BuildGraph;
% KL.Plot

%% Planning

% Prepare
header = {'event_name','onset(s)','duration(s)'};
EP = EventPlanning(header); % Create the planning object

% Stim paradigm : what you want
EP.AddPlanning({...
    'StartTime' 0 0
    'C0' 0 2
    'C1' 2 2
    'Cross' 4 2
    'C0' 6 2
    'C1' 8 2
    'Cross' 10 2
    'C0' 12 2
    'C1' 14 2
    'Cross' 16 2
    'StopTime' 18 0
    });

% Post stim
EP.BuildGraph;
% EP.Plot


%% Recorder

% Prepare
ER = EventRecorder(header,100);
ER.AddStartTime('StartTime',0);

% Stim : what you recored during the stimulation
for k = 0:8
    switch mod(k,3)
        case 1
            ev = 'C1';
        case 0
            ev = 'C0';
        case 2
            ev = 'Cross';
    end
    ER.AddEvent({ev (2*k+rand) []});
end
ER.AddStopTime('StopTime',(2*(k+1)+rand));

% Post stim
ER.ClearEmptyEvents;
ER.ComputeDurations
ER.BuildGraph;
% ER.Plot


%% Fusion

% Planning vs. Recorded  ( + Key logger )
plotStim(EP,ER,KL)

% Planning - Recorded = delay
plotDelay(EP,ER)