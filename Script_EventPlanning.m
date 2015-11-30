clc
close all
clear

%% Load an already prepared keybind logger

load KL.mat

KL.Plot

%% Prepare a planning

% Create the planning object
EP = EventPlanning({'event_name','onset(s)','duration(s)'});

% Define a planing
EP.AddPlanning({...
    'T_start' 0 0
    'C0' 0 2
    'C1' 2 2
    'Cross' 4 2
    'C0' 6 2
    'C1' 8 2
    'Cross' 10 2
    'C0' 12 2
    'C1' 14 2
    'Cross' 16 2
    'T_stop' 18 0
    });

EP.Plot

%% Prepare an event recorder

ER = EventRecorder({'event_name','onset(s)'},100);
ER.AddStartTime(0);
for k = 0:8
    switch mod(k,3)
        case 1
            ev = 'C1';
        case 0
            ev = 'C0';
        case 2
            ev = 'Cross';
    end
    ER.AddEvent({ev (2*k+rand)});
end
ER.AddStopTime((2*(k+1)+rand));
ER.ClearEmptyEvents;

ER.Plot
