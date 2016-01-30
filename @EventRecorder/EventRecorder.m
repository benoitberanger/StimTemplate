classdef EventRecorder < handle
    
    %EVENTRECORDER Class to record any stimulation events
    
    %% Properties
    
    properties
        
        Data           = cell(0)                 % cell( NumberOfEvents , Columns )
        Header         = {''}                    % str : Description of each columns
        Columns        = 0                       % double(positive integer)
        Description    = mfilename( 'fullpath' ) % str : Fullpath of the file
        TimeStamp      = datestr( now )          % str : Time stamp for the creation of object
        NumberOfEvents = 0                       % double(positive integer)
        EventCount     = 0                       % double(positive integer)
        GraphData      = cell(0)                 % cell( 'ev1' curve1 ; 'ev2' curve2 ; ... )
        
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
        function AddStartTime( obj, starttime_name , starttime )
            % obj.AddStartTime( StartTime_name = str , StartTime = double )
            %
            % Add special event { StartTime_name starttime }
            
            if ~ischar( starttime_name )
                error( 'StartTime_name must be string' )
            end
            
            if ~isnumeric( starttime )
                error( 'StartTime must be numeric' )
            end
            
            obj.IncreaseEventCount;
            obj.Data( obj.EventCount , 1:2 ) = { starttime_name starttime };
            % ex : Add T_start = 0 on the next line (usually first line)
            
        end
        
        % -----------------------------------------------------------------
        %                          Add Stop Time
        % -----------------------------------------------------------------
        function AddStopTime( obj, stoptime_name , starttime )
            % obj.AddStartTime( StopTime_name = str , StartTime = double )
            %
            % Add special event { StopTime_name starttime }
            
            if ~ischar( stoptime_name )
                error( 'StopTime_name must be string' )
            end
            
            if ~isnumeric( starttime )
                error( 'StopTime must be numeric' )
            end
            
            obj.IncreaseEventCount;
            obj.Data( obj.EventCount , 1:2 ) = { stoptime_name starttime };
            % ex : Add T_stop = 0 on the next line (usually last line)
            
        end
        
        % -----------------------------------------------------------------
        %                            AddEvent
        % -----------------------------------------------------------------
        function AddEvent( obj , event )
            % obj.AddEvent( cell(1,n) = { 'eventName' data1 date2 ... } )
            %
            % Add event, according to the dimensions given by the Header
            
            if length( event ) == obj.Columns % Check input arguments
                if size( event , 1 ) > 0 && size( event , 2 ) == 1 % if iscolumn( event )
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
        %                             Scale Time
        % -----------------------------------------------------------------
        function ScaleTime( obj )
            % obj.ScaleTime()
            %
            % Scale the time origin to the first entry in obj.Data
            
            % Fetch caller object
            [~, name, ~] = fileparts(obj.Description);
            
            % Onsets of events
            time = cell2mat( obj.Data( : , 2 ) );
            
            % Depending on the object calling the method, the display changes.
            switch name
                
                case 'EventRecorder'
                    column_to_write_scaled_onsets = 2;
                    
                case 'KbLogger'
                    column_to_write_scaled_onsets = 4;
                    
                case 'EventPlanning'
                    column_to_write_scaled_onsets = 2;
                    
                otherwise
                    error('Unknown object caller')
                    
            end
            
            % Write scaled time
            if ~isempty( time )
                obj.Data( : , column_to_write_scaled_onsets ) = num2cell( time - time(1) );
            else
                warning( 'EventRecorder:ScaleTime' , 'No data in %s.Data' , inputname(1) )
            end
            
        end
        
        % -----------------------------------------------------------------
        %                        ComputeDurations
        % -----------------------------------------------------------------
        function ComputeDurations( obj )
            % obj.ComputeDurations()
            %
            % Compute durations for each onsets
            
            onsets              = cell2mat( obj.Data (:,2) ); % Get the times
            duration            = diff(onsets);               % Compute the differences
            obj.Data(1:end-1,3) = num2cell( duration );       % Save durations
            
            % For the last event, usually StopTime, we need an exception.
            if strcmp( obj.Data{end,1} , 'StopTime' )
                obj.Data{end,3} = 0;
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
            
            [ event_name , ~ , idx_event2data ] = unique_stable(obj.Data(:,1));
            
            % Col 1 : event_name
            % Col 2 : obj.Data(event_name)
            %Col 3 ~= obj.Data(event_name), adapted for plot
            obj.GraphData = cell(length(event_name),3);
            
            for e = 1:length(event_name)
                obj.GraphData{e,1} = event_name{e};
                obj.GraphData{e,2} = cell2mat ( obj.Data( idx_event2data == e , 2:3 ) );
            end
            
            % ================= Build curves for each Event ===============
            
            for e = 1 : size( obj.GraphData , 1 ) % For each Event
                
                data = [ obj.GraphData{e,2} ones(size(obj.GraphData{e,2},1),1) ]; % Catch data for this Event
                
                N  = size( data , 1 ); % Number of data = UP(0) + DOWN(1)
                
                % Here we need to build a curve that looks like recangles
                for n = N:-1:1
                    
                    switch n
                        
                        case N
                            
                            % Split data above & under the point
                            dataABOVE  = data( 1:n-1 ,: );
                            dataMIDDLE = data( n ,: );
                            dataUNDER  = NaN( 1 , size(data,2) );
                            
                        case 1
                            
                            % Split data above & under the point
                            dataABOVE  = data( 1:n-1 ,: );
                            dataMIDDLE = data( n ,: );
                            dataUNDER  = data( n+1:end , : );
                            
                        otherwise
                            
                            % Split data above & under the point
                            dataABOVE  = data( 1:n-1 ,: );
                            dataMIDDLE = data( n ,: );
                            dataUNDER  = data( n+1:end , : );
                            
                    end
                    
                    % Add a point ine curve to build a rectangle
                    data  = [ ...
                        
                    dataABOVE ;...
                    
                    % Add points to create a rectangle
                    dataMIDDLE(1,1) NaN NaN ;...
                    dataMIDDLE(1,1) NaN 0 ;...
                    dataMIDDLE(1,:) ;...
                    dataMIDDLE(1,1)+dataMIDDLE(1,2) NaN 1 ;...
                    dataMIDDLE(1,1)+dataMIDDLE(1,2) NaN 0 ;...
                    
                    dataUNDER ...
                    
                    ] ;
                
                end
                
                % Delete second column
                data(:,2) = [];
                
                % Store curves
                obj.GraphData{e,3} = data;
                
            end
            
        end
        
        % -----------------------------------------------------------------
        %                               Plot
        % -----------------------------------------------------------------
        function Plot( obj )
            % obj.Plot()
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
            figure( ...
                'Name'        , [ inputname(1) ' : ' name ] , ...
                'NumberTitle' , 'off'                       , ...
                'Units'       , 'Normalized'                , ...
                'Position'    , [0.05, 0.05, 0.90, 0.80]      ...
                )
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
%             set(lgd,'Interpreter','none')
            set(lgd,'Interpreter','none','Location','Best')
            
            % ================ Adapt the graph axes limits ================
            
            % Change the limit of the graph so we can clearly see the
            % rectangles.
            
            ScaleAxisLimits( gca , 1.1 )
            
            % ================ Change YTick and YTickLabel ================
            
            % Put 1 tick in the middle of each event
            switch display_method
                case '+'
                    set( gca , 'YTick' , (1:size( obj.GraphData , 1 ))+0.5 )
                case '*'
                    set( gca , 'YTick' , (1:size( obj.GraphData , 1 )) )
            end
            
            % Set the tick label to the event name
            set( gca , 'YTickLabel' , obj.GraphData(:,1) )
            
        end
        
    end % methods
    
end % class