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
            % obj = EventRecorder( Header = cell( 1 , Columns ) ,
            % NumberOfEvents = double(positive integer) )
            
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
            % obj.AddPlanning( cell(1,n) = { 'eventName' onset date ... } )
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
        %                           PlotPlanning
        % -----------------------------------------------------------------
        function PlotPlanning( obj )
            % obj.PlotPlanning()
            %
            % Plot Planning Events ( DOWN = 0 or UP > 0 ) over the time.
            % Each Event has it's own Up value {1, 2, 3 , ...} and its
            % own color for reading comfort.
            
            % ===================== Regroup each event ====================
            
            [event_name,~,idx_event2data] = unique(obj.Data(:,1),'stable');
            
            % Col 1 : event_name
            % Col 2 : obj.Data(event_name)
            % Col 3 ~ obj.Data(event_name), adapted for plot
            events = cell(length(event_name),3);
            
            for e = 1:length(event_name)
                events{e,1} = event_name{e};
                events{e,2} = cell2mat ( obj.Data( idx_event2data == e , 2:3 ) );
            end
            
            % ================= Build curves for each Event ===============
            
            for e = 4 : size( events , 1 ) % For each Event

                    data = [ events{e,2} ones(size(events{e,2},1),1) ]; % Catch data for this Event
                    
                    N  = size( data , 1 ); % Number of data = UP(0) + DOWN(1)
                    
                    % Here we need to build a curve that looks like
                    % recangles
                    for n = N:-1:1

                        % Split data above & under the point
                        dataABOVE = data( 1:n ,: );
                        dataUNDER = data( n+1:end , : );
                        
                        % Add a point ine curve to build a rectangle
                        switch data(n,2)
                            case 0
                                data  = [ dataABOVE ; dataUNDER(1,1) 1  ; dataUNDER ] ;
                            case 1
                                data  = [ dataABOVE ; dataUNDER(1,1) 0 ; dataUNDER ] ;
                                
                            otherwise
                                disp( 'bug' )
                        end
                    end
                    
                    events{e,3} = data

            end
%%
            % ======================== Plot ===============================
            
            figure( 'Name' , [ mfilename ' : ' inputname(1) ] , 'NumberTitle' , 'off' )
            hold all
            
            % For each Event, plot the curve
            for e = 1 : size( events , 1 )

                plot( events{e,3}(:,1) , events{e,3}(:,2) )
                
            end
            
            lgd = legend( events(:,1) );
            set(lgd,'Interpreter','none')
            
            % Change the limit of the graph so we can clearly see the
            % rectangles.
            
            old_xlim = xlim;
            range_x  = old_xlim(2) - old_xlim(1);
            center_x = mean( old_xlim );
            new_xlim = [ (center_x - range_x*1.1/2 ) center_x + range_x*1.1/2 ];
            
            old_ylim = ylim;
            range_y  = old_ylim(2) - old_ylim(1);
            center_y = mean( old_ylim );
            new_ylim = [ ( center_y - range_y*1.1/2 ) center_y + range_y*1.1/2 ];
            
            xlim( new_xlim )
            ylim( new_ylim )

        end
        
    end % methods
    
end % class