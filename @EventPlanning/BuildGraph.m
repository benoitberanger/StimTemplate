function BuildGraph( obj )
% obj.BuildGraph()
%
% Build curves for each events, ready to be plotted.

% ===================== Regroup each event ====================

% Check if not empty
obj.IsEmptyProperty('Data');

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
