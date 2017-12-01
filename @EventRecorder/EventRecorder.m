classdef EventRecorder < OmniRecorder
    %EVENTRECORDER Class to record any stimulation events
    
    % benoit.beranger@icm-institute.org
    % CENIR-ICM , 2015
    
    
    %% Properties
    
    properties
        
        BlockData      = cell(0) % cell( ? , Columns )
        BlockGraphData = cell(0) % cell( ? , Columns )
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = EventRecorder( header , numberofevents )
            % self = EventRecorder( Header = cell( 1 , Columns ) , NumberOfEvents = double(positive integer) )
            
            % Usually, first column is the event name, and second column is
            % it's onset.
            
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
            
            self.Description = mfilename( 'fullpath' );
            self.Columns     = length( self.Header );
            self.Data        = cell( self.NumberOfEvents , self.Columns );
            
        end
        
        
        %         % -----------------------------------------------------------------
        %         %                             saveobj
        %         % -----------------------------------------------------------------
        %         function s = saveobj(self)
        %
        %             s = struct; % Create a sctructure
        %             props = properties(self);
        %             for p = 1:numel(props)
        %                 s.(props{p})=self.(props{p}); % Fill the structer with the object properties
        %             end
        %
        %         end
        
    end % methods
    
    %     methods ( Static )
    %
    %         % -----------------------------------------------------------------
    %         %                             loadobj
    %         % -----------------------------------------------------------------
    %         function self = loadobj(s)
    %
    %             if isstruct(s) % if the object was saved as a structure
    %
    %                 % Fetch class name
    %                 [~, classsName, ~] = fileparts(s.Description);
    %
    %                 newObj = feval(str2func(classsName)); % Create an empty instance
    %                 props = properties(newObj);
    %                 for p = 1:numel(props)
    %                     try
    %                         newObj.(props{p})=s.(props{p}); % Fill the instance
    %                     catch err
    %                         warning(err.message)
    %                     end
    %                 end
    %                 self = newObj; % Assign the pointer
    %
    %             else % if the object was saved as an object
    %
    %                 self = s;
    %
    %             end
    %
    %         end
    %
    %     end % methods ( Static )
    
end % class
