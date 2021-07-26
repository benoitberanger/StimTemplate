function t = data2table( self )

data = self.Data; % make a copy so it can be modified if necessary

if iscell(data)
    
    % remove StartTime & StopTime
    startstop = strcmp( data(:,1), 'StartTime' ) | strcmp( data(:,1), 'StopTime' );
    data( startstop , : ) = [];
    
    t = cell2table(data,'VariableName',matlab.lang.makeValidName(self.Header));
    
elseif isnumeric(data)
    
    t = array2table(data,'VariableName',matlab.lang.makeValidName(self.Header));
    
end

end % function
