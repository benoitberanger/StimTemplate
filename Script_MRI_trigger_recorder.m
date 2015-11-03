% Clear everything

clc
close all
clear

%% Initialization

KbName('UnifyKeyNames');

keys = {'space' '5%' 'escape'};

kl = KbQueueLogger(KbName(keys) , keys);

kl.Start;

%% Stop logger and display results

kl.GetQueue;

kl.Stop;

kl.ScaleTime;

kl.ComputeDurations;

kl.PlotKbEvents;

disp(kl)
disp(kl.Data)
disp(kl.KbEvents)
