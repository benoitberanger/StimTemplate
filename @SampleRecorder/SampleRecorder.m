classdef SampleRecorder < Recorder
    %SAMPLERECORDER This class is optimized to store numerical samples.
    % Samples will be stored in a double array, not a cell array (like EventRecorder)
    
    % benoit.beranger@icm-institute.org
    % CENIR-ICM , 2017
    
    
    %% Properties
    
    properties
        
        % See Recorder
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = SampleRecorder( header , numberofevents )
            % self = EventRecorder( Header = cell( 1 , Columns ) , NumberOfEvents = double(positive integer) )
            
            % Usually, first column is the time, and other columns are samples type
            
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
                
                % --- numberofevents ---
                if isnumeric( numberofevents ) && ...
                        numberofevents == round( numberofevents ) && ...
                        numberofevents > 0 % Check input argument
                    self.NumberOfEvents = numberofevents;
                else
                    error( 'NumberOfEvents must be a positive integer' )
                end
                
            end
            
            % ================== Callback =============================
            
            self.Columns     = length( self.Header );
            self.Data        = zeros( self.NumberOfEvents , self.Columns );
            self.Description = mfilename( 'fullpath' );
            
        end % ctor
        
    end % methods
    
    
end % class
