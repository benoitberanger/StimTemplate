classdef StimEvents < handle
    
    %STIMCELL Class to handle the stimulation events
    
    %% Properties
    
    properties
        
        Data = cell(0)
        Header = {''}
        Columns = 0
        Description = ''
        
    end
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = StimEvents( header )
            if nargin > 0 % arguments ?
                if iscell(header) && size(header,1) == 1 && size(header,2) > 0 % Check input argument
                    if all(cellfun(@isstr,header))
                        obj.Header = header;
                    else
                        error('Header should be a line cell of strings')
                    end
                else
                    error('Header should be a line cell of strings')
                end
                obj.Columns = size(header,2);
                obj.Data    = cell(1,obj.Columns);
            end
        end
        
        % -----------------------------------------------------------------
        %                          Add start time
        % -----------------------------------------------------------------
        function AddStartTime(obj)
            obj.Data(1,1:2) = {'T_start' 0}; % Add T_start = 0 on the first line
        end
        
        % -----------------------------------------------------------------
        %                          Add stop time
        % -----------------------------------------------------------------
        function obj = AddStopTime(obj,StopTime)
            if isnumeric(StopTime)
                obj.Data(end+1,1:2) = {'T_stop' StopTime}; % Add T_stop below the last line
            else
                error('StopTime must be numeric')
            end
        end
        
        % -----------------------------------------------------------------
        %                          Add Event
        % -----------------------------------------------------------------
        function obj = AddEvent(obj,varargin)
            if length(varargin{:}) == obj.Columns % Check input arguments
                obj.Data(end+1,:) = varargin{:};
            else
                error('Wrong number of arguments')
            end
        end
        
    end
    
end
