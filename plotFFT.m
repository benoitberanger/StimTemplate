function plotFFT( signal , fs , F_view )
%%PLOTFFT( signal , fs , F_view )

% benoit.beranger@icm-institute.org
% CENIR-ICM , 2014

if nargin < 3
    F_view = [];
end
 
L = length(signal);

figure

subplot(2,1,1)
plot((1:L)/fs,signal)
ylabel('Signal(t)')
xlabel('t (s)')

% --- first version ---
% NFFT = 2^nextpow2(L); % Next power of 2 from length of y
% Y = fft(signal,NFFT)/L;
% f = fs/2*linspace(0,1,NFFT/2+1);

% --- second version ---
Y = fft(signal);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(L/2))/L;


% Plot single-sided amplitude spectrum.
subplot(2,1,2)

% --- first version ---
% plot(f,2*abs(Y(1:NFFT/2+1)))

% --- second version ---
plot(f,P1)

xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

if ~isempty(F_view)
    xlim(F_view)
end

end

