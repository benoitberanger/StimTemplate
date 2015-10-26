classdef KbQueueLogger < EventRecorder
    
    %KBQUEUELOGGER Class to handle the the Keybinds Queue from Psychtoolbox
    %(ex : record MRI triggers while other code is executing)
    
    %% Properties
    
    properties
        
        KbList   = []      % double = [ KbName('space') KbName('5%') ]
        %         TR       = 0       % double(positive) Volumes  = 0
        %         % double(positive integer)
        KbEvents = cell(0) % cell(Columns,2)
        
    end % properties
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = KbQueueLogger(kblist,header)
            % obj = KbQueueLogger( KbList = [ KbName('space') KbName('5%')]
            % , Header = cell(1,Columns) )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- kblist ----
                if isvector(kblist) && isnumeric(kblist) % Check input argument
                    obj.KbList = kblist;
                else
                    error('Header should be a line cell of strings')
                end
                
                % --- header ----
                if isvector(header) && ...
                        iscell(header) && ...
                        length(kblist) == length(header) % Check input argument
                    if all(cellfun(@isstr,header))
                        obj.Header = header;
                    else
                        error('Header should be a line cell of strings')
                    end
                else
                    error('Header should be a line cell of strings and same size as KbList')
                end
                
            else
                % Create empty KbQueueLogger
            end
            
            % ======================= Callback ============================
            
            obj.Description    = mfilename('fullpath');
            obj.TimeStamp      = datestr(now);
            obj.Columns        = 3;
            obj.Data           = cell(obj.NumberOfEvents,obj.Columns);
            obj.KbEvents       = cell(obj.Columns,2);
            obj.NumberOfEvents = NaN;
            
        end
        
        % -----------------------------------------------------------------
        %                            GetQueue
        % -----------------------------------------------------------------
        function GetQueue(obj)
            % obj.GetQueue()
            %
            % Fetch the queue and use AddEvent method to fill obj.Data
            % according to the KbList
            
            while KbEventAvail
                [evt, ~] = KbEventGet; % Get all queued keys
                if any( evt.Keycode == obj.KbList )
                    key_idx = evt.Keycode == obj.KbList;
                    obj.AddEvent( { obj.Header{key_idx} evt.Time evt.Pressed } )
                end
            end
            
        end
        
        % -----------------------------------------------------------------
        %                           Scale Time
        % -----------------------------------------------------------------
        function ScaleTime(obj)
            % obj.ScaleTime()
            %
            % Scale the time origin to the first entry in obj.Data
            
            time = cell2mat(obj.Data(:,2));
            
            if ~isempty(time)
                obj.Data(:,2) = num2cell(time - time(1));
            else
                warning('KbQueueLogger:ScaleTime','No data in obj.Data')
            end
            
        end
        
        % -----------------------------------------------------------------
        %                        ComputeDurations
        % -----------------------------------------------------------------
        function ComputeDurations(obj)
            % obj.ComputeDurations()
            %
            % Compute durations for each keybinds
            
            kbevents = cell(length(obj.Header),2);
            
            % Take out T_start and T_stop from Data
            
            T_start_idx = strcmp(obj.Data(:,1),'T_start');
            T_stop_idx = strcmp(obj.Data(:,1),'T_stop');
            
            data = obj.Data( ~(T_start_idx + T_stop_idx) ,:);
            
            % Create list for each KeyBind
            
            [C,~,ic] = unique(data(:,1),'first'); % Filter each Kb
            
            [~,ia_,~] = intersect(obj.Header,C,'stable');
            
            kbevents(:,1)= obj.Header; % Name of KeyBind
            
            count = 0;
            
            for c = 1:length(C)
                
                count = count + 1;
                
                kbevents{ia_(count),2}= data(ic == c,2:3); % Time & Up/Down of Keybind
                
            end
            
            % Compute the difference between each time
            for e = 1:size(kbevents,1)
                
                if size(kbevents{e,2},1) > 1
                    
                    time = cell2mat(kbevents{e,2}(:,1));                 % Get the times
                    kbevents{e,2}(1:end-1,end+1) = num2cell(diff(time)); % Compute the differences
                    
                end
                
            end
            
            obj.KbEvents = kbevents;
            
        end
        
        % -----------------------------------------------------------------
        %                          PlotKbEvents
        % -----------------------------------------------------------------
        function PlotKbEvents(obj)
            % obj.PlotKbEvents()
            
            % ================== Build rectangles =========================
            
            for k = 1:size(obj.KbEvents,1) % For each KeyBinds
                
                if ~isempty(obj.KbEvents{k,2}) % Except for null (usually the last one)
                    
                    data = cell2mat(obj.KbEvents{k,2}(:,1:2)); % Catch data for this Keybind
                    
                    N  = size(data,1); % Number of data = UP(0) + DOWN(1)
                    
                    % Here we need to build a curve that looks like
                    % recangles
                    for n = N:-1:1
                        
                        % % Split data above & under the point
                        dataABOVE = data(1:n-1,:);
                        dataUNDER = data(n:end,:);
                        
                        % Add a point ine curve to build a rectangle
                        switch data(n,2)
                            case 0
                                data  = [ dataABOVE ; dataUNDER(1,1) 1 ; dataUNDER ] ;
                            case 1
                                data  = [ dataABOVE ; dataUNDER(1,1) 0 ; dataUNDER ] ;
                            otherwise
                                disp('bug')
                        end
                        
                    end
                    
                    obj.KbEvents{k,3} = data;
                    
                end
                
            end
            
            % ======================== Plot ===============================
            
            figure('Name',[ mfilename ' : ' inputname(1)],'NumberTitle','off')
            hold all
            
            for k = 1:size(obj.KbEvents,1)
                
                if ~isempty(obj.KbEvents{k,2})
                    
                    plot(obj.KbEvents{k,3}(:,1),obj.KbEvents{k,3}(:,2)*k)
                    
                else
                    
                    plot(0,0)
                    
                end
                
            end
            
            legend(obj.Header{:})
            
            old_xlim = xlim;
            range_x = old_xlim(2)-old_xlim(1);
            center_x = mean(old_xlim);
            new_xlim = [ (center_x - range_x*1.1/2 ) center_x + range_x*1.1/2 ];
            
            old_ylim = ylim;
            range_y = old_ylim(2)-old_ylim(1);
            center_y = mean(old_ylim);
            new_ylim = [ (center_y - range_y*1.1/2 ) center_y + range_y*1.1/2 ];
            
            xlim(new_xlim)
            ylim(new_ylim)
            
        end
        
    end % methods
    
    methods ( Static )
        
        % -----------------------------------------------------------------
        %                              Init
        % -----------------------------------------------------------------
        function Init
            % obj.Init()
            
            KbQueueCreate
            KbQueueStart
            
        end
        
        % -----------------------------------------------------------------
        %                           Destructor
        % -----------------------------------------------------------------
        function delete
            % obj.delete()
            %
            % Delete methods are always called before a object of the class
            % is destroyed
            
            KbQueueStop
            KbQueueRelease
            
        end
        
    end % methods
    
end % class