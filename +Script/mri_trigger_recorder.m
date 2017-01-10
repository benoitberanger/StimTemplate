%% This script need to be executed cell by cell

clc
close all
clear


%% Initialization : do it before start of the scanner

KbName('UnifyKeyNames');

if IsLinux
    keys = {'space' 'escape' 't'};
else
    keys = {'space' '5%' 'escape' 't'};
end

KL = KbLogger(KbName(keys) , keys);

KL.Start;






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scanner running : do nothing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Scanner stopped : Stop logger and display results

KL.GetQueue;

KL.Stop;

KL.ScaleTime;

KL.ComputeDurations;

KL.BuildGraph;

KL.Plot;

KL.ComputePulseSpacing(1);

disp(KL)
disp(KL.Data)
disp(KL.KbEvents)
