%--------------------------------------------------------------------------
% PCD_diagnosis
%--------------------------------------------------------------------------
% This MATLAB script is written for PCD_diagnosis data analysis. It will
% calculate a series of parameters including DNAH11 intensity, tubulin
% intensity, DNAH11/tubulin colocalization for subsequent Principle
% Component Analysis &Machine Learning Use 
%--------------------------------------------------------------------------
% Input: a 3 color image ended with .ome.tiff
%        the blue signal represents the nucleus 
%        the green signal represents DNAH11
%        the red signal represents tubulin
% Outputs: 
%         tiff file
%          FileName(1:end-9)_blue_sum.tif
%          FileName(1:end-9)_green_sum.tif
%          FileName(1:end-9)_red_sum.tif
%         figure
%          identified contour displayed on the image
%         data
%          the calculated paramters
%         workspace         
%          workspace contained all the raw data
%--------------------------------------------------------------------------
% Zhen Liu
% liuzhorizon@gmail.com
% September 2nd, 2016
%--------------------------------------------------------------------------
% Version 1.0
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------
 clear;close all;clc;
%--------------------------------------------------------------------------
% image format processing and saving
%--------------------------------------------------------------------------
 [FileName,PathName]=uigetfile({'*.ome.tiff';'*.tif';'*.tiff'},...
                                                  'Select the image file');
 cd(PathName);
% load the tiff file
 info = imfinfo(FileName);
 num_images = numel(info);
 for k = 1:num_images
     SpecificFrameImage=imread(FileName, k, 'Info', info);
     movie_raw(:,:,k)=SpecificFrameImage;
 end
% seperate channels
 red_raw=movie_raw(:,:,1:k/3);
 green_raw=movie_raw(:,:,(k/3+1):2*k/3);
 blue_raw=movie_raw(:,:,(2*k/3+1):end);
% sum of seperate channels
red_raw_sum=sum(red_raw,3);   
green_raw_sum=sum(green_raw,3);
blue_raw_sum=sum(blue_raw,3);
data_red=uint32(red_raw_sum);
data_green=uint32(green_raw_sum);
data_blue=uint32(blue_raw_sum);
t_red=Tiff([FileName(1:end-9) '_red_sum.tif'],'w');
t_green=Tiff([FileName(1:end-9) '_green_sum.tif'],'w');
t_blue=Tiff([FileName(1:end-9) '_blue_sum.tif'],'w');
% Setup tags
% Lots of information here:
% http://www.mathworks.com/help/matlab/ref/tiffclass.html
tagstruct.ImageLength=size(data_red,1);
tagstruct.ImageWidth=size(data_red,2);
tagstruct.Photometric=Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample=32;
tagstruct.SamplesPerPixel=1;
tagstruct.RowsPerStrip=16;
tagstruct.PlanarConfiguration=Tiff.PlanarConfiguration.Chunky;
tagstruct.Software='MATLAB';
t_red.setTag(tagstruct); t_green.setTag(tagstruct); 
t_blue.setTag(tagstruct);
t_red.write(data_red); t_red.close();
t_green.write(data_green); t_green.close();
t_blue.write(data_blue); t_blue.close();
%--------------------------------------------------------------------------
% Optimizing threshold for each color channel
%--------------------------------------------------------------------------
% blue
%--------------------------------------------------------------------------
figure(1); clf;
imagesc(blue_raw_sum/max(max(single(blue_raw_sum)))); 
axis equal;colorbar;
judgement=0;
while judgement~=1
    level=input('please input the threshold');
    [level_blue,bw_blue,bw2_blue,B_blue,L_blue,max_I_blue,fig1_blue,...
        fig2_blue,fig3_blue,fig4_blue,...
        object_largest2_blue]=PCD_diagnosis_contour(blue_raw_sum,level);
    judgement=input('Are you satisfied with the results? \n 1 for satisfied, 0 for unsatisfied');
end
%--------------------------------------------------------------------------
% red
%--------------------------------------------------------------------------
figure(1); clf;
imagesc(red_raw_sum/max(max(single(red_raw_sum)))); 
axis equal;colorbar;
judgement=0;
while judgement~=1
    level_red=input('please input the threshold');
    [level_red,bw_red,bw2_red,B_red,L_red,max_I_red,fig1_red,...
        fig2_red,fig3_red,fig4_red,...
        object_largest2_red]=PCD_diagnosis_contour(red_raw_sum,level_red);
    judgement=input('Are you satisfied with the results? \n 1 for satisfied, 0 for unsatisfied');
end

