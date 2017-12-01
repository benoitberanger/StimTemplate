classdef BasicObject < handle
    %BASICOBJECT is a 'virtual' class : all subclasses contain this virtual class methods and attributes
    % This is a very basic object, just a container of simple methods
    
    
    %% Properties
    
    properties
        
        TimeStamp      = datestr( now )          % str : Time stamp for the creation of object
        Description    = mfilename( 'fullpath' ) % str : Fullpath of the file
        Header         = {''}                    % cellstr : Description of each columns
        
    end
    
    
    %% Methods
    
    methods
        
        % --- Constructor -------------------------------------------------
        % no constructor : this is a 'virtual' object
        % -----------------------------------------------------------------
        
    end
    
    
end % classdef
