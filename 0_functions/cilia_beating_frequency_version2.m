clear;close all;clc;
% Cilia_Beating_Frequency_Measurement
% Step 1: import the image you want to analyze and input the frequency of
% the image
[filename,pathname]=uigetfile('*.tif','Select the image you want to analyze the frequency');
cd(pathname);
image=imread(filename);
sampling_frequency=input('please input the number of frames you collect in one second in the raw data');
[image_row,image_column]=size(image);
T=1/sampling_frequency; % sampling time
L=1000; % length of the signal
figure1=figure(1);
colors=distinguishable_colors(image_row);
cilia_frequency=zeros(image_row,1);
for i=1:image_row
   row=image(i,:);
   row=row-mean(row);
   row=row(1:1000); % only use the first thousand data
   t=(0:L-1)*T;
   NFFT = 2^nextpow2(L); % Next power of 2 from length of y
   Y=fft(row,NFFT)/L;
   f=sampling_frequency/2*linspace(0,1,NFFT/2+1);
   % Plot single-sided amplitude spectrum.
   amplitude=2*abs(Y(1:NFFT/2+1));
   plot(f,amplitude,'color',colors(i,:))
   hold on
   range=[f(f>=10&f<=30);amplitude(f>=10&f<=30)]; % 
   [max_amplitude,max_index]=max(range(2,:));
   cilia_frequency(i,1)=range(1,max_index);
   %clear row t NFFT Y f
end
   set(gca,'XTick',[0:10:150]);
   xlabel('Frequency');
   ylabel('Amplitude');
   title('Fourier Frequency For All the Rows');
   
   figure2=figure(2);
   hist(cilia_frequency);
   xlabel('cilia frequency');
   ylabel('row counts');
   title('Cilia Beating Frequency For Each Row');
   
   cilia_frequency_mean=mean(cilia_frequency);
   cilia_frequency_median=median(cilia_frequency);
   legend(['cilia frequency mean' num2str(cilia_frequency_mean)])
 
   display('-------------------------------------------------------------');
   display('The mean cilia frequency is');
   display(num2str(cilia_frequency_mean));
   display('-------------------------------------------------------------');
   %% To be finished 
   % save all the data 
   % save the frequency measured
   saveas(figure1,[filename(1:end-4) '_frequencydistribution.fig'],'fig');
   saveas(figure2,[filename(1:end-4) '_frequencyhistogramforeachline.fig'],'fig');

   save([filename(1:end-9) '_mean_beating_frequency.mat'],'cilia_frequency_mean');

   

