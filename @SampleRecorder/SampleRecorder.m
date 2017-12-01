classdef SampleRecorder < BasicObject
    %SAMPLERECORDER This class is optimized to store numerical samples.
    % Samples will be stored in a double array, not a cell array (like EventRecorder)
    
    % benoit.beranger@icm-institute.org
    % CENIR-ICM , 2017
    
    
    %% Properties
    
    properties
        
        Data            = zeros(0) % zeros( NumberOfSamples , Columns )
        Columns         = 0        % double(positive integer)
        NumberOfSamples = 0        % double(positive integer)
        SampleCount     = 0        % double(positive integer)
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = SampleRecorder( header , numberofsamples )
            % self = EventRecorder( Header = cell( 1 , Columns ) , NumberOfSamples = double(positive integer) )
            
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
                if isnumeric( numberofsamples ) && ...
                        numberofsamples == round( numberofsamples ) && ...
                        numberofsamples > 0 % Check input argument
                    self.NumberOfSamples = numberofsamples;
                else
                    error( 'NumberOfEvents must be a positive integer' )
                end
                
            end
            
            % ================== Callback =============================
            
            self.Description = mfilename( 'fullpath' );
            self.Columns     = length( self.Header );
            self.Data        = zeros( self.NumberOfSamples , self.Columns );
            
        end % ctor
        
    end % methods
    
    
end % class
