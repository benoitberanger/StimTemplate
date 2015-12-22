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
            % obj.AddPlanning( cell(1,n) = { 'eventName' onset duration ... } )
            %
            % Add planning, according to the dimensions given by the Header
            
            if iscell(planning) && size( planning , 2 ) == obj.Columns % Check input arguments
                obj.EventCount = obj.EventCount + size( planning , 1 );
                obj.Data = [ obj.Data ; planning ]; % == vertical concatenation
            else
                error( 'Wrong number of arguments' )
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
        
    end % methods
    
end % class