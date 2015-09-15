classdef KbQueueLogger < StimEvents
    
    %KBQUEUELOGGER Class to handle the the Keybinds queue (ex : record MRI
    %triggers while other code is executing)
    
    %% Properties
    
    properties
        
        KbList   = []      % double = [ KbName('space') KbName('5%') ]
        TR       = 0       % double(positive)
        Volumes  = 0       % double(positive integer)
        KbEvents = cell(0) % cell(Columns,2)
        
    end % properties
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = KbQueueLogger(kblist,header)
            % obj = KbQueueLogger( KbList = [ KbName('space') KbName('5%')
            % ] , Header = cell(1,Columns) )
            
            obj.Description = mfilename;
            obj.Columns = 3;
            
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
                if iscell(header) && size(header,1) == 1 && size(header,2) > 0 % Check input argument
                    if all(cellfun(@isstr,header))
                        obj.Header = header;
                    else
                        error('Header should be a line cell of strings')
                    end
                else
                    error('Header should be a line cell of strings')
                end
                
            else
                % Create empty KbQueueLogger
            end
            
            % ================== Callback =============================
            
            obj.Data     = cell(obj.NumberOfEvents,obj.Columns);
            obj.KbEvents = cell(obj.Columns,2);
            
        end
        
        % -----------------------------------------------------------------
        %                          Add Start Time
        % -----------------------------------------------------------------
        function AddStartTime(obj,starttime)
            % obj.AddStartTime( StartTime = double )
            
            if isnumeric(starttime)
                IncreaseEventCount(obj)
                obj.Data(obj.EventCount,1:2) = {'T_start' starttime}; % Add T_start = 0 on the first line
            else
                error('StartTime must be numeric')
            end
            
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
            obj.Data(:,2) = num2cell(time - time(1));
            
        end
        
        % -----------------------------------------------------------------
        %                        ComputeDurations
        % -----------------------------------------------------------------
        function ComputeDurations(obj)
            % obj.ComputeDurations()
            %
            % Compute durations for each keybinds
            
            KbEvents = cell(length(obj.Header),2);
            
            % Create list for each KeyBind
            
            [C,~,ic] = unique(obj.Data(:,1),'first'); % Filter each Kb
            
            count = 0;
            
            for c = 1:length(C)
                
                count = count + 1;
                
                KbEvents{count,1}= C{c};                  % Name of KeyBind
                KbEvents{count,2}= obj.Data(ic == c,2:3); % Time & Up/Down of Keybind
                
            end
            
            % Compute the difference between each time
            for e = 1:size(KbEvents,1)
                
                if size(KbEvents{e,2},1) > 1
                    
                    time = cell2mat(KbEvents{e,2}(:,1));                 % Get the times
                    KbEvents{e,2}(1:end-1,end+1) = num2cell(diff(time)); % Compute the differences
                    
                end
                
            end
            
            obj.KbEvents = KbEvents;
            
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