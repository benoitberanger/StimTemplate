classdef KbQueueLogger < StimEvents
    
    %KBQUEUELOGGER Class to handle the the Keybinds queue (ex : record MRI
    %triggers while other code is executing)
    
    %% Properties
    
    properties
        
        KbList = [] % == [ KbName('space') KbName('5%') ]
        TR = 0
        Volumes = 0
        
    end % properties
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = KbQueueLogger(kblist,header)
            
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
            
            obj.Data = cell(obj.NumberOfEvents,obj.Columns);
            
        end
        
        % -----------------------------------------------------------------
        %                          Add Start Time
        % -----------------------------------------------------------------
        function AddStartTime(obj,starttime)
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
        % Scale the time origin to the first entry in obj.Data
        function ScaleTime(obj)
            time = cell2mat(obj.Data(:,2));
            obj.Data(:,2) = num2cell(time - time(1));
        end
        
        % -----------------------------------------------------------------
        %                        ComputeDurations
        % -----------------------------------------------------------------
        % Scale the time origin to the first entry in obj.Data
        function ComputeDurations(obj)
            time = cell2mat(obj.Data(:,2));
            obj.Data(1:end-1,4) = num2cell(diff(time));
        end
        
    end % methods
    
    methods ( Static )
        
        % -----------------------------------------------------------------
        %                              Init
        % -----------------------------------------------------------------
        function Init
            KbQueueCreate
            KbQueueStart
        end
        
        % -----------------------------------------------------------------
        %                           Destructor
        % -----------------------------------------------------------------
        % Delete methods are always called before a object
        % of the class is destroyed
        function delete
            KbQueueStop
            KbQueueRelease
        end
        
    end % methods
    
end % class