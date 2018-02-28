function PlotHRF( self, TR, nrVolumes )
%PLOTHRF convolves the events with HRF, using SPM pipeline
% TR is required to estimate the stimulus response function


%% Checks

% SPM
assert( ~isempty( which('spm_hrf') ) , 'SPM toolbox is required' )

% Data
assert( size(self.Data,1)>1, 'Empty data' )

% TR
assert( nargin>=1, 'TR is required to estimate the stimulus response function' )
assert( isnumeric(TR) && isscalar(TR) && TR>0, 'TR must be positive' )

% nrVolumes
if nargin < 3
    nrVolumes = ceil( self.Data{end,2}/TR ) + 1;
end
assert( isnumeric(nrVolumes) && isscalar(nrVolumes) && nrVolumes>0 && nrVolumes==round(nrVolumes) , 'nrVolumes must be positive integer' )


%% Format self.Data into names onsets durations

[names,~,indC] = unique_stable( self.Data(:,1) );

onsets    = cell(size(names));
durations = cell(size(names));

for n = 1 : length(names)
    onsets{n}    = cell2mat( self.Data(indC==n,2) );
    durations{n} = cell2mat( self.Data(indC==n,3) );
end % names


%% Pipe my environement with SPM

SPM.xY.RT = TR;
SPM.nscan = nrVolumes;

multicond           = struct;
multicond.names     = names;
multicond.onsets    = onsets;
multicond.durations = durations;

SPM.xBF.name = ''; % it means cannonical HRF


%% SPM : part 1

%-Microtime onset and microtime resolution
%--------------------------------------------------------------------------
fMRI_T     = spm_get_defaults('stats.fmri.t');
fMRI_T0    = spm_get_defaults('stats.fmri.t0');
SPM.xBF.T  = fMRI_T;
SPM.xBF.T0 = fMRI_T0;

%-Time units, dt = time bin {secs}
%--------------------------------------------------------------------------
SPM.xBF.dt     = SPM.xY.RT/SPM.xBF.T;

%-Get basis functions
%--------------------------------------------------------------------------
SPM.xBF        = spm_get_bf(SPM.xBF);


%% SPM : part 2

i = 1;

sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});

% %-Load MAT-file
% %------------------------------------------------------------------
% try
%     multicond = load('/mnt/data/benoit/Protocol/NBI/fmri/behaviour_data/spmReady_MTMST_files/2016_04_29_NBI_Pilote01/MT_LEFT.mat');
% catch
%     error('Cannot load %s',sess.multi{1});
% end

%-Check structure content
%------------------------------------------------------------------
if ~all(isfield(multicond, {'names','onsets','durations'})) || ...
        ~iscell(multicond.names) || ...
        ~iscell(multicond.onsets) || ...
        ~iscell(multicond.durations) || ...
        ~isequal(numel(multicond.names), numel(multicond.onsets), ...
        numel(multicond.durations))
    error(['Multiple conditions MAT-file ''%s'' is invalid:\n',...
        'File must contain names, onsets, and durations '...
        'cell arrays of equal length.\n'],sess.multi{1});
end

for j=1:numel(multicond.onsets)
    
    %-Mutiple Conditions: names, onsets and durations
    %--------------------------------------------------------------
    cond.name     = multicond.names{j};
    if isempty(cond.name)
        error('MultiCond file: sess %d cond %d has no name.',i,j);
    end
    cond.onset    = multicond.onsets{j};
    if isempty(cond.onset)
        error('MultiCond file: sess %d cond %d has no onset.',i,j);
    end
    cond.duration = multicond.durations{j};
    if isempty(cond.onset)
        error('MultiCond file: sess %d cond %d has no duration.',i,j);
    end
    
    %-Mutiple Conditions: Time Modulation
    %--------------------------------------------------------------
    if ~isfield(multicond,'tmod'); %#ok<*NOSEL>
        cond.tmod = 0;
    else
        try
            cond.tmod = multicond.tmod{j};
        catch
            error('Error specifying time modulation.');
        end
    end
    
    %-Mutiple Conditions: Parametric Modulation
    %--------------------------------------------------------------
    cond.pmod = [];
    if isfield(multicond,'pmod')
        try
            %-Check if a PM is defined for that condition
            if (j <= numel(multicond.pmod)) && ...
                    ~isempty(multicond.pmod(j).name)
                for ii = 1:numel(multicond.pmod(j).name)
                    cond.pmod(ii).name  = multicond.pmod(j).name{ii};
                    cond.pmod(ii).param = multicond.pmod(j).param{ii};
                    cond.pmod(ii).poly  = multicond.pmod(j).poly{ii};
                end
            end
        catch
            warning('Error specifying parametric modulation.');
            rethrow(lasterror); %#ok<*LERR>
        end
    end
    
    %-Mutiple Conditions: Orthogonalisation of Modulations
    %--------------------------------------------------------------
    if isfield(multicond,'orth') && (j <= numel(multicond.orth))
        cond.orth    = multicond.orth{j};
    else
        cond.orth    = true;
    end
    
    %-Append to singly-specified conditions
    %--------------------------------------------------------------
    sess.cond(end+1) = cond;
