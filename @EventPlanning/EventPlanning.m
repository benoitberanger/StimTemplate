classdef EventPlanning < OmniRecorder
    
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
        function self = EventPlanning( header )
            % self = EventRecorder( Header = cell( 1 , Columns ) )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- header ----
                if isvector( header ) && ...
                        iscell( header ) && ...
                        ~isempty( header ) % Check input argument
                    if all( cellfun( @isstr , header ) )
                        self.Header =  header ;
                    else
                        error( 'Header should be a line cell of strings' )
                    end
                else
                    error( 'Header should be a line cell of strings' )
                end
                
            end
            
            % ================== Callback =============================
            
            self.Description = mfilename( 'fullpath' );
            self.Columns     = length( self.Header );
            self.Data        = cell( self.NumberOfEvents , self.Columns );
            
        end
        
    end % methods
    
    
end % class
