% Clear everything

clc
close all
clear

%% Initialization

KbName('UnifyKeyNames');

keys = {'space' '5%' 'escape' 'A' 'Z' 'E' 'R' 'T' 'Y' 'J' 'K' 'L' 'X' 'C' 'B' 'N'};

KL = KbLogger(KbName(keys) , keys);

KL.Start;

%% Stop logger and display results

KL.GetQueue;

KL.Stop;

KL.ScaleTime;

KL.ComputeDurations;

KL.BuildGraph;

KL.Plot;

disp(KL)
disp(KL.Data)
disp(KL.KbEvents)
