classdef KbLogger < OmniRecorder
    
    %KBLOGGER Class to handle the the Keybinds Queue from Psychtoolbox
    %  (ex : record MRI triggers while other code is executing)
    
    % benoit.beranger@icm-institute.org
    % CENIR-ICM , 2015
    
    
    %% Properties
    
    properties
        
        KbList   = []      % double = [ KbName( 'space' ) KbName( '5%' ) ]
        KbEvents = cell(0) % cell( Columns , 2 )
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = KbLogger( kblist , header )
            % self = KbLogger( KbList = [ KbName( 'space' ) KbName( '5%' ) ] , Header = cell( 1 , Columns ) )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- kblist ----
                if isvector( kblist ) && isnumeric( kblist ) % Check input argument
                    self.KbList = kblist;
                else
                    error( 'KbList should be a line vector of positive integers' )
                end
                
                % --- header ----
                if isvector( header ) && ...
                        iscell( header ) && ...
                        length( kblist ) == length( header ) % Check input argument
                    if all( cellfun( @isstr , header ) )
                        self.Header = header;
                    else
                        error( 'Header should be a line cell of strings' )
                    end
                else
                    error( 'Header should be a line cell of strings and same size as KbList' )
                end
                
            end
            
            % ======================= Callback ============================
            
            self.Description    = mfilename( 'fullpath' );
            self.Columns        = 4;
            self.Data           = cell( self.NumberOfEvents , self.Columns );
            self.KbEvents       = cell( self.Columns , 2 );
            
        end
        
    end % methods
    
    
    methods ( Static )
        
        Stop
        
    end % methods ( Static )
    
    
end % class
