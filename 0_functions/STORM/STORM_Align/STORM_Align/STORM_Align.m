function STORM_Align(file,folder,zoom)

%% input
% file is the name of the txt file of molecule list     e.g. 'Cep164-647-high_0005_list_auto_cluster_s_tran_redu_robust_20140926-20150414'
% folder is where you put all the png images to align   e.g. 'D:\Xiaoyu\MatlabAnalysis\3dalignment\FTalign\STORM_Align\input\'
% zoom is the magnification when you save your images with Insight3.  You
% can get the number using Insight3, View->Iamge Parameters->Zoom.  The
% default is 50 if you use Insight3 cluster aligning mode.      e.g.50

%% output
% The output is a txt file of molecule list of aligned clusters.  This txt
% file can be read by Insight3. Insight3 -> file-> load molecule list 


%% 
addpath(genpath(pwd))

% paprameters for alignment
usfac = 100; % alignment resolution =1/usfac (pixel)
angrange = 90; % ratation range
angstep = 2; % degrees to rotate each time
n_iteration = 10;  % number of iterations you wanted to align, increase this number if the result is not satisfying.


% tune the contrast of the images to align
n=3;  % lower the contrst
m=6;  % lower the contrst
[images0,images] = ReadMultiImageLowCon(folder,n);  % tested n is 3, images0 is the low con images, images is untreated.

% align images ratationally and translationally
[aligniter,iterIm,s,n_frame,allIm] = rotregistrationALL(images0,usfac,angrange,angstep,n_iteration);

writelist10(aligniter,n_iteration,file,zoom);

sumim = zeros(s,s);
for index = 1:n_frame
    sumim = sumim + images(:,:,index);
end
regi=iterIm(:,:,n_iteration);
[A] = LowerImages(regi,m);

figure;
subplot(1,2,1);imshow(sumim/3000);title('to be registered')
subplot(1,2,2);imshow(abs(regi)/3000);title('registered')




