classdef StimEvents < handle
    
    %STIMCELL Class to handle the stimulation events
    
    %% Properties
    
    properties
        
        Data = cell(0)
        Header = {''}
        Columns = 0
        Description = ''
        NumberOfEvents = 0
        EventCount = 0
        
    end
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = StimEvents( header , numberofevents )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
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
                
                % --- numberofevents ---
                if isnumeric(numberofevents) && ...
                    numberofevents == round(numberofevents) && ...
                    numberofevents > 0 % Check input argument
                    obj.NumberOfEvents = numberofevents;
                else
                    error('NumberOfEvents must be a positive integer')
                end
                
                % ================== Callback =============================
                
                obj.Columns = size(header,2);
                obj.Data    = cell(numberofevents,obj.Columns);
            else
                % Create empty StimEvents
            end
        end
        
        % -----------------------------------------------------------------
        %                          Add start time
        % -----------------------------------------------------------------
        function AddStartTime(obj)
            IncreaseEventCount(obj)
            obj.Data(obj.EventCount,1:2) = {'T_start' 0}; % Add T_start = 0 on the first line
        end
        
        % -----------------------------------------------------------------
        %                          Add stop time
        % -----------------------------------------------------------------
        function obj = AddStopTime(obj,StopTime)
            if isnumeric(StopTime)
                IncreaseEventCount(obj)
                obj.Data(obj.EventCount,1:2) = {'T_stop' StopTime}; % Add T_stop below the last line
            else
                error('StopTime must be numeric')
            end
        end
        
        % -----------------------------------------------------------------
        %                          Add Event
        % -----------------------------------------------------------------
        function obj = AddEvent(obj,varargin)
            
            if length(varargin{:}) == obj.Columns % Check input arguments
                IncreaseEventCount(obj)
                obj.Data(obj.EventCount,:) = varargin{:};
            else
                error('Wrong number of arguments')
            end
            
        end
        
        % -----------------------------------------------------------------
        %                      IncreaseEventCount
        % -----------------------------------------------------------------
        function IncreaseEventCount(obj)
            obj.EventCount = obj.EventCount + 1;
        end
        
    end
    
end
