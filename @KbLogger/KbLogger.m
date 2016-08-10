classdef KbLogger < EventRecorder
    
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
        function obj = KbLogger( kblist , header )
            % obj = KbLogger( KbList = [ KbName( 'space' ) KbName( '5%' ) ] , Header = cell( 1 , Columns ) )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- kblist ----
                if isvector( kblist ) && isnumeric( kblist ) % Check input argument
                    obj.KbList = kblist;
                else
                    error( 'KbList should be a line vector of positive integers' )
                end
                
                % --- header ----
                if isvector( header ) && ...
                        iscell( header ) && ...
                        length( kblist ) == length( header ) % Check input argument
                    if all( cellfun( @isstr , header ) )
                        obj.Header = header;
                    else
                        error( 'Header should be a line cell of strings' )
                    end
                else
                    error( 'Header should be a line cell of strings and same size as KbList' )
                end
                
            else
                % Create empty KbQueueLogger
            end
            
            % ======================= Callback ============================
            
            obj.Description    = mfilename( 'fullpath' );
            obj.TimeStamp      = datestr( now );
            obj.Columns        = 4;
            obj.Data           = cell( obj.NumberOfEvents , obj.Columns );
            obj.KbEvents       = cell( obj.Columns , 2 );
            obj.NumberOfEvents = NaN;
            
        end
        
    end % methods
    
    
    methods ( Static )
        
        Stop
        
    end % methods ( Static )
    
    
end % class
