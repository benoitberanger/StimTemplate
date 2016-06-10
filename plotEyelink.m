function plotEyelink( readEyelink_output )
%PLOTEYELINK plots output 'Numeric' for redEyelink function
%
% plotEyelink( readEyelink_output )
%
%  INPUTS
%  1. readEyelink output structure
%
%  OUTPUTS
%  1. No output
%
%  NOTES
%  1. The function need the 'numeric' mode from readEyelink function
%
%
% See also readEyelink

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2014


%% Check input arguments

% If no input agument, call readEyelink directly to selact a file to read
% and plot.
if nargin < 1
    readEyelink_output = readEyelink;
end


%% Shortcuts

FieldNames = fieldnames(readEyelink_output);
for fieldNumber = 1:length(FieldNames)
    DynamicName = genvarname(FieldNames{fieldNumber});
    eval([DynamicName ' = readEyelink_output. ' DynamicName ';']);
end

FieldNames = fieldnames(Flags);
for fieldNumber = 1:length(FieldNames)
    DynamicName = genvarname(FieldNames{fieldNumber});
    eval([DynamicName ' = Flags. ' DynamicName ';']);
end


%% Transform timestamp (ms) into secondes (s)

%  Time = Numeric_events(:,Numeric_row_number.TIME);
%  Time = Time(isfinite(Time)); % Delete NaN;
%  Numeric_events(:,Numeric_row_number.TIME) = (Numeric_events(:,Numeric_row_number.TIME) - Time(1))/1000;


%% TTL

INPUT_flag = 0;
BUTTON_flag = 0;
if isfield(Numeric_row_number,'INPUT')
    Input = Numeric_events(:,Numeric_row_number.INPUT); %#ok<*NODEF>
    Input = Input(isfinite(Input)); % Delete NaN
    unique_Input = unique(Input); % Extract uniques values
    
    Button = Numeric_events(:,Numeric_row_number.BUTTON);
    Button = Button(isfinite(Button)); % Delete NaN
    unique_Button = unique(Button); % Extract uniques values
    
    % MRI trigger (TTL) @CENIR-Verio gives us : 255 = no signal, 253 = trigger
    if ~isempty(unique_Input)
        if unique_Input(1) == 253 &&  unique_Input(2) == 255
            % We transform the values such as : 255 -> 0, 253 -> 1.
            Numeric_events(:,Numeric_row_number.INPUT) = abs(Numeric_events(:,Numeric_row_number.INPUT)-255)/2;
            INPUT_flag = 1;
        end
    end
    
    % MRI trigger (TTL) @CENIR-Prisma gives us : Button_1(0) = no signal, Button_1(1) = trigger
    if ~isempty(unique_Button)
        if unique_Button(1) == 10 &&  unique_Button(2) == 11
            % We transform the values such as : 10 -> 0, 11 -> 1.
            Numeric_events(:,Numeric_row_number.BUTTON) = Numeric_events(:,Numeric_row_number.BUTTON)-10;
            BUTTON_flag = 1;
        end
    end
    
end


%% Ceils

% Monocular
if xor(SAMPLES_LEFT_flag,SAMPLES_RIGHT_flag)
    
    BLINK_ceil = 1;
    SACCADE_ceil = 2;
    FIXATION_ceil = 3;
    
    INPUT_ceil = FIXATION_ceil + 1;
    
    % Binocular
elseif SAMPLES_LEFT_flag && SAMPLES_RIGHT_flag
    
    BLINK_ceil_L = 1;
    SACCADE_ceil_L = 2;
    FIXATION_ceil_L = 3;
    
    BLINK_ceil_R = 1-0.5;
    SACCADE_ceil_R = 2-0.5;
    FIXATION_ceil_R = 3-0.5;
    
    INPUT_ceil = FIXATION_ceil_L + 1;
    
end


%% Color

X_color = [0 0 1]; % blue
Y_color = [0 0.5 0]; % dark green
D_color = [1 0 0]; % red
TTL_color = [0 0 0]; % black
BLINK_color = [1 0 1]; % magenta
SACCADE_color = [1 0.5 0]; % orange
FIXATION_color = [0 1 0]; % light green


%% LineWidth

SAMPLES_LineWidth = 1;
EVENTS_LineWidth = 1;


%% LineStyle

% Monocular
if xor(SAMPLES_LEFT_flag,SAMPLES_RIGHT_flag)
    
    SAMPLES_LineStyle = '-';
    EVENTS_LineStyle = '-';
    
    % Binocular
elseif SAMPLES_LEFT_flag && SAMPLES_RIGHT_flag
    
    SAMPLES_LineStyle_L = '-';
    SAMPLES_LineStyle_R = ':';
    EVENTS_LineStyle_L = '-';
    EVENTS_LineStyle_R = ':';
    