%--------------------------------------------------------------------------
% green
%--------------------------------------------------------------------------
figure(1);clf;
imagesc(green_raw_sum/max(max(single(green_raw_sum)))); 
axis equal;colorbar;
judgement=0;
while judgement~=1
    level_green=input('please input the threshold');
    [level_green,bw_green,bw2_green,B_green,L_green,max_I_green,fig1_green,...
        fig2_green,fig3_green,fig4_green,...
        object_largest2_green]=PCD_diagnosis_contour(green_raw_sum,level_green);
    judgement=input('Are you satisfied with the results? \n 1 for satisfied, 0 for unsatisfied');
end

%--------------------------------------------------------------------------
% display the identified contours
%--------------------------------------------------------------------------
figure(5)
sum_integrate_normalize(:,:,1)=red_raw_sum/max(max(single(red_raw_sum)));
sum_integrate_normalize(:,:,2)=green_raw_sum/max(max(single(green_raw_sum)));
sum_integrate_normalize(:,:,3)=blue_raw_sum/max(max(single(blue_raw_sum))); 
imagesc(sum_integrate_normalize);axis equal;
hold on
boundary_largest_red=B_red{max_I_red};
boundary_largest_green=B_green{max_I_green};
boundary_largest_blue=B_blue{max_I_blue};
plot(boundary_largest_red(:,2),...
               boundary_largest_red(:,1),'r','LineWidth',2);
plot(boundary_largest_green(:,2),...
               boundary_largest_green(:,1),'g','LineWidth',2);
plot(boundary_largest_blue(:,2),...
               boundary_largest_blue(:,1),'b','LineWidth',2);

%--------------------------------------------------------------------------
% measurements
%--------------------------------------------------------------------------
% measure the size of the nucleous
%--------------------------------------------------------------------------
nucleus=find(object_largest2_blue);
nucleus_area=length(nucleus); % unit pixel^2
%--------------------------------------------------------------------------
% measure the size of the cell
%--------------------------------------------------------------------------
cell_index=find(object_largest2_green|object_largest2_red);
[m,n]=size(object_largest2_red);
cell_contour=zeros(m,n);
cell_contour(cell_index)=1;
cell_contour=logical(cell_contour);
scrsz = get(0,'ScreenSize');
fig6=figure(6);
imshow(cell_contour)
cell_area=length(cell_index);
truesize(fig6,[scrsz(3)/4,scrsz(4)/4])
%--------------------------------------------------------------------------
% measure the paramter of the cell
%--------------------------------------------------------------------------
cell_contour=imfill(cell_contour,'holes');    
temp=regionprops(cell_contour, 'Perimeter');    
cell_perimeter=temp.Perimeter;
%--------------------------------------------------------------------------
% measure the intensity of the green signal
%--------------------------------------------------------------------------
green_index=find(object_largest2_green);
green_integrated_intensity=sum(green_raw_sum(green_index));
green_area=length(green_index);
%--------------------------------------------------------------------------
% measure the intensity of the red signal
%--------------------------------------------------------------------------
red_index=find(object_largest2_red);
red_integrated_intensity=sum(red_raw_sum(red_index));
red_area=length(red_index);
%--------------------------------------------------------------------------
% measure the colocalization/pixel overlap between the red and green signal
%--------------------------------------------------------------------------
red_green_overlap_index=find(object_largest2_red&object_largest2_green);
red_green_overlap_area=length(red_green_overlap_index);
overlap_red_integrated_intensity=sum(red_raw_sum(red_green_overlap_index));
overlap_green_integrated_intensity=sum(green_raw_sum(red_green_overlap_index));
% overlap area % red signal area
OverlapAreaDividedByRed=red_green_overlap_area/red_area;
% overlap red integrated intensity/red integrated intensity
RedOverlapIntensityRatio=overlap_red_integrated_intensity/red_integrated_intensity;
% overlap green integrated intensity/green integrated intensity
GreenOverlapIntensityRatio=overlap_green_integrated_intensity/green_integrated_intensity;
%--------------------------------------------------------------------------
% data saving
%--------------------------------------------------------------------------
data.nucleus_area=nucleus_area;
data.cell_area=cell_area;
data.cell_perimeter=cell_perimeter;
data.DNAH11_integratedintensity=green_integrated_intensity;
data.tubulin_integratedintensity=red_integrated_intensity;
data.colocalization_RedOverlapArea=OverlapAreaDividedByRed;
data.colocalization_RedOverlapIntIntensityRatio=RedOverlapIntensityRatio;
data.colocalization_GreenOverlapIntIntensityRatio=GreenOverlapIntensityRatio;
data.threshold=[level_red,level_green,level_blue];
saveas(figure(5),[FileName(1:end-9) '_optimizedcontour.fig'],'fig');
save([FileName(1:end-9) '_PCD_diagnosis_requireddata.mat'],'data');









