function [ Noise ] = Value1D( nPoints , Octaves , f0 , Persistance , Lacunarity )
%VALUE1D Generate values noise
%
%   --- SYNTAX ------------------------------------------------------------
%
%   [ Noise ] = Noise.Value1D( nPoints , Octaves , f0 , Persistance , Lacunarity )
%
%   nPoints     : number of points to generate
%   Octaves     : number of iterations of the process
%   f0          : lowest special frequency
%   Persistance : each iteration, amplitude of the octave is Persistance^octaveNumber
%   Lacunarity  : each iteration, spatial frequencey of the octave is Lacunarity^octaveNumber
%
%
%   --- EXEMPLE -----------------------------------------------------------
%
%   [ Noise ] = Noise.Value1D( 1000 , 10 , 10 , 0.5 , 2 )
%   classic values => (Persistance,Lacunarity)=(0.5,2) means each iteration halves the amplitude and doubles the spatial frequency.
%
%
%   --- NOTES -------------------------------------------------------------
%
%   Noise.Value1D() => display an example
%
%   adapted from : http://web.archive.org/web/20080724063449/http://freespace.virgin.net/hugo.elias/models/m_perlin.htm

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2016


%% Check input arguments

% Lacunarity ?
if nargin < 5
    Lacunarity = 2;
else
    if ~( isnumeric(Lacunarity) && isscalar(Lacunarity) && Lacunarity>0 )
        error('Lacunarity must be numeric(1,1)>0')
    end
end

% Persistance ?
if nargin < 4
    Persistance = 0.5;
else
    if ~( isnumeric(Persistance) && isscalar(Persistance) && Persistance>0 )
        error('Persistance must be numeric(1,1)>0')
    end
end

% f0 ?
if nargin < 3
    f0 = 5;
else
    if ~( isnumeric(f0) && isscalar(f0) && f0>0 && f0==round(f0))
        error('f0 must be integer(1,1)>0')
    end
end

% Octaves ?
if nargin < 2
    Octaves = 10;
else
    if ~( isnumeric(Octaves) && isscalar(Octaves) && Octaves>0 && Octaves==round(Octaves) )
        error('Octaves must be integer(1,1)>0')
    end
end

% nPoints ?
if nargin < 1
    nPoints = 1000;
    display = true;
else
    if ~( isnumeric(nPoints) && isscalar(nPoints) && nPoints>0 && nPoints==round(nPoints) )
        error('nPoints must be integer(1,1)>0')
    end
    display = false;
end


%% Do

xi = linspace(0,nPoints,nPoints); % abscisse of the points we need (doesnt change)
Noise = zeros(1,nPoints); % preallocate the output

if display
    colors = lines(Octaves);
    figure( 'Name', mfilename, 'NumberTitle', 'off', 'Units', 'Normalized', 'Position', [0.05, 0.05, 0.90, 0.80] )
    ax(1) = subplot(3,1,1:2);
    hold all
    octavesDisplay = 4;
    ylabel(['octaves(1..' num2str(octavesDisplay) ')'])
    title(sprintf('nPoints=%d , Octaves=%d , f0=%d , Persistance=%g , Lacunarity=%g',...
        nPoints, Octaves, f0, Persistance, Lacunarity ))
end

for o = 1:Octaves
    
    amplitude = Persistance^(o);
    freqFactor = Lacunarity^(o);
    
    y = randn(1, f0*freqFactor)*amplitude; % random amplitudes
    x = linspace(0,nPoints,f0*freqFactor); % lineary spaced
    
    if display && o <= octavesDisplay
        plot(x,y,'Color',colors(o,:),'LineStyle','none','Marker','o')
    end
    
    yi = interp1(x,y,xi,'cubic'); % cubic slower than spline but looks better
    
    Noise =  Noise + yi; % add the octave to the noise
    
    if display && o <= octavesDisplay
        plot(yi,'Color',colors(o,:),'LineStyle','-','Marker','none')
    end
    
end

if display
    ax(2) = subplot(3,1,3);
    hold all
    plot(Noise)
    ylabel(['noise = sum(octaves(1..' num2str(Octaves) '))'])
    linkaxes(ax,'x')
    clear Noise
end

end
