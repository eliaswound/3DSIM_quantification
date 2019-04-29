clear;close all;clc;
% cell_contour determination by watershed
[FileName,PathName]=uigetfile({'*.tif';'*.tiff';'*.png';'*.jpeg';'*.bmp'},'Select the image file');
cd(PathName);
image=imread(FileName);
% show figure
fig1=figure(1);imshow(image);
title(FileName)
% binary image
bw = im2bw(image, graythresh(image));
fig2=figure(2);imshow(bw);
title([FileName(1:end-4) '-Binary Image']);
% watershed
bw_complement=imcomplement(bw);
L = watershed(bw_complement);
Lrgb = label2rgb(L);
fig3=figure(3);imshow(Lrgb);
% % particle properties 
% s=regionprops(bw, image, 'all');
% % label all the clusters
% fig3=figure(3);
% imshow(image);
% title('Identified particles');
% hold on
% numObj = numel(s);
% for k = 1 : numObj
%     plot(s(k).WeightedCentroid(1), s(k).WeightedCentroid(2), 'r*');
%     text(s(k).Centroid(1),s(k).Centroid(2), ...
%         sprintf('%4d', k), ...
%         'Color','r');
% end
% hold off
% 
% % reduce the dimension by principal component analysis(PCA) 
% %
% % set a filter