end

%% Plot

figure( ...
    'Name'        , ASCFile                     , ...
    'NumberTitle' , 'off'                       , ...
    'Units'       , 'Normalized'                , ...
    'Position'    , [0.05, 0.05, 0.90, 0.80]      ...
    )

%%%%%%%%%%%%%%%
%  Monocular  %
%%%%%%%%%%%%%%%
if xor(SAMPLES_LEFT_flag,SAMPLES_RIGHT_flag)
    
    %%% XP YP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax(1) = subplot(5,1,1:2);
    hold all
    lgd = {};
    
    lgd = [lgd ; 'XP'];
    plot(Numeric_events(:,Numeric_row_number.XP),...
        SAMPLES_LineStyle,...
        'Color',X_color,...
        'LineWidth',SAMPLES_LineWidth)
    
    lgd = [lgd ; 'YP'];
    plot(Numeric_events(:,Numeric_row_number.YP),...
        SAMPLES_LineStyle,...
        'Color',Y_color,...
        'LineWidth',SAMPLES_LineWidth)
    
    axis tight
    
    legend(lgd,'Location','Best')
    
    
    %%% Events %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax(2) = subplot(5,1,3);
    hold all
    lgd = {};
    
    lgd = [lgd ; 'FIXATION'];
    plot(Numeric_events(:,Numeric_row_number.FIXATION)*FIXATION_ceil,...
        EVENTS_LineStyle,...
        'Color',FIXATION_color,...
        'LineWidth',EVENTS_LineWidth)
    
    lgd = [lgd ; 'SACCADE'];
    plot(Numeric_events(:,Numeric_row_number.SACCADE)*SACCADE_ceil,...
        EVENTS_LineStyle,...
        'Color',SACCADE_color,...
        'LineWidth',EVENTS_LineWidth)
    
    lgd = [lgd ; 'BLINK'];
    plot(Numeric_events(:,Numeric_row_number.BLINK)*BLINK_ceil,...
        EVENTS_LineStyle,...
        'Color',BLINK_color,...
        'LineWidth',EVENTS_LineWidth)
    
    
    % TTL from MRI
    if INPUT_flag
        lgd = [lgd ; 'INPUT'];
        plot(Numeric_events(:,Numeric_row_number.INPUT)*INPUT_ceil,...
            '-',...
            'Color',TTL_color,...
            'LineWidth',1)
    elseif BUTTON_flag
        lgd = [lgd ; 'BUTTON'];
        plot(Numeric_events(:,Numeric_row_number.BUTTON)*INPUT_ceil,...
            '-',...
            'Color',TTL_color,...
            'LineWidth',1)
    end
    
    set(gca,'YTick',[])
    
    axis([0 1 0 INPUT_ceil])
    
    legend(lgd,'Location','Best')
    
    
    %%% PS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax(3) = subplot(5,1,4:5);
    hold all
    lgd = {};
    
    lgd = [lgd ; 'PS'];
    plot(Numeric_events(:,Numeric_row_number.PS),...
        SAMPLES_LineStyle,...
        'Color',D_color,...
        'LineWidth',SAMPLES_LineWidth)
    
    legend(lgd,'Location','Best')
    
    %     xlabel('time (s)')
    
    axis tight
    
    linkaxes(ax,'x')
    
    %%%%%%%%%%%%%
    % Binocular %
    %%%%%%%%%%%%%
