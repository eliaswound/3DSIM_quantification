clear;close all;clc;
% cell_contour determination by watershed
[FileName,PathName]=uigetfile({'*.tif';'*.tiff';'*.png';'*.jpeg';'*.bmp'},'Select the image file');
cd(PathName);
image=imread(FileName);
imsegm=double(image);

% Illumination correction/ Zhen newly added 
prm.illum = 1;% 1 means there is illumination correction

% Smoothing
prm.smoothim.method = 'dirced';

% Ridge filtering
prm.filterridges = 1;

% Segmentation
prm.classifycells.convexarea = 0.50; % need to change  
prm.classifycells.convexperim = 0.45; %¡¡need to change 
[cellbw,wat,imsegmout,minima,minimacell,info] = ...
    cellsegm.segmsurf(imsegm,2,10000,'prm',prm);

cellsegm.show(imsegm,1);title('Raw image');axis off;
cellsegm.show(minima,2);title('Markers');axis off;
cellsegm.show(wat,3);title('Watershed image');axis off;
cellsegm.show(cellbw,4);title('Cell segmentation');axis off;