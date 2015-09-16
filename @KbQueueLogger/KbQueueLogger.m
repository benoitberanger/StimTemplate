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
            
            % ======================= Callback ============================
            
            obj.Description = mfilename;
            obj.Columns = 3;
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
            
            % Create list for each KeyBind
            
            [C,~,ic] = unique(obj.Data(:,1),'first'); % Filter each Kb
            
            [~,ia_,~] = intersect(obj.Header,C,'stable');
            
            kbevents(:,1)= obj.Header; % Name of KeyBind
            
            count = 0;
            
            for c = 1:length(C)
                
                count = count + 1;
                
                kbevents{ia_(count),2}= obj.Data(ic == c,2:3); % Time & Up/Down of Keybind
                
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
            
            for k = 1:size(obj.KbEvents,1)
                
                if ~isempty(obj.KbEvents{k,2})
                    
                    data = cell2mat(obj.KbEvents{k,2}(:,1:2));
                    
                    N  = size(data,1);
                    
                    for n = N:-1:1
                        
                        dataUP = data(1:n-1,:);
                        dataDOWN = data(n:end,:);
                        
                        if data(n,2) == 0
                            data  = [ dataUP ; dataDOWN(1,1) 1 ; dataDOWN ] ;
                        elseif data(n,2) == 1
                            data  = [ dataUP ; dataDOWN(1,1) 0 ; dataDOWN ] ;
                        else
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