elseif SAMPLES_LEFT_flag && SAMPLES_RIGHT_flag
    
    %%% XP YP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax(1) = subplot(5,1,1:2);
    hold all
    lgd = {};
    
    lgd = [lgd ; 'XPL'];
    plot(Numeric_events(:,Numeric_row_number.XPL),...
        SAMPLES_LineStyle_L,...
        'Color',X_color,...
        'LineWidth',SAMPLES_LineWidth)
    
    lgd = [lgd ; 'YPL'];
    plot(Numeric_events(:,Numeric_row_number.YPL),...
        SAMPLES_LineStyle_L,...
        'Color',Y_color,...
        'LineWidth',SAMPLES_LineWidth)
    
    lgd = [lgd ; 'XPR'];
    plot(Numeric_events(:,Numeric_row_number.XPR),...
        SAMPLES_LineStyle_R,...
        'Color',X_color,...
        'LineWidth',SAMPLES_LineWidth)
    
    lgd = [lgd ; 'YPR'];
    plot(Numeric_events(:,Numeric_row_number.YPR),...
        SAMPLES_LineStyle_R,...
        'Color',Y_color,...
        'LineWidth',SAMPLES_LineWidth)
    
    axis tight
    
    legend(lgd,'Location','Best')
    
    
    %%% Events %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax(2) = subplot(5,1,3);
    hold all
    lgd = {};
    
    lgd = [lgd ; 'FIXATION_L'];
    plot(Numeric_events(:,Numeric_row_number.FIXATION_L)*FIXATION_ceil_L,...
        EVENTS_LineStyle_L,...
        'Color',FIXATION_color,...
        'LineWidth',EVENTS_LineWidth)
    
    lgd = [lgd ; 'FIXATION_R'];
    plot(Numeric_events(:,Numeric_row_number.FIXATION_R)*FIXATION_ceil_R,...
        EVENTS_LineStyle_R,...
        'Color',FIXATION_color,...
        'LineWidth',EVENTS_LineWidth)
    
    lgd = [lgd ; 'SACCADE_L'];
    plot(Numeric_events(:,Numeric_row_number.SACCADE_L)*SACCADE_ceil_L,...
        EVENTS_LineStyle_L,...
        'Color',SACCADE_color,...
        'LineWidth',EVENTS_LineWidth)
    
    lgd = [lgd ; 'SACCADE_R'];
    plot(Numeric_events(:,Numeric_row_number.SACCADE_R)*SACCADE_ceil_R,...
        EVENTS_LineStyle_R,...
        'Color',SACCADE_color,...
        'LineWidth',EVENTS_LineWidth)
    
    lgd = [lgd ; 'BLINK_L'];
    plot(Numeric_events(:,Numeric_row_number.BLINK_L)*BLINK_ceil_L,...
        EVENTS_LineStyle_L,...
        'Color',BLINK_color,...
        'LineWidth',EVENTS_LineWidth)
    
    lgd = [lgd ; 'BLINK_R'];
    plot(Numeric_events(:,Numeric_row_number.BLINK_R)*BLINK_ceil_R,...
        EVENTS_LineStyle_R,...
        'Color',BLINK_color,...
        'LineWidth',EVENTS_LineWidth)
    
    
    % TTL from MRI
    if INPUT_flag
        lgd = [lgd ; 'INPUT'];
        plot(Numeric_events(:,1),Numeric_events(:,Numeric_row_number.INPUT)*INPUT_ceil,...
            '-',...
            'Color',TTL_color,...
            'LineWidth',1)
    elseif BUTTON_flag
        lgd = [lgd ; 'BUTTON'];
        plot(Numeric_events(:,1),Numeric_events(:,Numeric_row_number.BUTTON)*INPUT_ceil,...
            '-',...
            'Color',TTL_color,...
            'LineWidth',1)
    end
    
    set(gca,'YTick',[])
    
    axis([0 1 0 INPUT_ceil])
    
    legend(lgd,'Location','Best')
    
    %%% PS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax(3) = subplot(5,1,4:5);
    hold all
    lgd = {};
    
    lgd = [lgd ; 'PSL'];
    plot(Numeric_events(:,Numeric_row_number.PSL),...
        SAMPLES_LineStyle_L,...
        'Color',D_color,...
        'LineWidth',SAMPLES_LineWidth)
    
    lgd = [lgd ; 'PSR'];
    plot(Numeric_events(:,Numeric_row_number.PSR),...
        SAMPLES_LineStyle_R,...
        'Color',D_color,...
        'LineWidth',SAMPLES_LineWidth)
    
    legend(lgd,'Location','Best')
    
    %     xlabel('time (s)')
    
    axis tight
    
    linkaxes(ax,'x')
    
end


% %% filter
%
% Fs = 1000;
% signal = Numeric_events(:,Numeric_row_number.XP);
% signal = signal(isfinite(signal));
% % signal = signal - mean(signal);
% L = length(signal);
% NFFT = 2^nextpow2(L);
% Y = fft(signal,NFFT)/L;
% f = Fs/2*linspace(0,1,NFFT/2+1);
%
% figure
%
% plot(f,2*abs(Y(1:NFFT/2+1)))
% title('Single-Sided Amplitude Spectrum of y(t)')
% xlabel('Frequency (Hz)')
% ylabel('|Y(f)|')
% xlim([1 250])
%
%
% %%
%
% close all
%
% figure
%
%
% t = Numeric_events(:,Numeric_row_number.XP);
% y = Numeric_events(:,Numeric_row_number.YP);
%
% for k = 2:10:length(Numeric_events(:,Numeric_row_number.XP))
%
%     plot(t(k),y(k),'x','YDataSource','y')
%     axis([200 800 200 800])
%     pause(0.001)
%
% end

end
