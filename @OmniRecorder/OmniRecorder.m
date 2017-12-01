classdef OmniRecorder < BasicObject
    % OMNIRECORDER is a 'virtual' class : all subclasses contain this virtual class methods and attributes
    % OmniRecorder can record everything.
    % Data are stored in Cell.
    % WARNING : if you need to store numeric data at high speed or for a lot of sample, use SampleRecorder.
    
    
    %% Properties
    
    properties
        
        Data           = cell(0) % cell( NumberOfEvents , Columns )
        Columns        = 0       % double(positive integer)
        NumberOfEvents = 0       % double(positive integer)
        EventCount     = 0       % double(positive integer)
        GraphData      = cell(0) % cell( 'ev1' curve1 ; 'ev2' curve2 ; ... )
        
    end
    
    
    %% Methods
    
    methods
        
        % --- Constructor -------------------------------------------------
        % no constructor : this is a 'virtual' object
        % -----------------------------------------------------------------
        
    end
    
    
end % classdef
