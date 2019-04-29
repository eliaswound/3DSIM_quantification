%% Function to generate a fast gaussian binned represention of 
%  STORM data bin the data with a bin pixel size defined in nm
%  load xyz data, and tif file for boundary

% Copyright @2012/04/30 Rahul

%% Input
%   1. *.dat file output by Merge_and_plotfiles.m - Rahul
%                           precisionstat.m       - Yujie Sun
%                           Domain3D.m            - Peter Su
%      X in um - Y in um - Z in um or nm
%   2. X pixel Size in nm
%      Y pixel Size in nm6
%   3. bin size     in nm

%% Output
%   1. -bin##nm-Rendered*.fig file
%   2. -bin##nm-Rendered*.tif file 

%% Revised by Q. Peter Su on Dec 28 2012
%  Input the X and Y pixel size in nm

%% Revised by Q.Peter Su on Jan 07 2013
%  output file name -bin##nm-Rendered*.tif file 

%% Revised by Q.Peter Su & Yujie Sun on Apr 14 2013
%  imwrite(uint16(10000*nNorm),tiffilename,'tif', 'Compression', 'none', 'WriteMode',  'overwrite');

%% Revised by Q.Peter Su on Nov 18 2013
%  bin = 5nm - resolution = 25nm
%  






function ST08_fastmap_20131130new_60000(Afname,Xpixel,Ypixel,bin,resolution)
%% Load data
%clc
close all;
%%
if nargin<5
[FileName,PathName] = uigetfile('*.dat',...
    'Select Corrected and Filtered *.DAT File for fastmap',...
    'MultiSelect', 'off');
cd(PathName);
%frames = input('Enter Total no. of frames?');

    Afname      =char(FileName);
%     Xpixel      =input('Please input X pixel size (in nm) - ');
%     Ypixel      =input('Please input Y pixel size (in nm) - ');
%     bin         =input('Enter Bin Size for Render (in nm) - ');
%     resolution  =input('Enter Resolution of STORM (in nm) - ');


    Xpixel      =160;
    Ypixel      =160;
    bin         =5;
    resolution  =12.5;
end

%%
[imagefile, Path] = uigetfile({'*bf*.tif','Select .tif file for size';...
                               '*.tif','Select .tif file for size'}, ...
                               'MultiSelect', 'off');
disp('... Import Data ing ...')
XYZt = importdata(Afname);
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
x = XYZt(:,1); %%%%%%% These are in um rather than in pixels %%%%%%%%%%
y = XYZt(:,2); %%%%%%%%  (need to change for actual data)  %%%%%%%%%%%%
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%t = XYZt(:,12);
% X and Y Pixel Size
strout0=strcat('Totally, There are - ', num2str(size(x,1)), '- Localizations to be Rendered.');
disp(strout0);
   %% use the drift corrected file to build 2D histogram
disp('------------------------------------------------------------------');
disp('... Get Info ing ...')
if imagefile ==0
    xwidth  = (max(XYZt(:,2)) - min(XYZt(:,2))); %%%%???????????
    yheight = (max(XYZt(:,1)) - min(XYZt(:,1)));  %um position values
else
   % image =imread(imagefile); 
    info = imfinfo([Path imagefile]);
    strout1=strcat('Raw tif File X Pixel = ', num2str(info(1,1).Width));
    disp(strout1);
    strout2=strcat('Raw tif File Y Pixel = ', num2str(info(1,1).Height));
    disp(strout2);
    xwidth = info(1,1).Width   * Xpixel/1000;     %um values (160nm pixel)
    yheight = info(1,1).Height * Ypixel/1000;

    x = XYZt(:,1);
    y = XYZt(:,2);
end
%% binning of data
% if nargin<3
%     bin       = input('Enter bin size (in nm)              - ');
% end
disp('------------------------------------------------------------------');
disp('... Calculate Localization ing ...')
disp('This might take a few minutes due to your image size...');
disp('... Be Patient ... Please ...');
    binsize = bin/1000.;   % binsize in um
    nxbins = ceil(xwidth/binsize);
    nybins = ceil(yheight/binsize);
    xc = linspace(0,xwidth, nxbins);
    yc = linspace(0,yheight, nybins)';
    
    tic
    %IHis = zeros([length(xc) length(yc)]);
    IHis = hist2d(x, y, xc, yc);
    toc
%% gaussian convolution and centroid extraction
disp('------------------------------------------------------------------');
disp('... Gaussian Smooth ing ...');
GaussianBottom=ceil(resolution*3/bin); % unit - pixel
% resolution is 2.355fold of standard deviation (sigma)
% the bottome of the gaussian peak is 3-fold of resolution 
if mod(GaussianBottom,2)==1
    GaussianBottom=GaussianBottom;
else
    GaussianBottom=GaussianBottom+1;
end
GaussianStd=floor(GaussianBottom/6); % unit - pixel
h1 = fspecial('gaussian', GaussianBottom , GaussianStd);
tic
IHisg = imfilter(IHis, h1); 
toc
%% Display  Images
disp('------------------------------------------------------------------');
disp('... Plot Localizations ing ...')
scrsz = get(0,'ScreenSize');
figure('OuterPosition',[1 0.5*scrsz(4) 1000 500]);
% colorbar set to enhance contrast
% norm = double(max(IHisg(:)));
norm = double(max(max(IHisg)));
nNorm = double(IHisg)./norm; 
%level = 0.3*graythresh(nNorm); 
level = graythresh(nNorm); 
cmax = level*norm;
clims1 = [0 5*cmax];
clims2 = [0 5*cmax];
colormap hot;
subplot(1,2,1) 
imagesc(xc(1,:),yc(:,1),IHis, clims2); colorbar;
axis equal
%xlable('X in um');
%ylabel('Y in um');

subplot(1,2,2) 
imagesc(xc(1,:),yc(:,1),IHisg, clims1); colorbar;
axis equal
%xlable('X in um');
%ylabel('Y in um');
figurefilename1 = strcat(Afname(1:end-4),'-Bin',num2str(bin),'-Res',num2str(resolution),'-60000-Rend.fig'); 
figurefilename2 = strcat(Afname(1:end-4),'-Bin',num2str(bin),'-Res',num2str(resolution),'-60000-Rend.png'); 
saveas(gcf,figurefilename1,'fig');
saveas(gcf,figurefilename2,'png');
tiffilename = strcat(Afname(1:end-4),'-Bin',num2str(bin),'-Res',num2str(resolution),'-60000-Rend.tif');
%imwrite(uint16(10000*IHisg),tiffilename,'tif', 'Compression', 'none', 'WriteMode',  'overwrite');
imwrite(uint16(60000*nNorm),tiffilename,'tif', 'Compression', 'none', 'WriteMode',  'overwrite');

end