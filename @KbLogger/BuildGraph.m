function BuildGraph( self )
% self.BuildGraph()
%
% Build curves for each events, ready to be plotted.


% ================= Build curves for each Kb ==================

for k = 1:size( self.KbEvents , 1 ) % For each KeyBinds
    
    if ~isempty( self.KbEvents{k,2} ) % Except for null (usually the last one)
        
        data = cell2mat( self.KbEvents{k,2}(:,1:2) ); % Catch data for this Keybind
        
        N  = size( data , 1 ); % Number of data = UP(0) + DOWN(1)
        
        % Here we need to build a curve that looks like
        % recangles
        for n = N:-1:1
            
            % Split data above & under the point
            dataABOVE = data( 1:n-1 ,: );
            dataUNDER = data( n:end , : );
            
            % Add a point ine curve to build a rectangle
            switch data(n,2)
                case 0
                    data  = [ ...
                        dataABOVE ; ...
                        dataUNDER(1,1) 1 ;...
                        dataUNDER ...
                        ] ;
                case 1
                    data  = [ ...
                        dataABOVE ; ...
                        dataUNDER(1,1) 0 ; ...
                        dataUNDER ...
                        ] ;
                    
                otherwise
                    disp( 'bug' )
            end
            
        end
        
        % Now we have a continuous curve that draws rectangles.
        % The objective now is to 'split' each rectangle, to
        % have a more convinient display
        
        % To find where are two consecutive 0, REGEXP is used
        data_str  = num2str(num2str(data(:,2)')); % Convert to text
        data_str  = regexprep(data_str,' ','');   % Delete white spaces
        idx_data_str = regexp(data_str,'00');     % Find two consecutive zeros
        
        % Add NaN between two consecutive zeros
        for n = length(idx_data_str):-1:1
            
            % Split data above & under the point
            dataABOVE = data( 1:idx_data_str(n) , : );
            dataUNDER = data( idx_data_str(n)+1:end , : );
            
            % Add a point in curve to build a rectangle
            data  = [ ...
                dataABOVE ; ...
                dataUNDER(1,1) NaN ; ...
                dataUNDER ...
                ] ;
            
        end
        
        % Store curves
        self.KbEvents{k,3} = data;
        
    end
    
end

% Store curves
self.GraphData = self.KbEvents;

end % function
