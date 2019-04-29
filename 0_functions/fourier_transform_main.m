clear; close all;clc;
%--------------------------------------------------------------------------
% Import and process the data
%--------------------------------------------------------------------------
[filename,pathname]=uigetfile('*.txt','please select the txt file you want to analyze');
cd(pathname);
num = importdata(filename);
data=num.data;
data(:,3)=data(:,1)*5;  % 1 pixel=5 nm
data(:,4)=data(:,2)/max(data(:,2)); % normalize the maximum value
%--------------------------------------------------------------------------
% Plot the Signal
%--------------------------------------------------------------------------
figure(1)
plot(data(:,3),data(:,2),'r-')
xlabel('nm')
ylabel('intensity')
%--------------------------------------------------------------------------
% Fourier transform
%--------------------------------------------------------------------------
sampling_frequency=0.2; % every 5 nm 
T=1/sampling_frequency; % sampling distance nm
L=length(data); % length of the signal
Intensity=data(:,4);   
t=(0:L-1)*T;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y=fft(Intensity,NFFT)/L;
f=sampling_frequency/2*linspace(0,1,NFFT/2+1);
%--------------------------------------------------------------------------
% Plot single-sided amplitude spectrum.
%--------------------------------------------------------------------------
amplitude=2*abs(Y(1:NFFT/2+1));
figure(2)
plot(f,amplitude)
xlabel('frequency(nm-1)')
ylabel('amplitude')
%--------------------------------------------------------------------------
% plot the interested region
%--------------------------------------------------------------------------
finterest=find(f>0.005&f<0.015);
f_interest=f(finterest);
amplitude_interest=amplitude(finterest,1);
figure(3)
plot(f_interest,amplitude_interest,'g-')
xlabel('frequency(nm-1)')
ylabel('amplitude')
%--------------------------------------------------------------------------
% Output the main frequency
%--------------------------------------------------------------------------
[value,index]=max(amplitude_interest);
periodicity=f_interest(index);   
periodicity_nm=1/periodicity;
display('----------------------------------------------------------------')
display('The periodicity is:')
display([num2str(periodicity_nm) 'nm'])
display('----------------------------------------------------------------')
%--------------------------------------------------------------------------
% Save all the data and frequency
%--------------------------------------------------------------------------
saveas(figure(1),[filename(1:end-4) '_intensity.fig'],'fig');
saveas(figure(2),[filename(1:end-4) '_frequency.fig'],'fig');
saveas(figure(3),[filename(1:end-4) '_frequency_selected.fig'],'fig');
save([filename(1:end-4) '.mat']);
