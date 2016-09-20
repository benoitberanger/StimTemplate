function [ Noise ] = Value2D( hvPoints , Octaves , f0 , Persistance , Lacunarity )
%VALUE2D Generate values noise
%
%   --- SYNTAX ------------------------------------------------------------
%
%   [ Noise ] = Noise.Value2D( hvPoints , Octaves , f0 , Persistance , Lacunarity )
%
%   hvPoints    : [nrPointsH , nrPointsV] for number of horizontal and vertical points
%   Octaves     : number of iterations of the process
%   f0          : lowest special frequency
%   Persistance : each iteration, amplitude of the octave is Persistance^octaveNumber
%   Lacunarity  : each iteration, spatial frequencey of the octave is Lacunarity^octaveNumber
%
%
%   --- EXEMPLE -----------------------------------------------------------
%
%   [ Noise ] = Noise.Value2D( [800 600] , 5 , 5 , 0.5 , 2 )
%   classic values => (Persistance,Lacunarity)=(0.5,2) means each iteration halves the amplitude and doubles the spatial frequency.
%
%
%   --- NOTES -------------------------------------------------------------
%
%   Noise.Value2D() => display an example
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
    Octaves = 5;
else
    if ~( isnumeric(Octaves) && isscalar(Octaves) && Octaves>0 && Octaves==round(Octaves) )
        error('Octaves must be integer(1,1)>0')
    end
end

% nPoints ?
if nargin < 1
    hvPoints = [800 600];
    display = true;
else
    if ~( isnumeric(hvPoints) && isvector(hvPoints) && all(hvPoints)>0 && all(hvPoints==round(hvPoints)) )
        error('nPoints must be integer(1,2)>0')
    end
    display = false;
end


%% Do

nrPointsH = hvPoints(1);
nrPointsV = hvPoints(2);

if nrPointsH >= nrPointsV
    freqH = f0;
    freqV = ceil(f0/(nrPointsH/nrPointsV));
else
    freqV = f0;
    freqH = ceil(f0/(nrPointsV/nrPointsH));
end

H = linspace(0,nrPointsH,nrPointsH); % horizontal position of the points we need (doesnt change)
V = linspace(0,nrPointsV,nrPointsV); % vertical position of the points we need (doesnt change)
Noise = zeros(nrPointsV,nrPointsH); % preallocate the output
[HI,VI] = meshgrid( H , V ); % convert the H V positions into a grid of points

for o = 1:Octaves
    
    amplitude = Persistance^(o);
    freqFactor = Lacunarity^(o);
    
    
    [h,v] = meshgrid( linspace(0,nrPointsH,freqH*freqFactor) , linspace(0,nrPointsV,freqV*freqFactor) );
    
    z = randn( freqV*freqFactor , freqH*freqFactor )*amplitude;
    
    ZI = interp2(h,v,z,HI,VI,'spline'); % cubic slower than spline but looks better
    
    Noise = Noise + ZI;
    
    if display && mod(o,2) == 1
        
        figure( 'Name', ['octaves=' num2str(o)], 'NumberTitle', 'off', 'Units', 'Normalized', 'Position', [0.05, 0.05, 0.90, 0.80] )
        
        subplot(2,1,1)
        hold all
        surf(ZI,'EdgeColor','none')
        view(2)
        colormap( gray(255) )
        axis equal
        axis off
        
        subplot(2,1,2)
        hold all
        surf(Noise,'EdgeColor','none')
        view(2)
        colormap( gray(255) )
        axis equal
        axis off
        
    end
    
end

Noise = Noise + abs(min(Noise(:)));
Noise = Noise/max(Noise(:));
Noise = (Noise-0.5)*255 + 255/2;

if display
    
    figure( 'Name', sprintf('nrPointsH=%d , nrPointsV=%d , Octaves=%d , f0=%d , Persistance=%g , Lacunarity=%g',...
        nrPointsH, nrPointsV, Octaves, f0, Persistance, Lacunarity ),...
        'NumberTitle', 'off', 'Units', 'Normalized', 'Position', [0.05, 0.05, 0.90, 0.80] )
    surf(Noise,'EdgeColor','none')
    view(2)
    colormap( gray(255) )
    axis equal
    axis off
    
    clear Noise
    
end

end
