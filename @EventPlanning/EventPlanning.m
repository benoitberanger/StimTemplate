classdef EventPlanning < EventRecorder
    
    %EVENTPLANNING Class to schedul any stimulation events
    
    %% Properties
    
    properties
        
    end % properties
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = EventPlanning( header )
           % obj = EventRecorder( Header = cell( 1 , Columns ) ,
            % NumberOfEvents = double(positive integer) )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- header ----
                if isvector( header ) && ...
                        iscell( header ) && ...
                        ~isempty( header ) % Check input argument
                    if all( cellfun( @isstr , header ) )
                        obj.Header =  header ;
                    else
                        error( 'Header should be a line cell of strings' )
                    end
                else
                    error( 'Header should be a line cell of strings' )
                end

                % ================== Callback =============================
                
                obj.Columns        = length( header );
                obj.Data           = cell( 0 , obj.Columns );
                obj.Description    = mfilename( 'fullpath' );
                obj.TimeStamp      = datestr( now );
            
            else
                % Create empty StimEvents
            end
            
        end
        
        % -----------------------------------------------------------------
        %                            AddPlanning
        % -----------------------------------------------------------------
        function AddPlanning( obj , planning )
            % obj.AddPlanning( cell(1,n) = { 'eventName' onset date ... } )
            %
            % Add planning, according to the dimensions given by the Header
            
            if iscell(planning) && size( planning , 2 ) == obj.Columns % Check input arguments
                obj.EventCount = obj.EventCount + size( planning , 1 );
                obj.Data = [ obj.Data ; planning ]; % == vertical concatenation
            else
                error( 'Wrong number of arguments' )
            end
            
        end
        
    end % methods
    
end % class