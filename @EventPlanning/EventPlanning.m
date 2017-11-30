classdef EventPlanning < Recorder
    
    %EVENTPLANNING Class to schedul any stimulation events
    
    % benoit.beranger@icm-institute.org
    % CENIR-ICM , 2015
    
    
    %% Properties
    
    properties
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = EventPlanning( header )
            % obj = EventRecorder( Header = cell( 1 , Columns ) )
            
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
                
            else % Create empty StimEvents
                obj.Header = {};
            end
            
            % ================== Callback =============================
            
            obj.Description = mfilename( 'fullpath' );
            obj.TimeStamp   = datestr( now );
            obj.Columns     = length( obj.Header );
            obj.Data        = cell( 0 , obj.Columns );
            
        end
        
    end % methods
    
    
end % class