end


%-Conditions
%----------------------------------------------------------------------
U = [];

for j = 1:numel(sess.cond)
    
    %-Name, Onsets, Durations
    %------------------------------------------------------------------
    cond      = sess.cond(j);
    U(j).name = {cond.name}; %#ok<*AGROW>
    U(j).ons  = cond.onset(:);
    U(j).dur  = cond.duration(:);
    U(j).orth = cond.orth;
    if isempty(U(j).orth), U(j).orth = true; end
    if length(U(j).dur) == 1
        U(j).dur = repmat(U(j).dur,size(U(j).ons));
    elseif numel(U(j).dur) ~= numel(U(j).ons)
        error('Mismatch between number of onset and number of durations.');
    end
    
    %-Modulations
    %------------------------------------------------------------------
    P  = [];
    q1 = 0;
    %-Time Modulation
    %     switch job.timing.units
    %         case 'secs'
    sf    = 1 / 60;
    %         case 'scans'
    %             sf    = job.timing.RT / 60;
    %         otherwise
    %             error('Unknown unit "%s".',job.timing.units);
    %     end
    if cond.tmod > 0
        P(1).name = 'time';
        P(1).P    = U(j).ons * sf;
        P(1).h    = cond.tmod;
        q1        = 1;
    end
    %-Parametric Modulations
    if ~isempty(cond.pmod)
        for q = 1:numel(cond.pmod)
            q1 = q1 + 1;
            P(q1).name = cond.pmod(q).name;
            P(q1).P    = cond.pmod(q).param(:);
            P(q1).h    = cond.pmod(q).poly;
        end
    end
    %-None
    if isempty(P)
        P.name = 'none';
        P.h    = 0;
    end
    
    U(j).P = P;
    
end

SPM.Sess.U = U;


%% SPM : part 3

s = 1;

%-Number of scans for this session
%----------------------------------------------------------------------
k = SPM.nscan(s);

%-Create convolved stimulus functions or inputs
%======================================================================

%-Get inputs, neuronal causes or stimulus functions U
%----------------------------------------------------------------------
U = spm_get_ons(SPM,s);

%-Convolve stimulus functions with basis functions
%----------------------------------------------------------------------
SPM.xBF.Volterra = 1;
% [X,Xn,Fc] = spm_Volterra(U, SPM.xBF.bf, SPM.xBF.Volterra);
[X,~,~] = spm_Volterra(U, SPM.xBF.bf, SPM.xBF.Volterra);

%-Resample regressors at acquisition times (32 bin offset)
%----------------------------------------------------------------------
if ~isempty(X)
    X = X((0:(k - 1))*fMRI_T + fMRI_T0 + 32,:);
end

%% Plot

% Figure
figure( ...
    'Name'        , [ inputname(1) ' : ' class(self) ] , ...
    'NumberTitle' , 'off'                                ...
    )
hold all

t = (0 : nrVolumes-1) * TR;

for n = 1 : length(names)
    
    plot( t, X(:,n), 'DisplayName',names{n} )
    
end

xlabel ('time (s)')
ylabel ('hemodynamic response (A.U.)')

legend('show')


end % function
