function [ varargout ] = readEyelink( file , mode )
%READEYELINK function returns a structure containing data from a .asc
% Eyelink file.
%
% [ structure ] = readEyelink( 'name_of_the_file' , 'mode_name' )
%
%  INPUTS
%  1. file is the name of a .asc Eyelink file
%  2. mode can be :
%     - 'Numeric' (default), for a numeric array of all events
%     - 'Array', for arrays seperating all events
%     - 'Raw', for a cell containing each lines of the file
%     - 'All' = 'Numeric' + 'Array' + 'Raw'
%
%  OUTPUTS
%  1. Structure containing data from a .asc
% Eyelink file.
%
%  NOTES
%  1. If there is no input argument, the functons open a UI to select the
%  file to read.
%  2. If there is no mode as input argument, the function uses the default
%  mode (numeric).
%  3. The function takes less than 1 minutes to read a 10 minutes record
%  from the Eyelink (1000 Hz, monocular).
%
%
% See also plotEyelink

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2014


%% Check input arguments

% Flags & Initial values
Numeric_flag = 1; % Default value
Raw_flag = 0;
Array_flag = 0;
All_flag = 0;

if nargin < 1
    file = uigetfile('*.asc','Select the .asc Eyelink file');
end

if ~ischar(file)
    error('''file'' must be the name of .asc Eyelink file such as (with the quotes) : ''name_of_the_file'' ')
end

% Check the 'mode'
if exist('mode','var')
    if ischar(mode)
        if strcmpi(mode,'numeric')
            Numeric_flag = 1;
            Raw_flag = 0;
            Array_flag = 0;
        elseif strcmpi(mode,'raw')
            Numeric_flag = 0;
            Raw_flag = 1;
            Array_flag = 0;
        elseif strcmpi(mode,'array')
            Numeric_flag = 0;
            Raw_flag = 0;
            Array_flag = 1;
        elseif strcmpi(mode,'all')
            All_flag = 1;
        else
            error('''mode'' must be : ''numeric''(default), ''raw'', ''array'', ''all'' ')
        end
        
    else
        error('''mode'' must be : ''numeric''(default), ''raw'', ''array'', ''all'' ')
    end
end

% Open the file
file_ID = fopen( file, 'r' ) ;
if file_ID < 0
    error('%d cannot be opened', file)
end


%% Preparation of the Output

varargout{1}                = struct;
varargout{1}.DataDescriptor = 'Eyelink data from .asc file';
varargout{1}.CreatedBy      = mfilename;
varargout{1}.TimeStamp      = datestr(now);
varargout{1}.ASCFile        = file;

varargout{1}.other_info.COMMENT    = {};
varargout{1}.other_info.START      = {};
varargout{1}.other_info.PRESCALER  = {};
varargout{1}.other_info.VPRESCALER = {};
varargout{1}.other_info.PUPIL      = {};
varargout{1}.other_info.EVENTS     = {};
varargout{1}.other_info.SAMPLES    = {};
varargout{1}.other_info.END        = {};


%% Counting the lines in the file & Detection of SAMPLE and EVENTS architecture

start_time_count = tic;

line_count = 0;
EVENTS_flag = 0;
SAMPLES_flag = 0;
while ~feof(file_ID)
    line_content = fgets(file_ID) ;
    if ~EVENTS_flag
        if strfind( line_content , 'EVENTS' ) == 1
            EVENTS_line_content = line_content;
            EVENTS_flag = 1;
        end
    end
    if ~SAMPLES_flag
        if strfind( line_content , 'SAMPLES' ) == 1
            SAMPLES_line_content = line_content;
            SAMPLES_flag = 1;
            token = regexp(line_content,'RATE\t(\w+)','tokens');
            if ~isempty(token)
                varargout{1}.SamplingRate = str2double(token{1});
            end
        end
    end
    line_count = line_count + 1;
end
frewind(file_ID)
disp(['Number of lines in the file : ' num2str(line_count)])
disp(['Time to count the number of lines : ' num2str(toc(start_time_count)) ' s'])


%% Analyze of 'EVENTS' line and 'SAMPLES' line : Flag factory

EVENTS_LEFT_flag  = 0;
EVENTS_RIGHT_flag = 0;
EVENTS_RES_flag   = 0;

SAMPLES_LEFT_flag  = 0;
SAMPLES_RIGHT_flag = 0;
SAMPLES_RES_flag   = 0;
SAMPLES_VEL_flag   = 0;
SAMPLES_INPUT_flag = 0;

% EVENTS
if strfind( EVENTS_line_content , 'LEFT' )
    EVENTS_LEFT_flag = 1;
end
if strfind( EVENTS_line_content , 'RIGHT' )
    EVENTS_RIGHT_flag = 1;
end
if strfind( EVENTS_line_content , 'RES' )
    EVENTS_RES_flag = 1;
end

% SAMPLES
if strfind( SAMPLES_line_content , 'LEFT' )
    SAMPLES_LEFT_flag = 1;
end
if strfind( SAMPLES_line_content , 'RIGHT' )
    SAMPLES_RIGHT_flag = 1;
end
if strfind( SAMPLES_line_content , 'RES' )
    SAMPLES_RES_flag = 1;
end
if strfind( SAMPLES_line_content , 'VEL' )
    SAMPLES_VEL_flag = 1;
end
if strfind( SAMPLES_line_content , 'INPUT' )
    SAMPLES_INPUT_flag = 1;
end

varargout{1}.Flags.EVENTS_LEFT_flag   = EVENTS_LEFT_flag;
varargout{1}.Flags.EVENTS_RIGHT_flag  = EVENTS_RIGHT_flag;
varargout{1}.Flags.EVENTS_RES_flag    = EVENTS_RES_flag;

varargout{1}.Flags.SAMPLES_LEFT_flag  = SAMPLES_LEFT_flag;
varargout{1}.Flags.SAMPLES_RIGHT_flag = SAMPLES_RIGHT_flag;
varargout{1}.Flags.SAMPLES_RES_flag   = SAMPLES_RES_flag;
varargout{1}.Flags.SAMPLES_VEL_flag   = SAMPLES_VEL_flag;
varargout{1}.Flags.SAMPLES_INPUT_flag = SAMPLES_INPUT_flag;


%% NUMERIC : Preparation of variables

if Numeric_flag || All_flag
    
    %%%%%%%%%%%%%%%
    %  Monocular  %
    %%%%%%%%%%%%%%%
    if xor(SAMPLES_LEFT_flag,SAMPLES_RIGHT_flag)
        
        % Init
        Numeric_row_names         = {'TIME'};
        Numeric_row_number.TIME   = length(Numeric_row_names);
        
        % Loop for the rest
        for row_name = {'XP' 'YP' 'PS'}
            Numeric_row_names                = [Numeric_row_names row_name]; % Add name
            Numeric_row_number.(row_name{:}) = length(Numeric_row_names);    % Create dynamicly the number
        end
        
        
        % --- Velocity ---
        if SAMPLES_VEL_flag
            for row_name = {'XV' 'YV'}
                Numeric_row_names                = [Numeric_row_names row_name];
                Numeric_row_number.(row_name{:}) = length(Numeric_row_names);
            end
        end
        
        % --- Resolution ---
        if SAMPLES_RES_flag
            for row_name = {'XR' 'YR'}
                Numeric_row_names                = [Numeric_row_names row_name];
                Numeric_row_number.(row_name{:}) = length(Numeric_row_names);
            end
        end
        
        %%%%%%%%%%%%%%%
        %  Binocular  %
        %%%%%%%%%%%%%%%
    elseif SAMPLES_LEFT_flag && SAMPLES_RIGHT_flag
        
        % Init
        Numeric_row_names         = {'TIME'};
        Numeric_row_number.TIME   = length(Numeric_row_names);
        
        % Loop for the rest
        for row_name = {'XP' 'XPL' 'YPL' 'PSL' 'XPR' 'YPR' 'PSR'}
            Numeric_row_names                = [Numeric_row_names row_name]; % Add name
            Numeric_row_number.(row_name{:}) = length(Numeric_row_names);    % Create dynamicly the number
        end
        
        
        % --- Velocity ---
        if SAMPLES_VEL_flag
            for row_name = {'XVL' 'YVL' 'XVR' 'YVR'}
                Numeric_row_names                = [Numeric_row_names row_name];
                Numeric_row_number.(row_name{:}) = length(Numeric_row_names);
            end
        end
        
        % --- Resolution ---
        if SAMPLES_RES_flag
            for row_name = {'XR' 'YR'}
                Numeric_row_names                = [Numeric_row_names row_name];
                Numeric_row_number.(row_name{:}) = length(Numeric_row_names);
            end
        end
        
    end
    
    % --- Input ---
    if SAMPLES_INPUT_flag
        Numeric_row_names           = [Numeric_row_names {'INPUT'}];
        Numeric_row_number.INPUT    = length(Numeric_row_names);
    end
    
    % --- Button = MRI trigger @CENIR ---
    Numeric_row_names           = [Numeric_row_names {'BUTTON'}];
    Numeric_row_number.BUTTON = length(Numeric_row_names);
    
    
    %%%%%%%%%%%%%%%%%%%%%%
    %  Monocular EVENTS  %
    %%%%%%%%%%%%%%%%%%%%%%
    if xor(SAMPLES_LEFT_flag,SAMPLES_RIGHT_flag)
        
        for row_name = {'BLINK' 'SACCADE' 'FIXATION'}
            Numeric_row_names                = [Numeric_row_names row_name];
            Numeric_row_number.(row_name{:}) = length(Numeric_row_names);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%
        %  Binocular EVENTS  %
        %%%%%%%%%%%%%%%%%%%%%%
    elseif SAMPLES_LEFT_flag && SAMPLES_RIGHT_flag
        
        for row_name = {'BLINK_L' 'SACCADE_L' 'FIXATION_L' 'BLINK_R' 'SACCADE_R' 'FIXATION_R'}
            Numeric_row_names                = [Numeric_row_names row_name];
            Numeric_row_number.(row_name{:}) = length(Numeric_row_names);
        end
        
    end
    
    Numeric_events = nan(line_count,length(Numeric_row_names));
    
end


%% ARRAY : Preparation of variables

if Array_flag || All_flag
    
    sample_count = 0;
    sample_no_info_count = 0;
    
    % Preparation of data
    if SAMPLES_INPUT_flag
        SAMPLE_NO_INFO = zeros(line_count,3);
    else
        SAMPLE_NO_INFO = zeros(line_count,2);
    end
    SBLINK     = {};
    EBLINK     = {};
    SFIX       = {};
    EFIX       = {};
    SSACC      = {};
    ESACC      = {};
    INPUT      = [];
    BUTTON     = [];
    
    % Preallocating the SAMPLE matrix
    
    %%%%%%%%%%%%%%%
    %  Monocular  %
    %%%%%%%%%%%%%%%
    if xor(SAMPLES_LEFT_flag,SAMPLES_RIGHT_flag)
        
        % Init
        SAMPLE_row_names         = {'TIME'};
        SAMPLE_row_number.TIME   = length(SAMPLE_row_names);
        
        % Loop for the rest
        for row_name = {'XP' 'YP' 'PS'}
            SAMPLE_row_names                = [SAMPLE_row_names row_name]; % Add name
            SAMPLE_row_number.(row_name{:}) = length(SAMPLE_row_names);    % Create dynamicly the number
        end
        
        % --- Velocity ----
        if SAMPLES_VEL_flag
            for row_name = {'XV' 'YV'}
                SAMPLE_row_names                = [SAMPLE_row_names row_name];
                SAMPLE_row_number.(row_name{:}) = length(SAMPLE_row_names);
            end
        end
        
        % --- Resolution ---
        if SAMPLES_RES_flag
            for row_name = {'XR' 'YR'}
                SAMPLE_row_names                = [SAMPLE_row_names row_name];
                SAMPLE_row_number.(row_name{:}) = length(SAMPLE_row_names);
            end
        end
        
        %%%%%%%%%%%%%%%
        %  Binocular  %
        %%%%%%%%%%%%%%%
    elseif SAMPLES_LEFT_flag && SAMPLES_RIGHT_flag
        
        % Init
        SAMPLE_row_names         = {'TIME'};
        SAMPLE_row_number.TIME   = length(SAMPLE_row_names);
        
        % Loop for the rest
        for row_name =  {'XPL' 'YPL' 'PSL' 'XPR' 'YPR' 'PSR'}
            SAMPLE_row_names                = [SAMPLE_row_names row_name]; % Add name
            SAMPLE_row_number.(row_name{:}) = length(SAMPLE_row_names);    % Create dynamicly the number
        end
        
        % --- Velocity ---
        if SAMPLES_VEL_flag
            for row_name = {'XVL' 'YVL' 'XVR' 'YVR'}
                SAMPLE_row_names                = [SAMPLE_row_names row_name];
                SAMPLE_row_number.(row_name{:}) = length(SAMPLE_row_names);
            end
        end
        
        % --- Resolution ---
        if SAMPLES_RES_flag
            for row_name = {'XR' 'YR'}
                SAMPLE_row_names                = [SAMPLE_row_names row_name];
                SAMPLE_row_number.(row_name{:}) = length(SAMPLE_row_names);
            end
        end
        
    end
    
    % Add LINE row
    SAMPLE_row_names       = [SAMPLE_row_names 'LINE'];
    SAMPLE_row_number.LINE = length(SAMPLE_row_names);
    
    % --- Input ---
    if SAMPLES_INPUT_flag
        SAMPLE_row_names           = [SAMPLE_row_names {'INPUT'}];
        SAMPLE_row_number.INPUT    = length(SAMPLE_row_names);
    end
    
    % --- Button = MRI trigger @CENIR ---
    SAMPLE_row_names           = [SAMPLE_row_names {'BUTTON'}];
    SAMPLE_row_number.BUTTON = length(SAMPLE_row_names);
    
    SAMPLE = nan(line_count,length(SAMPLE_row_names));
    
end


%% RAW : Preparation of variables

if Raw_flag || All_flag
    raw_events = cell(line_count,1);
end


%% Analyse of each lign

% Count for lines
line_number = 0;

start_time_count = tic;

% Determination length of a complete sample S (basic scanned line)
Sample_length = ...
    1 + ... % time
    3 * (SAMPLES_LEFT_flag + SAMPLES_RIGHT_flag) + ... % ( XP YP PS ) for each eye
    2 * SAMPLES_VEL_flag * (SAMPLES_LEFT_flag + SAMPLES_RIGHT_flag) + ... % ( XV + YV ) for each eye if VELOCITY
    2 * SAMPLES_VEL_flag + ... % ( XR + YR ) for each eye if RESOLOLUTION
    SAMPLES_INPUT_flag;
disp(['Sample length is : ' num2str(Sample_length)])


while ~feof(file_ID)
    
    % Read next line
    line_content = fgets(file_ID) ;
    
    % Count a line
    line_number = line_number + 1 ;
    
    % Display each 10k lines a message
    if mod(line_number,10000) == 0
        disp(line_number)
        disp(['Time to analyze the last 10k lines : ' num2str(toc(start_time_count)) ' s'])
        start_time_count = tic;
    end
    
    % Architecture of a line containing a complete sample : In a Sample
    % line, there can be 14 numbers maximum
    S = sscanf(line_content,'%f');
    
    % === Sample analysis =================================================
    if length(S) == Sample_length
        
        %%%%%%%%%%%%%%%
        %  Monocular  %
        %%%%%%%%%%%%%%%
        if xor(SAMPLES_LEFT_flag,SAMPLES_RIGHT_flag)
            
            % Raw
            if Raw_flag || All_flag
                raw_events{line_number}.type      = 'SAMPLE' ;
                raw_events{line_number}.LINE      = line_number ;
                raw_events{line_number}.TIME      = S(1) ;
                raw_events{line_number}.XP        = S(2) ;
                raw_events{line_number}.YP        = S(3) ;
                raw_events{line_number}.PS        = S(4) ;
                if SAMPLES_INPUT_flag
                    raw_events{line_number}.INPUT = S(end) ;
                end
            end
            % Array
            if Array_flag || All_flag
                sample_count = sample_count + 1;
                SAMPLE(sample_count,SAMPLE_row_number.TIME)      = S(1);
                SAMPLE(sample_count,SAMPLE_row_number.XP)        = S(2);
                SAMPLE(sample_count,SAMPLE_row_number.YP)        = S(3);
                SAMPLE(sample_count,SAMPLE_row_number.PS)        = S(4);
                SAMPLE(sample_count,SAMPLE_row_number.LINE)      = line_number;
                if SAMPLES_INPUT_flag
                    SAMPLE(sample_count,SAMPLE_row_number.INPUT) = S(end);
                end
            end
            % Numeric
            if Numeric_flag || All_flag
                Numeric_events(line_number,Numeric_row_number.TIME)      = S(1);
                Numeric_events(line_number,Numeric_row_number.XP)        = S(2);
                Numeric_events(line_number,Numeric_row_number.YP)        = S(3);
                Numeric_events(line_number,Numeric_row_number.PS)        = S(4);
                if SAMPLES_INPUT_flag
                    Numeric_events(line_number,Numeric_row_number.INPUT) = S(end);
                end
            end
            
            %%%% Velocity %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if SAMPLES_VEL_flag && ~SAMPLES_RES_flag
                
                % Raw
                if Raw_flag || All_flag
                    raw_events{line_number}.XV = S(5) ;
                    raw_events{line_number}.YV = S(6) ;
                end
                % Array
                if Array_flag || All_flag
                    SAMPLE(sample_count,SAMPLE_row_number.XV) = S(5);
                    SAMPLE(sample_count,SAMPLE_row_number.YV) = S(6);
                end
                % Numeric
                if Numeric_flag || All_flag
                    Numeric_events(line_number,Numeric_row_number.XV) = S(5);
                    Numeric_events(line_number,Numeric_row_number.YV) = S(6);
                end
                
                %%% Resolution %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif ~SAMPLES_VEL_flag && SAMPLES_RES_flag
                
                % Raw
                if Raw_flag || All_flag
                    raw_events{line_number}.XR = S(5) ;
                    raw_events{line_number}.YR = S(6) ;
                end
                % Array
                if Array_flag || All_flag
                    SAMPLE(sample_count,SAMPLE_row_number.XR) = S(5);
                    SAMPLE(sample_count,SAMPLE_row_number.YR) = S(6);
                end
                % Numeric
                if Numeric_flag || All_flag
                    Numeric_events(line_number,Numeric_row_number.XR) = S(5);
                    Numeric_events(line_number,Numeric_row_number.YR) = S(6);
                end
                
                %%% Velocity + Resolution %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif SAMPLES_VEL_flag && SAMPLES_RES_flag
                
                % Raw
                if Raw_flag || All_flag
                    raw_events{line_number}.XV = S(5) ;
                    raw_events{line_number}.YV = S(6) ;
                    raw_events{line_number}.XR = S(7) ;
                    raw_events{line_number}.YR = S(8) ;
                end
                % Array
                if Array_flag || All_flag
                    SAMPLE(sample_count,SAMPLE_row_number.XV) = S(5);
                    SAMPLE(sample_count,SAMPLE_row_number.YV) = S(6);
                    SAMPLE(sample_count,SAMPLE_row_number.XR) = S(7);
                    SAMPLE(sample_count,SAMPLE_row_number.YR) = S(8);
                end
                % Numeric
                if Numeric_flag || All_flag
                    Numeric_events(line_number,Numeric_row_number.XV) = S(5);
                    Numeric_events(line_number,Numeric_row_number.YV) = S(6);
                    Numeric_events(line_number,Numeric_row_number.XR) = S(7);
                    Numeric_events(line_number,Numeric_row_number.YR) = S(8);
                end
                
            end
            
            
            %%%%%%%%%%%%%%%
            %  Binocular  %
            %%%%%%%%%%%%%%%
        elseif SAMPLES_LEFT_flag && SAMPLES_RIGHT_flag
            
            % Raw
            if Raw_flag || All_flag
                raw_events{line_number}.type      = 'SAMPLE' ;
                raw_events{line_number}.LINE      = line_number ;
                raw_events{line_number}.TIME      = S(1) ;
                raw_events{line_number}.XPL       = S(2) ;
                raw_events{line_number}.YPL       = S(3) ;
                raw_events{line_number}.PSL       = S(4) ;
                raw_events{line_number}.XPR       = S(5) ;
                raw_events{line_number}.YPR       = S(6) ;
                raw_events{line_number}.PSR       = S(7) ;
                if SAMPLES_INPUT_flag
                    raw_events{line_number}.INPUT = S(end) ;
                end
            end
            % Array
            if Array_flag || All_flag
                sample_count = sample_count + 1;
                SAMPLE(sample_count,SAMPLE_row_number.TIME)      = S(1);
                SAMPLE(sample_count,SAMPLE_row_number.XPL)       = S(2);
                SAMPLE(sample_count,SAMPLE_row_number.YPL)       = S(3);
                SAMPLE(sample_count,SAMPLE_row_number.PSL)       = S(4);
                SAMPLE(sample_count,SAMPLE_row_number.XPR)       = S(5);
                SAMPLE(sample_count,SAMPLE_row_number.YPR)       = S(6);
                SAMPLE(sample_count,SAMPLE_row_number.PSR)       = S(7);
                SAMPLE(sample_count,SAMPLE_row_number.LINE)      = line_number;
                if SAMPLES_INPUT_flag
                    SAMPLE(sample_count,SAMPLE_row_number.INPUT) = S(end);
                end
            end
            % Numeric
            if Numeric_flag || All_flag
                Numeric_events(line_number,Numeric_row_number.TIME)      = S(1);
                Numeric_events(line_number,Numeric_row_number.XPL)       = S(2);
                Numeric_events(line_number,Numeric_row_number.YPL)       = S(3);
                Numeric_events(line_number,Numeric_row_number.PSL)       = S(4);
                Numeric_events(line_number,Numeric_row_number.XPR)       = S(5);
                Numeric_events(line_number,Numeric_row_number.YPR)       = S(6);
                Numeric_events(line_number,Numeric_row_number.PSR)       = S(7);
                if SAMPLES_INPUT_flag
                    Numeric_events(line_number,Numeric_row_number.INPUT) = S(end);
                end
            end
            
            %%%% Velocity %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if SAMPLES_VEL_flag && ~SAMPLES_RES_flag
                
                % Raw
                if Raw_flag || All_flag
                    raw_events{line_number}.XVL = S(8) ;
                    raw_events{line_number}.YVL = S(9) ;
                    raw_events{line_number}.XVR = S(10) ;
                    raw_events{line_number}.YVR = S(11) ;
                end
                % Array
                if Array_flag || All_flag
                    SAMPLE(sample_count,SAMPLE_row_number.XVL) = S(8);
                    SAMPLE(sample_count,SAMPLE_row_number.YVL) = S(9);
                    SAMPLE(sample_count,SAMPLE_row_number.XVR) = S(10);
                    SAMPLE(sample_count,SAMPLE_row_number.YVR) = S(11);
                end
                % Numeric
                if Numeric_flag || All_flag
                    Numeric_events(line_number,Numeric_row_number.XVL) = S(8);
                    Numeric_events(line_number,Numeric_row_number.YVL) = S(9);
                    Numeric_events(line_number,Numeric_row_number.XVR) = S(10);
                    Numeric_events(line_number,Numeric_row_number.YVR) = S(11);
                end
                
                %%% Resolution %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif ~SAMPLES_VEL_flag && SAMPLES_RES_flag
                
                % Raw
                if Raw_flag || All_flag
                    raw_events{line_number}.XR = S(8) ;
                    raw_events{line_number}.YR = S(9) ;
                end
                % Array
                if Array_flag || All_flag
                    SAMPLE(sample_count,SAMPLE_row_number.XR) = S(8);
                    SAMPLE(sample_count,SAMPLE_row_number.YR) = S(9);
                end
                % Numeric
                if Numeric_flag || All_flag
                    Numeric_events(line_number,Numeric_row_number.XR) = S(8);
                    Numeric_events(line_number,Numeric_row_number.YR) = S(9);
                end
                
                %%% Velocity + Resolution %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif SAMPLES_VEL_flag && SAMPLES_RES_flag
                
                % Raw
                if Raw_flag || All_flag
                    raw_events{line_number}.XVL = S(8) ;
                    raw_events{line_number}.YVL = S(9) ;
                    raw_events{line_number}.XVR = S(10) ;
                    raw_events{line_number}.YVR = S(11) ;
                    raw_events{line_number}.XR  = S(12) ;
                    raw_events{line_number}.YR  = S(13) ;
                end
                % Array
                if Array_flag || All_flag
                    SAMPLE(sample_count,SAMPLE_row_number.XVL) = S(8);
                    SAMPLE(sample_count,SAMPLE_row_number.YVL) = S(9);
                    SAMPLE(sample_count,SAMPLE_row_number.XVR) = S(10);
                    SAMPLE(sample_count,SAMPLE_row_number.YVR) = S(11);
                    SAMPLE(sample_count,SAMPLE_row_number.XR)  = S(12);
                    SAMPLE(sample_count,SAMPLE_row_number.YR)  = S(13);
                end
                % Numeric
                if Numeric_flag || All_flag
                    Numeric_events(line_number,Numeric_row_number.XVL) = S(8);
                    Numeric_events(line_number,Numeric_row_number.YVL) = S(9);
                    Numeric_events(line_number,Numeric_row_number.XVR) = S(10);
                    Numeric_events(line_number,Numeric_row_number.YVR) = S(11);
                    Numeric_events(line_number,Numeric_row_number.XR)  = S(12);
                    Numeric_events(line_number,Numeric_row_number.YR)  = S(13);
                end
                
            end
        end
        
        % =================================================================
        % === Empty sample line (0 on each value) =========================
        % =================================================================
    elseif ~isempty(S) && length(S) < Sample_length
        
        NA = textscan(line_content,'%s');
        NA = NA{1,1};
        
        % Raw
        if Raw_flag || All_flag
            raw_events{line_number}.type      = 'SAMPLE_NO_INFO' ;
            raw_events{line_number}.LINE      = line_number ;
            raw_events{line_number}.TIME      = S(1) ;
            raw_events{line_number}.infos     = line_content ;
        end
        % Array
        if Array_flag || All_flag
            sample_no_info_count = sample_no_info_count + 1;
            if SAMPLES_INPUT_flag
                SAMPLE_NO_INFO(sample_no_info_count,:) = [line_number S(1) str2double(NA(end-1))];
            else
                SAMPLE_NO_INFO(sample_no_info_count,:) = [line_number S(1)];
            end
        end
        % Numeric
        if Numeric_flag || All_flag
            Numeric_events(line_number,Numeric_row_number.TIME) = S(1);
            if SAMPLES_INPUT_flag
                Numeric_events(line_number,Numeric_row_number.INPUT) = str2double(NA(end-1));
            end
        end
        
        
        % =================================================================
        % === Events analysis =============================================
        % =================================================================
        
        
        % --- SFIX : Fixation start ---------------------------------------
    elseif strfind( line_content , 'SFIX' ) == 1
        
        SF = sscanf(line_content,'SFIX %c %f \r\n');
        
        % Raw
        if Raw_flag || All_flag
            raw_events{line_number}.type   = 'SFIX';
            raw_events{line_number}.LINE   = line_number ;
            raw_events{line_number}.EYE    = char(SF(1)) ;
            raw_events{line_number}.STIME  = SF(2) ;
        end
        
        % Array
        if Array_flag || All_flag
            SFIX = [SFIX ; { line_number char(SF(1)) SF(2) }]; %#ok<*AGROW>
        end
        
        % Numeric
        if Numeric_flag || All_flag
            Numeric_events(line_number,Numeric_row_number.TIME) = SF(2);
            
            switch char(SF(1))
                case 'L'
                    SFIX_L_line = line_number;
                case 'R'
                    SFIX_R_line = line_number;
            end
            
        end
        
        % --- EFIX : Fixation end -----------------------------------------
    elseif strfind( line_content , 'EFIX' ) == 1
        
        EF = sscanf(line_content,'EFIX %c %f %f %f %f %f %f %f %f \r\n');
        
        % Raw
        if Raw_flag || All_flag
            raw_events{line_number}.type   = 'EFIX';
            raw_events{line_number}.LINE   = line_number ;
            raw_events{line_number}.EYE    = char(EF(1)) ;
            raw_events{line_number}.STIME  = EF(2) ;
            raw_events{line_number}.ETIME  = EF(3) ;
            raw_events{line_number}.DUR    = EF(4) ;
            raw_events{line_number}.AXP    = EF(5) ;
            raw_events{line_number}.AYP    = EF(6) ;
            raw_events{line_number}.APS    = EF(7) ;
            if EVENTS_RES_flag
                raw_events{line_number}.XR = EF(8) ;
                raw_events{line_number}.YR = EF(9) ;
            end
        end
        
        % Array
        if Array_flag || All_flag
            if EVENTS_RES_flag
                EFIX = [EFIX ; ...
                    { line_number char(EF(1)) EF(2) EF(3) EF(4) EF(5) EF(6) EF(7) EF(8) EF(9)}];
            else
                EFIX = [EFIX ; ...
                    { line_number char(EF(1)) EF(2) EF(3) EF(4) EF(5) EF(6) EF(7) }];
            end
        end
        
        % Numeric
        if Numeric_flag || All_flag
            
            Numeric_events(line_number,Numeric_row_number.TIME) = EF(3);
            
            switch char(EF(1))
                case 'L'
                    SFIX_line = SFIX_L_line;
                case 'R'
                    SFIX_line = SFIX_R_line;
            end
            
            for k = SFIX_line:line_number
                
                % M
                if xor(EVENTS_LEFT_flag,EVENTS_RIGHT_flag)
                    Numeric_events(k,Numeric_row_number.FIXATION) = 1;
                    
                    % B
                elseif EVENTS_LEFT_flag && EVENTS_RIGHT_flag
                    
                    % L/R
                    switch char(EF(1))
                        case 'L'
                            Numeric_events(k,Numeric_row_number.FIXATION_L) = 1;
                        case 'R'
                            Numeric_events(k,Numeric_row_number.FIXATION_R) = 1;
                    end
                    
                end
                
            end
            
        end
        
        
        % --- SSACC : Saccade start ---------------------------------------
    elseif strfind( line_content , 'SSACC' ) == 1
        
        SS = sscanf(line_content,'SSACC %c %f \r\n');
        
        % Raw
        if Raw_flag || All_flag
            raw_events{line_number}.type  = 'SSACC';
            raw_events{line_number}.LINE  = line_number ;
            raw_events{line_number}.EYE   = char(SS(1)) ;
            raw_events{line_number}.STIME = SS(2) ;
        end
        
        % Array
        if Array_flag || All_flag
            SSACC = [SSACC ; { line_number char(SS(1)) SS(2)}];
        end
        
        % Numeric
        if Numeric_flag || All_flag
            Numeric_events(line_number,Numeric_row_number.TIME) = SS(2);
            
            switch char(SS(1))
                case 'L'
                    SSACC_L_line = line_number;
                case 'R'
                    SSACC_R_line = line_number;
            end
            
        end
        
        
        % --- ESACC : Saccade end -----------------------------------------
    elseif strfind( line_content , 'ESACC' ) == 1
        
        ES = sscanf(line_content,'ESACC %c %f %f %f %f %f %f %f %f %f %f %f \r\n');
        
        
        
        % Raw
        if Raw_flag || All_flag
            raw_events{line_number}.type       = 'ESACC';
            raw_events{line_number}.LINE       = line_number ;
            raw_events{line_number}.EYE        = char(ES(1)) ;
            raw_events{line_number}.STIME      = ES(2) ;
            raw_events{line_number}.ETIME      = ES(3) ;
            raw_events{line_number}.DUR        = ES(4) ;
            if length(ES)>=10
                raw_events{line_number}.SXP    = ES(5) ;
                raw_events{line_number}.SYP    = ES(6) ;
                raw_events{line_number}.EXP    = ES(7) ;
                raw_events{line_number}.EYP    = ES(8) ;
                raw_events{line_number}.AMPL   = ES(9) ;
                raw_events{line_number}.PV     = ES(10) ;
                if EVENTS_RES_flag
                    raw_events{line_number}.XR = ES(11) ;
                    raw_events{line_number}.YR = ES(12) ;
                end
            end
        end
        
        % Array
        if Array_flag || All_flag
            if length(ES)>=10
                if EVENTS_RES_flag
                    ESACC = [ESACC ; ...
                        { line_number char(ES(1)) ES(2) ES(3) ES(4) ES(5) ES(6) ES(7) ES(8) ES(9) ES(10) ES(11) ES(12) }];
                else
                    ESACC = [ESACC ; ...
                        { line_number char(ES(1)) ES(2) ES(3) ES(4) ES(5) ES(6) ES(7) ES(8) ES(9) ES(10)}];
                end
            else
                ESACC = [ESACC ; ...
                    { line_number char(ES(1)) ES(2) ES(3) ES(4) NaN NaN NaN NaN NaN NaN}];
            end
        end
        
        % Numeric
        if Numeric_flag || All_flag
            
            Numeric_events(line_number,Numeric_row_number.TIME) = ES(3);
            
            switch char(ES(1))
                case 'L'
                    SSACC_line = SSACC_L_line;
                case 'R'
                    SSACC_line = SSACC_R_line;
            end
            
            for k = SSACC_line:line_number
                
                % M
                if xor(EVENTS_LEFT_flag,EVENTS_RIGHT_flag)
                    Numeric_events(k,Numeric_row_number.SACCADE) = 1;
                    
                    % B
                elseif EVENTS_LEFT_flag && EVENTS_RIGHT_flag
                    
                    % L/R
                    switch char(ES(1))
                        case 'L'
                            Numeric_events(k,Numeric_row_number.SACCADE_L) = 1;
                        case 'R'
                            Numeric_events(k,Numeric_row_number.SACCADE_R) = 1;
                    end
                    
                end
                
            end
            
        end
        
        
        
        % --- SBLINK : Blinking start -------------------------------------
    elseif strfind( line_content , 'SBLINK' ) == 1
        
        SB = sscanf(line_content,'SBLINK %c %f \r\n');
        
        % Raw
        if Raw_flag || All_flag
            raw_events{line_number}.type   = 'SBLINK';
            raw_events{line_number}.LINE   = line_number ;
            raw_events{line_number}.TIME   = SB(2) ;
            raw_events{line_number}.EYE    = char(SB(1)) ;
        end
        
        % Array
        if Array_flag || All_flag
            SBLINK = [SBLINK ; { line_number SB(2) char(SB(1)) }];
        end
        
        % Numeric
        if Numeric_flag || All_flag
            Numeric_events(line_number,Numeric_row_number.TIME) = SB(2);
            
            switch char(SB(1))
                case 'L'
                    SBLINK_L_line = line_number;
                case 'R'
                    SBLINK_R_line = line_number;
            end
            
        end
        
        % --- EBLINK : Blinking end ---------------------------------------
    elseif strfind( line_content , 'EBLINK' ) == 1
        
        EB = sscanf(line_content,'EBLINK %c %f %f %f \r\n');
        
        % Raw
        if Raw_flag || All_flag
            raw_events{line_number}.type   = 'EBLINK';
            raw_events{line_number}.LINE   = line_number ;
            raw_events{line_number}.EYE    = char(EB(1)) ;
            raw_events{line_number}.STIME  = EB(2) ;
            raw_events{line_number}.ETIME  = EB(3) ;
            raw_events{line_number}.DUR    = EB(4) ;
        end
        
        % Array
        if Array_flag || All_flag
            EBLINK = [EBLINK ; { line_number char(EB(1)) EB(2) EB(3) EB(4)}];
        end
        
        % Numeric
        if Numeric_flag || All_flag
            
            Numeric_events(line_number,Numeric_row_number.TIME) = EB(3);
            
            switch char(EB(1))
                case 'L'
                    SBLINK_line = SBLINK_L_line;
                case 'R'
                    SBLINK_line = SBLINK_R_line;
            end
            
            for k = SBLINK_line:line_number
                
                % M
                if xor(EVENTS_LEFT_flag,EVENTS_RIGHT_flag)
                    Numeric_events(k,Numeric_row_number.BLINK) = 1;
                    
                    % B
                elseif EVENTS_LEFT_flag && EVENTS_RIGHT_flag
                    
                    % L/R
                    switch char(EB(1))
                        case 'L'
                            Numeric_events(k,Numeric_row_number.BLINK_L) = 1;
                        case 'R'
                            Numeric_events(k,Numeric_row_number.BLINK_R) = 1;
                    end
                    
                end
                
            end
            
        end
        
        
        
        % --- INPUT : Input line ------------------------------------------
    elseif strfind( line_content , 'INPUT' ) == 1
        
        IP = sscanf(line_content,'INPUT\t%f\t%f\r\n');
        
        % Raw
        if Raw_flag || All_flag
            raw_events{line_number}.type   = 'INPUT' ;
            raw_events{line_number}.LINE   = line_number ;
            raw_events{line_number}.TIME   = IP(1) ;
            raw_events{line_number}.INPUT  = IP(2) ;
        end
        
        % Array
        if Array_flag || All_flag
            INPUT = [ INPUT ; line_number IP(1) IP(2) ];
        end
        
        % Numeric
        if Numeric_flag || All_flag
            Numeric_events(line_number,Numeric_row_number.TIME) = IP(1);
            if SAMPLES_INPUT_flag
                Numeric_events(line_number,Numeric_row_number.INPUT) = IP(2);
            end
        end
        
        % --- BUTTON : Button line ------------------------------------------
    elseif strfind( line_content , 'BUTTON' ) == 1
        
        BU = sscanf(line_content,'BUTTON\t%f\t%f\t%f\r\n');
        
        % Raw
        if Raw_flag || All_flag
            raw_events{line_number}.type   = 'BUTTON' ;
            raw_events{line_number}.LINE   = line_number ;
            raw_events{line_number}.TIME   = BU(1) ;
            raw_events{line_number}.BUTTON = BU(2) ;
            raw_events{line_number}.STATE  = BU(3) ;
        end
        
        % Array
        if Array_flag || All_flag
            BUTTON = [ BUTTON ; line_number BU(1) BU(2) BU(3) ];
        end
        
        % Numeric
        if Numeric_flag || All_flag
            % State
            switch BU(3)
                case 1
                    LastButtonUP = [ line_number BU(2) BU(3) ]; % Store last button up
                case 0
                    if exist('LastButtonUP','var') && BU(2) == LastButtonUP(2) % exist('LastButtonUP','var') is here to avoid a bug when the first button line in the file is button release
                        for k = LastButtonUP(1):line_number % Write lastbutton up during its activation
                            Numeric_events(k,Numeric_row_number.BUTTON) = 10*LastButtonUP(2) + 1*LastButtonUP(3); % WARNING : Encoding of the button [1-8] and state [0-1]
                        end
                        Numeric_events(LastButtonUP(1)-1,Numeric_row_number.BUTTON) = 10*BU(2) + 1*BU(3);
                    end
            end
            Numeric_events(line_number,Numeric_row_number.TIME)   = BU(1);
            Numeric_events(line_number,Numeric_row_number.BUTTON) = 10*BU(2) + 1*BU(3); % WARNING : Encoding of the button [1-8] and state [0-1]
        end
        
        % --- MSG : Messsage ----------------------------------------------
    elseif strfind( line_content , 'MSG' ) == 1
        
        % Raw
        if Raw_flag || All_flag
            raw_events{line_number}.type  = 'MSG' ;
            raw_events{line_number}.LINE  = line_number ;
            raw_events{line_number}.infos = line_content ;
        end
        
        
        % === Other types of lines we recognize ===========================
        
        % --- ** : Comment ------------------------------------------------
    elseif strfind( line_content , '**' ) == 1
        
        varargout{1}.other_info.COMMENT = [varargout{1}.other_info.COMMENT;{line_number line_content}];
        
        % Start line
    elseif strfind( line_content , 'START' ) == 1
        
        varargout{1}.other_info.START = [varargout{1}.other_info.START;{line_number line_content}];
        
    elseif strfind( line_content , 'PRESCALER' ) == 1
        
        varargout{1}.other_info.PRESCALER = [varargout{1}.other_info.PRESCALER;{line_number line_content}];
        
    elseif strfind( line_content , 'VPRESCALER' ) == 1
        
        varargout{1}.other_info.VPRESCALER = [varargout{1}.other_info.VPRESCALER;{line_number line_content}];
        
    elseif strfind( line_content , 'PUPIL' ) == 1
        
        varargout{1}.other_info.PUPIL = [varargout{1}.other_info.PUPIL;{line_number line_content}];
        
    elseif strfind( line_content , 'EVENTS' ) == 1
        
        varargout{1}.other_info.EVENTS = [varargout{1}.other_info.EVENTS;{line_number line_content}];
        
    elseif strfind( line_content , 'SAMPLES' ) == 1
        
        varargout{1}.other_info.SAMPLES = [varargout{1}.other_info.SAMPLES;{line_number line_content}];
        
        % End line
    elseif strfind( line_content , 'END' ) == 1
        
        varargout{1}.other_info.END = [varargout{1}.other_info.END;{line_number line_content}];
        
        
        % === Unknown line  ===============================================
        
    else
        if strcmp( deblank( line_content ), '' ) == 0
            disp( [ 'Unknown line !!! : ' num2str(line_number) ' ' line_content ] )
        end
    end
    
end

% Closing file
fclose(file_ID);


%% Adjusments of data

if Array_flag || All_flag
    % SAMPLE matrix has been over-dimensioned, now we reduce its size to fit
    % the data
    SAMPLE = SAMPLE(1:sample_count,:);
    SAMPLE_NO_INFO(1:sample_no_info_count,:);
end

if Raw_flag || All_flag
    % Transform into a row
    raw_events = raw_events';
end

if Numeric_flag || All_flag
    
end


%% Output

% Raw
if Raw_flag || All_flag
    varargout{1}.raw_events = raw_events;
end

% Array
if Array_flag || All_flag
    varargout{1}.SAMPLE_row_names  = SAMPLE_row_names;
    varargout{1}.SAMPLE_row_number = SAMPLE_row_number;
    varargout{1}.SAMPLE            = SAMPLE;
    varargout{1}.SAMPLE_NO_INFO    = SAMPLE_NO_INFO;
    varargout{1}.SBLINK            = SBLINK;
    varargout{1}.EBLINK            = EBLINK;
    varargout{1}.SSACC             = SSACC;
    varargout{1}.ESACC             = ESACC;
    varargout{1}.SFIX              = SFIX;
    varargout{1}.EFIX              = EFIX;
    varargout{1}.INPUT             = INPUT;
    varargout{1}.BUTTON            = BUTTON;
end

% Numeric
if Numeric_flag || All_flag
    varargout{1}.Numeric_row_names  = Numeric_row_names;
    varargout{1}.Numeric_row_number = Numeric_row_number;
    varargout{1}.Numeric_events     = Numeric_events;
end

% Estimation of the output memory size
output_variables=whos('varargout');
disp(['Estimated memory size of the output : ' num2str(output_variables.bytes/4/1024/1024) ' Mo'])

end
