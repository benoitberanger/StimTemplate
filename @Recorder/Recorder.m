classdef Recorder < handle
    % RECORDER is a 'virtual' class : all subclasses contain this virtual class methods and attributes
    
    
    %% Properties
    
    properties
        
        Data           = cell(0)                 % cell( NumberOfEvents , Columns )
        Header         = {''}                    % cellstr : Description of each columns
        Columns        = 0                       % double(positive integer)
        Description    = mfilename( 'fullpath' ) % str : Fullpath of the file
        TimeStamp      = datestr( now )          % str : Time stamp for the creation of object
        NumberOfEvents = 0                       % double(positive integer)
        EventCount     = 0                       % double(positive integer)
        GraphData      = cell(0)                 % cell( 'ev1' curve1 ; 'ev2' curve2 ; ... )
        BlockData      = cell(0)                 % cell( ? , Columns )
        BlockGraphData = cell(0)
        
    end
    
    
    %% Methods
    
    methods
        
        % --- Constructor -------------------------------------------------
        % no constructor : this is a 'virtual' object
        % -----------------------------------------------------------------
        
    end
    
    
end % classdef
