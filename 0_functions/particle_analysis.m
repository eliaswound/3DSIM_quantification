clear;close all;clc;
% MATLAB version particle analysis
[FileName,PathName]=uigetfile({'*.tif';'*.tiff';'*.png';'*.jpeg';'*.bmp'},'Select the image file');
cd(PathName);
image=imread(FileName);
% show figure
fig1=figure(1);imshow(image);
title(FileName)
% various ways can be used to set the range.
% method 1
% background=mean(mean(single(image)));
% noise=std(std(single(image)));
% treshold=background+4*noise;
% level=treshold/255; % for 8 bit image
% method 2
level=graythresh(image);
% method 3
% user defined level
% binary image
bw = im2bw(image,level);
fig2=figure(2);imshow(bw);
title([FileName(1:end-4) '-Binary Image']);
% particle properties 
s=regionprops(bw, image, 'all');
% label all the clusters
fig3=figure(3);
imshow(image);
title('Identified particles');
hold on
numObj = numel(s);
parameters=[];
for k = 1 : numObj
    plot(s(k).WeightedCentroid(1), s(k).WeightedCentroid(2), 'r*');
    text(s(k).WeightedCentroid(1),s(k).WeightedCentroid(2), ...
        sprintf('%4d', k), ...
        'Color','r');
    parameter=[k,s(k).Area,s(k).Perimeter,s(k).MajorAxisLength,s(k).MinorAxisLength,...
        s(k).Orientation];
    parameters=[parameters;parameter];
    clear parameter
end
hold off


% reduce the dimension by principal component analysis(PCA) 
%
% set a filter
% data normalization
% paramters structure
% column 1: object number;
% column 2: object area
% column 3: object perimeter
% column 4: object major axis length
% column 5: object minor axis length
% column 6: object orientation
% column 7: object major minor axis length ratio
parameters(:,7)=parameters(:,4)./parameters(:,5);
figure()
categories={'Area','Perimeter','Major Axis Length','Minor Axis Length','Orientation','Major/Minor'};
boxplot(parameters(:,2:7),'orientation','horizontal','labels',categories);
% parameters_normalization(:,1)=parameters(:,1);
% parameters_normalization(:,2)=(parameters(:,2)-mean(parameters(:,2)))/mean(parameters(:,2));
% parameters_normalization(:,3)=(parameters(:,3)-mean(parameters(:,3)))/mean(parameters(:,3));
% parameters_normalization(:,4)=(parameters(:,4)-mean(parameters(:,4)))/mean(parameters(:,4));
% parameters_normalization(:,5)=(parameters(:,5)-mean(parameters(:,5)))/mean(parameters(:,5));
% parameters_normalization(:,6)=(parameters(:,6)-mean(parameters(:,6)))/mean(parameters(:,6));
% parameters_normalization(:,7)=(parameters(:,7)-mean(parameters(:,7)))/mean(parameters(:,7));
% 
% [COEFF,SCORE]=princomp(parameters_normalization(:,2:7),'VariableWeights','variance');
% figure()
% plot(SCORE(:,1),SCORE(:,2),'+')
% xlabel('1st Principal Component')
% ylabel('2nd Principal Component')
area_limit=quantile(parameters(:,2),0.95);
index=find(parameters(:,2)>=area_limit);
correct=round(sum(parameters(index,2)/median(parameters(:,2))))-length(index);
particle_number_unnormalized=length(parameters);
particle_number_normalized=particle_number_unnormalized+correct;

