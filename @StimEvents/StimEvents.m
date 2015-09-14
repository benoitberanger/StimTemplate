classdef StimEvents < handle
    
    %STIMCELL Class to handle the stimulation events
    
    %% Properties
    
    properties
        
        Data = cell(0)
        Header = {''} % Description of each columns
        Columns = 0
        Description = mfilename
        NumberOfEvents = 0
        EventCount = 0
        
    end % properties
    
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
        %                          Add Start Time
        % -----------------------------------------------------------------
        function AddStartTime(obj)
            IncreaseEventCount(obj)
            obj.Data(obj.EventCount,1:2) = {'T_start' 0}; % Add T_start = 0 on the first line
        end
        
        % -----------------------------------------------------------------
        %                          Add Stop Time
        % -----------------------------------------------------------------
        function AddStopTime(obj,stoptime)
            if isnumeric(stoptime)
                IncreaseEventCount(obj)
                obj.Data(obj.EventCount,1:2) = {'T_stop' stoptime}; % Add T_stop below the last line
            else
                error('StopTime must be numeric')
            end
        end
        
        % -----------------------------------------------------------------
        %                            Add Event
        % -----------------------------------------------------------------
        % obj.AddEvent( {'eventName' data1 date2 ...} )
        function AddEvent(obj,varargin)
            
            if length(varargin{:}) == obj.Columns % Check input arguments
                IncreaseEventCount(obj)
                obj.Data(obj.EventCount,:) = varargin{:};
            else
                error('Wrong number of arguments')
            end
            
        end
        
        % -----------------------------------------------------------------
        %                        IncreaseEventCount
        % -----------------------------------------------------------------
        function IncreaseEventCount(obj)
            obj.EventCount = obj.EventCount + 1;
        end
        
        % -----------------------------------------------------------------
        %                         ClearEmptyEvents
        % -----------------------------------------------------------------
        % Delete empty rows. Useful when NumberOfEvents is not known
        % precisey but set to a great value (better for prealocating
        % memory).
        function ClearEmptyEvents(obj)
            empty_idx = cellfun(@isempty, obj.Data(:,1));
            obj.Data(empty_idx,:) = [];
        end
        
    end % methods
    
end % class