function plotSPMnod( Names , Onsets , Durations )
%PLOTSPMNOD plots Names Onsets and Durations (n.o.d.) defined for SPM
%
%  SYNTAX
%  (1) plotSPMnod( Names , Onsets , Durations )
%  (2) plotSPMnod
%
%  INPUTS
%  1. Names : defined for SPM
%  2. Onsets : defined for SPM
%  3. Durations : defined for SPM
%
%  NOTES
%  (1) All inputs are cells used for SPM design matrix
%  (2) Try to use 'names', 'onsets', 'durations' from base workspace
%
% See also spm

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2015


%% Check input arguments

Arguments = {...
    'Names'     ;...
    'Onsets'    ;...
    'Durations'  ...
    };
nb_Args = length(Arguments);

% Must be 3 input arguments, or try with the base workspace
if nargin > 0
    
    % narginchk(nb_Args,nb_Args)
    % narginchk introduced in R2011b
    if nargin ~= nb_Args
        error('%s uses %d input argument(s)',mfilename,nb_Args)
    end
   
else
    
    % Import variables from base workspace
    vars = evalin('base','whos');
    
    % Check each variable from base workspace
    for v = 1 : length(vars)
        
        % names ?
        if strcmp ( vars(v).name , 'names' ) && strcmp ( vars(v).class , 'cell' )
            Names = evalin('base','names');
        end
        % onsets ?
        if strcmp ( vars(v).name , 'onsets' ) && strcmp ( vars(v).class , 'cell' )
            Onsets = evalin('base','onsets');
        end
        % durations ?
        if strcmp ( vars(v).name , 'durations' ) && strcmp ( vars(v).class , 'cell' )
            Durations = evalin('base','durations');
        end
        
    end
    
    % Check if all vairables have been found in the base workspace
    if ~ ( exist('Names','var') && exist('Onsets','var') && exist('Durations','var') )
        error('Even without input arguments, the function tries to use the base workspace variables, but failed.')
    end
    
end

% Correct arguments ?
Length = nan(size(Arguments));
for arg = 1 : nb_Args
    validateattributes(eval(Arguments{arg}),{'cell'},{'vector'},mfilename,Arguments{arg},arg)
    Length(arg) = length(eval(Arguments{arg}));
end

% All inputs with the same dimension ?
collinear = cross( Length , ones(size(Arguments)) );
if any(collinear) % is Length vector collinear to [1 ; 1 ; 1] ?
    error('All inputs must have the same dimensions')
end

% Names is only strings ?
if ~iscellstr(Names)
    error('Names must be a cell array of strings')
end

for arg_  = 1 : Length(1)
    
    % Onset and Durations have same dimensions inside ?
    if length(Onsets{arg_}) ~= length(Durations{arg_})
        error( 'Onsets{%d} and Durations{%d} have different dimensions : %d and %d ' , arg_ , arg_ , length(Onsets{arg_}) , length(Durations{arg_}) )
    end
    
    % Onsets numeric inside ?
    if ~isnumeric(Onsets{arg_})
        error( 'Onsets{%d} must be numeric ', arg_ )
    end
    
    % Durations numeric inside ?
    if ~isnumeric(Durations{arg_})
        error( 'Durations{%d} must be numeric ', arg_ )
    end
    
end

% Change each column vector into row, just for convenience

for arg = 1 : nb_Args
    if isrow(eval(Arguments{arg}))
        eval([Arguments{arg} '=' Arguments{arg} ''';'])
    end
end

for o = 1 : length(Onsets)
    if isrow(Onsets{o})
        Onsets{o} = Onsets{o}';
    end
end

for d = 1 : length(Durations)
    if isrow(Durations{d})
        Durations{d} = Durations{d}';
    end
end



%% Prepare curves

% Pre-allocate
Curves = cell(length(Names),1);

% For condition
for c = 1 : size( Curves , 1 )
    
    % Catch data for this condition
    data = [ Onsets{c} Durations{c} ones(size(Onsets{c},1),1) ];
    
    % Number trials in the condition
    N  = size( data , 1 );
    
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
    if ~isempty(data)
        data(:,2) = [];
    end
    
    % Store curves
    Curves{c} = data;
    
end


%% Plot

% Figure
figure( ...
    'Name'        , mfilename                , ...
    'NumberTitle' , 'off'                      ...
    )

hold all

% For each Event, plot the curve
for c = 1 : size( Curves , 1 )
    
    if ~isempty(Curves{c})
        
        plot( Curves{c}(:,1) , Curves{c}(:,2) + c )
        
    else
        
        plot(0,NaN)
        
    end
    
end

% Legend
lgd = legend( Names(:) );
set(lgd,'Interpreter','none')


%% Adjust window display
% Change the limit of the graph so we can clearly see the rectangles.

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

% ================ Change YTick and YTickLabel ================

% Put 1 tick in the middle of each event
set( gca , 'YTick' , (1:size( Names , 1 ))+0.5 )

% Set the tick label to the event name
set( gca , 'YTickLabel' , Names )


end
