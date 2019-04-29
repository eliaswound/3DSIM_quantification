% This script is used to analyze all the cells in a field of view

% step 1: import the image you want to analyze.
% step 2: adjust the treshold to get a better contrast.
%  While true 
%   step 3: use freedraw tools to define the contour of the cell, crop and
%         save as a seperate image 
%   step 4: use click tool to get the coordinate of sensory like structure?
%         save the coordinate
%   step 5: calculate the basal body number in the cell,save data
%   step 6: calculate the cilia diretion in the cell,save data
%   step 7: calculate the relative position of the sensory like cilia in the
%         cell,save data
%  end
% step 8: plot the basal body direction and sensory like cilia position on top of the
%          cell
% step 11: save all the information for subsequent analysis

%--------------------------------------------------------------------------
% step 12: put the cells you are interested in a cell
% step 13: statistic analysis of all the paramters obtained
clear;close all;clc;

% step 1: import the image you want to analyze.
    [FileName,PathName]=uigetfile({'*.tif';'*.tiff';'*.png';'*.jpeg';'*.bmp'},'Select the image file');
    cd(PathName);
    image=imread(FileName);
    red=image(:,:,1);
    green=image(:,:,2);
% step 2: adjust the treshold to get a better contrast.
    scrsz = get(0,'ScreenSize');
    fig11=figure('Position',[1 1 scrsz(3) scrsz(4)]);
    imagesc(red)
    axis equal;
    imcontrast
% step 3: use freedraw tools to define the contour of the cell, crop and
%         save as a seperate image 
%         maybe a large display screen works better
   h_red=imfreehand;
   red_binary=createMask(h_red);
   s_red=regionprops(red_binary, red, 'WeightedCentroid','Area','BoundingBox','PixelIdxList');
   red_chosen=red;
   green_chosen=green;
   [a,b]=size(red);
   index_exclude=setdiff((1:1:a*b)',s_red.PixelIdxList);
   red_chosen(index_exclude)=0;
   green_chosen(index_exclude)=0;
   figure;
   imagesc(red_chosen);
   [I,J]=ind2sub(size(red),s_red.PixelIdxList);
   y_lower=min(I);y_upper=max(I);
   x_lower=min(J);x_upper=max(J);
   red_chosen_roi=red_chosen(y_lower:y_upper,x_lower:x_upper);
   image_chosen(:,:,1)=red_chosen;
   image_chosen(:,:,2)=green_chosen;
   image_chosen(:,:,3)=zeros(a,b);
   chosen_roi=image_chosen(y_lower:y_upper,x_lower:x_upper,:);
   centroid=[s_red.WeightedCentroid(1)-x_lower+1,s_red.WeightedCentroid(2)-y_lower+1];
   imwrite(chosen_roi,'Test.tiff','tiff', 'Compression', 'none', 'WriteMode',  'overwrite');
   figure
   imagesc(chosen_roi)
   axis equal
%    figure
%    
%    rotation
%    
%    imshow(chosen_roi(:,:,2))
%    [sensory_x,sensory_y]=ginput; % there may be multiple sensory like structure in the cell
   save('matlab.mat')

% calculate the direction 
% calculate the number of cilia in the cell

% calculate the sensory cilia like structure position
