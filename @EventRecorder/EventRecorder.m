classdef EventRecorder < handle
    
    %EVENTRECORDER Class to record any stimulation events
    
    %% Properties
    
    properties
        
        Data           = cell(0)                  % cell( NumberOfEvents , Columns )
        Header         = {''}                     % str : Description of each columns
        Columns        = 0                        % double(positive integer)
        Description    = mfilename( 'fullpath' ); % str : Fullpath of the file
        TimeStamp      = datestr( now );          % str : Time stamp for the creation of object
        NumberOfEvents = 0                        % double(positive integer)
        EventCount     = 0                        % double(positive integer)
        GraphData      = cell(0)                  % cell( 'ev1' curve1 ; 'ev2' curve2 ; ... )
        
    end % properties
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function obj = EventRecorder( header , numberofevents )
            % obj = EventRecorder( Header = cell( 1 , Columns ) , NumberOfEvents = double(positive integer) )
            
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
                        obj.Header =  header ;
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
                    obj.NumberOfEvents = numberofevents;
                else
                    error( 'NumberOfEvents must be a positive integer' )
                end
                
                % ================== Callback =============================
                
                obj.Columns = length( header );
                obj.Data    = cell( numberofevents , obj.Columns );
                
            else
                % Create empty StimEvents
            end
            
        end
        
        % -----------------------------------------------------------------
        %                          Add Start Time
        % -----------------------------------------------------------------
        function AddStartTime( obj,starttime )
            % obj.AddStartTime( StartTime = double )
            %
            % Add special event { 'T_start' starttime }
            
            if isnumeric( starttime )
                obj.IncreaseEventCount;
                obj.Data( obj.EventCount , 1:2 ) = { 'T_start' starttime }; % Add T_start = 0 on the first line
            else
                error( 'StartTime must be numeric' )
            end
            
        end
        
        % -----------------------------------------------------------------
        %                          Add Stop Time
        % -----------------------------------------------------------------
        function AddStopTime( obj , stoptime )
            % obj.AddStopTime( StopTime = double )
            %
            % Add special event { 'T_stop' stoptime }
            
            if isnumeric( stoptime )
                obj.IncreaseEventCount;
                obj.Data( obj.EventCount , 1:2 ) = { 'T_stop' stoptime }; % Add T_stop below the last line
            else
                error( 'StopTime must be numeric' )
            end
            
        end
        
        % -----------------------------------------------------------------
        %                            AddEvent
        % -----------------------------------------------------------------
        function AddEvent( obj , event )
            % obj.AddEvent( cell(1,n) = { 'eventName' data1 date2 ... } )
            %
            % Add event, according to the dimensions given by the Header
            
            if length( event ) == obj.Columns % Check input arguments
                if iscolumn( event )
                    event = event';
                end
                obj.IncreaseEventCount;
                obj.Data( obj.EventCount , : ) = event;
            else
                error( 'Wrong number of arguments' )
            end
            
        end
        
        % -----------------------------------------------------------------
        %                        IncreaseEventCount
        % -----------------------------------------------------------------
        function IncreaseEventCount( obj )
            % obj.IncreaseEventCount()
            %
            % Method used by other methods of the class. Usually, it's not
            % used from outside of the class.
            
            obj.EventCount = obj.EventCount + 1;
            
        end
        
        % -----------------------------------------------------------------
        %                         ClearEmptyEvents
        % -----------------------------------------------------------------
        function ClearEmptyEvents( obj )
            % obj.ClearEmptyEvents()
            %
            % Delete empty rows. Useful when NumberOfEvents is not known
            % precisey but set to a great value (better for prealocating
            % memory).
            
            empty_idx = cellfun( @isempty , obj.Data(:,1) );
            obj.Data( empty_idx , : ) = [];
        end
        
        % -----------------------------------------------------------------
        %                          ExportToStructure
        % -----------------------------------------------------------------
        function savestruct = ExportToStructure( obj )
            % StructureToSave = obj.ExportToStructure()
            %
            % Export all proporties of the object into a structure, so it
            % can be saved.
            % WARNING : it does not save the methods, just transform the
            % object into a common structure.
            ListProperties = properties(obj);
            for prop_number = 1:length(ListProperties)
                savestruct.(ListProperties{prop_number}) = obj.(ListProperties{prop_number});
            end
        end
        
        % -----------------------------------------------------------------
        %                             BuildGraph
        % -----------------------------------------------------------------
        function BuildGraph( obj )
            % obj.BuildGraph()
            %
            % Build curves for each events, ready to be plotted.
            
            % ===================== Regroup each event ====================
            
            [event_name,~,idx_event2data] = unique(obj.Data(:,1),'stable');
            
            % Col 1 : event_name
            % Col 2 : obj.Data(event_name)
            % Col 3 ~= obj.Data(event_name), adapted for plot
            obj.GraphData = cell(length(event_name),3);
            
            for e = 1:length(event_name)
                obj.GraphData{e,1} = event_name{e};
                obj.GraphData{e,2} = cell2mat ( obj.Data( idx_event2data == e , 2 ) );
            end
            
            % ================= Build curves for each Event ===============
            
            for e = 1 : size( obj.GraphData , 1 ) % For each Event
                
                data = [ obj.GraphData{e,2} ones(size(obj.GraphData{e,2},1),1) ]; % Catch data for this Event
                
                N  = size( data , 1 ); % Number of data = UP(0) + DOWN(1)
                
                % Here we need to build a curve that looks like recangles
                for n = N:-1:1
                    
                    % Split data above & under the point
                    dataABOVE = data( 1:n ,: );
                    dataUNDER = data( n+1:end , : );
                    
                    % Add a point in curve to build a rectangle
                    data  = [ ...
                        dataABOVE ; ...
                        dataABOVE(end,1) 0 ; ...
                        dataABOVE(end,1) NaN ; ...
                        dataUNDER ...
                        ] ;
                    
                end
                
                % Store curves
                obj.GraphData{e,3} = data;
                
            end
            
        end
        
        
        % -----------------------------------------------------------------
        %                               Plot
        % -----------------------------------------------------------------
        function Plot( obj )
            % obj.Plot( display_method = '+' OR '*' )
            %
            % Plot events over the time.
            
            % =============== BuildGraph if necessary =====================
            
            % Each subclass has its own BuildGraph method because Data
            % properties are different. But each BuildGraph subclass method
            % converge to a uniform GraphData.
            
            if isempty(obj.GraphData)
                
                obj.BuildGraph;
                
            end
            
            % ======================== Plot ===============================
            
            % Catch caller object
            [~, name, ~] = fileparts(obj.Description);
            
            % Depending on the object calling the method, the display changes.
            switch name
                
                case 'EventRecorder'
                    display_method = '+';
                    
                case 'KbLogger'
                    display_method = '*';
                    
                case 'EventPlanning'
                    display_method = '+';
                    
                otherwise
                    error('Unknown object caller')
                    
            end
            
            % Figure
            figure( 'Name' , [ inputname(1) ' : ' name ] , 'NumberTitle' , 'off' )
            hold all
            
            % For each Event, plot the curve
            for e = 1 : size( obj.GraphData , 1 )
                
                if ~isempty(obj.GraphData{e,3})
                    
                    switch display_method
                        
                        case '+'
                            plot( obj.GraphData{e,3}(:,1) , obj.GraphData{e,3}(:,2) + e )
                            
                        case '*'
                            plot( obj.GraphData{e,3}(:,1) , obj.GraphData{e,3}(:,2) * e )
                            
                        otherwise
                            error('Unknown display_method')
                    end
                    
                else
                    
                    plot(0,NaN)
                    
                end
                
            end
            
            % Legend
            lgd = legend( obj.GraphData(:,1) );
            set(lgd,'Interpreter','none')
            
            % ================ Adapt the graph axes limits ================
            
            % Change the limit of the graph so we can clearly see the
            % rectangles.
            
            scale = 1.1;
            
            old_xlim = xlim;
            range_x  = old_xlim(2) - old_xlim(1);
            center_x = mean( old_xlim );
            new_xlim = [ (center_x - range_x*scale/2 ) center_x + range_x*scale/2 ];
            
            old_ylim = ylim;
            range_y  = old_ylim(2) - old_ylim(1);
            center_y = mean( old_ylim );
            new_ylim = [ ( center_y - range_y*scale/2 ) center_y + range_y*scale/2 ];
            
            % Set new limits
            xlim( new_xlim )
            ylim( new_ylim )
            
        end
        
    end % methods
    
end % class