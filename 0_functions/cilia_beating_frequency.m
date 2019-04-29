Fs=300; % sampling frequency 
row2=image(3,:);
row2=row2-mean(row2);
row2=row2(1:1000);
T=1/Fs;% sample time
L=length(row2); % Length of the signal
t=(0:L-1)*T; % Time vector
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(row2,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2+1)))
set(gca,'XTick',[0:10:150]);
xlabel('Frequency','fontsize',14');
ylabel('Amplitude','fontsize',14');

% nfft=length(row1);
% nfft2=2^nextpow2(nfft);
% ff=fft(row1,nfft2);
% fff=ff(1:nfft2/2);
% xxfft=Fs*(0:nfft2/2-1)/nfft2;
