% identifying one 
clear;close all;clc;
% cell_contour determination by watershed
[FileName,PathName]=uigetfile({'*.tif';'*.tiff';'*.png';'*.jpeg';'*.bmp'},'Select the image file');
cd(PathName);
image=imread(FileName);
bw = im2bw(image, graythresh(image));
figure;
imshow(bw);
[y, x] = find(bw); 
figure;
scatter(x,y,'*');
axis equal