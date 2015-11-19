clc
close all
clear

load kl.mat

%% Prepare a planning

% Create the planning object
EP = EventPlanning({'event_name','onset(s)'});

% Define a planing
EP.AddPlanning({...
    'C0' 0
    'C1' 2
    'Cross' 4
    'C0' 6
    'C1' 8
    'Cross' 10
    });

%% Prepare an event recorder

ER = EventRecorder({'event_name','onset(s)'},100);
ER.AddStartTime(0);
for k = 1:10
    switch mod(k,3)
        case 2
        ev = 'Cross';
        case 1
        ev = 'C1';
        case 0
        ev = 'C0';
    end
    ER.AddEvent({ev (k+rand)});
end
ER.ClearEmptyEvents;
