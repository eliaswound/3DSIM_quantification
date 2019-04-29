%--------------------------------------------------------------------------
% PCD_diagnosis
%--------------------------------------------------------------------------
% This MATLAB script is written for PCD_diagnosis data analysis. It will
% calculate a series of parameters including PCD protein intensity, tubulin
% intensity, PCD protein/tubulin colocalization for subsequent Principle
% Component Analysis &Machine Learning Use 
%--------------------------------------------------------------------------
% Input: a 2 color image ended with .ome.tiff   
%        the green signal represents PCD protein
%        the red signal represents tubulin
% Outputs: 
%         tiff file
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
% Feb 13th, 2017
%--------------------------------------------------------------------------
% 1. Only the green channel(for instance DNAH11) and red channel(for instance 
%    a tubulin) is needed.
% 2. The integrated DNAH11 intensity in the entire cilia is also calculated.  
% 3. Adding the free draw tool instead to replace the threshold setting
%    tool.
% Revised Feb 22th, 2017
% Adding the manual contrast tool
%--------------------------------------------------------------------------
% To change the quantification method suitable for 3D colocalization
% 1. Use median image of all frames to define a threshold   
% 2. Use the max image of all frames to define the maximum boundary of the cells
% 3. For each frame, For each pixel in the maxium boundary of the cells, if its intensity is above the
%    threshold defined, consider it belongs to the cell region. Add the
%    intensity to the sum intensity of its corresponding channel
% 4. For each pixel, if both the green and red intensity are above the corresponding
%    channels, the green and red signal are colocalized. 
% Revised March 28th,2017
%--------------------------------------------------------------------------
% Version 4.0
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------
 clear;close all;clc;
%--------------------------------------------------------------------------
% image format processing and saving
%--------------------------------------------------------------------------
 [FileName,PathName]=uigetfile({'*.ome.tiff';'*.ome.tif';'*.tif';'*.tiff'},...
                                                  'Select the image file');
 cd(PathName);
% load the tiff file
 info = imfinfo(FileName);
 num_images = numel(info);
 movie_raw=[];
 for k = 1:num_images
     SpecificFrameImage=imread(FileName, k, 'Info', info);
     movie_raw(:,:,k)=SpecificFrameImage;
 end
% seperate channels
 red_raw=movie_raw(:,:,1:1:end/2);
 green_raw=movie_raw(:,:,end/2+1:1:end);
% sum of seperate channels

%red_raw_sum=sum(red_raw,3);   
%green_raw_sum=sum(green_raw,3);

%data_red=uint32(red_raw_sum);
%data_green=uint32(green_raw_sum);

%t_red=Tiff([FileName(1:end-9) '_red_sum.tif'],'w');
%t_green=Tiff([FileName(1:end-9) '_green_sum.tif'],'w');

% Setup tags
% Lots of information here:
% http://www.mathworks.com/help/matlab/ref/tiffclass.html
% tagstruct.ImageLength=size(data_red,1);
% tagstruct.ImageWidth=size(data_red,2);
% tagstruct.Photometric=Tiff.Photometric.MinIsBlack;
% tagstruct.BitsPerSample=32;
% tagstruct.SamplesPerPixel=1;
% tagstruct.RowsPerStrip=16;
% tagstruct.PlanarConfiguration=Tiff.PlanarConfiguration.Chunky;
% tagstruct.Software='MATLAB';
% t_red.setTag(tagstruct); t_green.setTag(tagstruct); 
% 
% t_red.write(data_red); t_red.close();
% t_green.write(data_green); t_green.close();
% [m,n]=size(green_raw_sum);



%--------------------------------------------------------------------------
% Optimizing threshold for each color channel
%--------------------------------------------------------------------------
% red
%--------------------------------------------------------------------------
% setting the threshold for the red
red_raw_median=median(red_raw,3);   %  calculate the median image of the red
%red_raw_median_normalize=single(red_raw_median)/single(2^16);
scrsz = get(0,'ScreenSize');
hfigure1=imtool(red_raw_median);
set(hfigure1,'Position',[10 45 scrsz(3)/2 scrsz(4)-150]);
hfigure2=imcontrast(hfigure1);
set(hfigure2,'position',[scrsz(3)/2 scrsz(4)/4 scrsz(3)/2 scrsz(4)/2])
uiwait(hfigure2);
red_modified=getimage(imgca);
close(hfigure1);
Index_red=setdiff(find(red_modified==0),find(red_raw_median==0));
threshold_red=max(max(red_raw_median(Index_red)));
%threshold_red=threshold*(2^16);
%--------------------------------------------------------------------------
% green
%--------------------------------------------------------------------------
% setting the threshold for the green
green_raw_median=median(green_raw,3);   %  calculate the median image of the red
%green_raw_median_normalize=single(green_raw_median)/(2^16);
scrsz = get(0,'ScreenSize');
hfigure1=imtool(green_raw_median);
set(hfigure1,'Position',[10 45 scrsz(3)/2 scrsz(4)-150]);
hfigure2=imcontrast(hfigure1);
set(hfigure2,'position',[scrsz(3)/2 scrsz(4)/4 scrsz(3)/2 scrsz(4)/2])
uiwait(hfigure2);
green_modified=getimage(imgca);
close(hfigure1);
Index_green=setdiff(find(green_modified==0),find(green_raw_median==0));
threshold_green=max(max(green_raw_median(Index_green)));
%--------------------------------------------------------------------------
% Define the maximum boundary of the green channel and red channel
%--------------------------------------------------------------------------
% both the red and green channel should be used to define the maximum
% boundary
%--------------------------------------------------------------------------
% red boundary first
%--------------------------------------------------------------------------
red_raw_max=max(red_raw,[],3);   

h=figure(100); clf;
set(h,'position',[1 1 scrsz(3) scrsz(4)]);
imshow(autocontrast(red_raw_max));
%hfigure_contrast=imcontrast(h);
%set(hfigure_contrast,'position',[scrsz(3)/2 scrsz(4)/4 scrsz(3)/2 scrsz(4)/2])
h_boundary_red=imfreehand;
maximum_boundary_red=createMask(h_boundary_red);

%--------------------------------------------------------------------------
% green boundary second
%--------------------------------------------------------------------------
green_raw_max=max(green_raw,[],3);
figure(100); clf;
imshow(autocontrast(green_raw_max));
%hfigure_contrast=imcontrast(h);
%set(hfigure_contrast,'position',[scrsz(3)/2 scrsz(4)/4 scrsz(3)/2 scrsz(4)/2])
h_boundary_green=imfreehand;
maximum_boundary_green=createMask(h_boundary_green);

%--------------------------------------------------------------------------
% use the maximum boundary and threshold to go through all the frames to
% extract the data
%--------------------------------------------------------------------------
% choose the largest boundary of course 
%-------------------------------
% red first
binary_props_red=regionprops(maximum_boundary_red, 'PixelIdxList','Area','Perimeter');
area_list_red=[];
for p=1:length(binary_props_red);
    area_list_red=[area_list_red;binary_props_red(p).Area];
end
[s_area_red,s_index_red]=max(area_list_red);
binary_props_red_largest=binary_props_red(s_index_red);
InboundaryIndexlist_red=binary_props_red.PixelIdxList;
contour_red_all=bwboundaries(maximum_boundary_red);
contour_red_largest=contour_red_all(s_index_red,1);

% green second
binary_props_green=regionprops(maximum_boundary_green, 'PixelIdxList','Area','Perimeter');
area_list_green=[];
for q=1:length(binary_props_green);
    area_list_green=[area_list_green;binary_props_green(q).Area];
end
[s_area_green,s_index_green]=max(area_list_green);
binary_props_green_largest=binary_props_green(s_index_green);
InboundaryIndexlist_green=binary_props_green.PixelIdxList;
contour_green_all=bwboundaries(maximum_boundary_green);
contour_green_largest=contour_green_all(s_index_green,1);
figure(101)
merge_max(:,:,1)=red_raw_max;
merge_max(:,:,2)=green_raw_max;
[d1,d2]=size(red_raw_max);
merge_max(:,:,3)=zeros(d1,d2);
imshow(autocontrast(merge_max));
hold on
red_bound_coor=contour_red_largest{1,1};
plot(red_bound_coor(:,2),red_bound_coor(:,1),'r-');
green_bound_coor=contour_green_largest{1,1};
plot(green_bound_coor(:,2),green_bound_coor(:,1),'g-');

% somewhere to define the pixel size / 80 nm per pixel

% frame_all=[];
red_pixel_sum=0;
red_intensity_sum=0;

green_pixel_sum=0;
green_intensity_sum=0;

pixeloverlap_sum=0;
redoverlapintensity_sum=0;
greenoverlapintensity_sum=0;

cell_volume=0;

%[x y z]=size(red_raw);


%red_all=[];
%green_all=[];

for i=1:num_images/2
    %frame_all=[frame_all;i];
    red_temp=red_raw(:,:,i);
    green_temp=green_raw(:,:,i);
    % Identify the pixel ID in the red-temp with the pixel value above
    % threshold
    red_index_refer=find(red_temp(InboundaryIndexlist_red)>threshold_red);
    red_index=InboundaryIndexlist_red(red_index_refer);
    % Refresh the parameters of the red parts
    red_pixel_temp=length(red_index);
    red_pixel_sum=red_pixel_sum+red_pixel_temp;
    red_intensity_temp=sum(red_temp(red_index));
    red_intensity_sum=red_intensity_sum+red_intensity_temp;
    clear red_pixel_temp red_intensity_temp
    
    %[y_coord_red,x_coord_red]=ind2sub(size(red_temp),red_index);
    %red_all=[red_all;x_coord_red,y_coord_red,double(i*ones(length(red_index),1)),double(red_temp(red_index))];
    
    
    % Identify the pixel ID of in the green-temp with the pixel value above
    % threshold
    green_index_refer=find(green_temp(InboundaryIndexlist_green)>threshold_green);
    green_index=InboundaryIndexlist_green(green_index_refer);
    % Refresh the parameters of the green parts
    green_pixel_temp=length(green_index);
    green_pixel_sum=green_pixel_sum+green_pixel_temp;
    green_intensity_temp=sum(green_temp(green_index));
    green_intensity_sum=green_intensity_sum+green_intensity_temp; 
    clear green_pixel_temp green_intensity_temp 
    %[y_coord_green,x_coord_green]=ind2sub(size(green_temp),green_index);
    %green_all=[green_all;x_coord_green,y_coord_green,double(i*ones(length(green_index),1)),double(green_temp(green_index))];
    % Get the ?? and ?? of the Red Index and Green Index identified above
    red_green_intersect=intersect(red_index, green_index);
    red_green_union=union(red_index, green_index);
    % Calculate the colocalization part     
%    if ~isempty(length(red_green_intersect))
    pixeloverlap_temp=length(red_green_intersect);
    redoverlapintensity_temp=sum(red_temp(red_green_intersect));
    greenoverlapintensity_temp=sum(green_temp(red_green_intersect));  
%    else
%     pixeloverlap_temp=0; 
%     redoverlapintensity_temp=0;
%     greenoverlapintensity_temp;
%    end
    pixeloverlap_sum=pixeloverlap_sum+pixeloverlap_temp;
    redoverlapintensity_sum=redoverlapintensity_sum+redoverlapintensity_temp;
    greenoverlapintensity_sum=greenoverlapintensity_sum+greenoverlapintensity_temp;
    clear redoverlapintensity_temp greenoverlapintensity_temp
    clear red_green_intersect
   %and the volume of the cell 
    cell_volume=cell_volume+length(red_green_union);
    clear red_green_union
   
end

%[I,J]=ind2sub(size(green_temp),InboundaryIndexlist_green);


%[I2,J2]=ind2sub(size(green_temp),green_index);

% save all the parameters obtained above
% save the workspace for future check.

% overlap area % red signal area
 OverlapAreaDividedByRed=pixeloverlap_sum/red_pixel_sum;
% overlap red integrated intensity/red integrated intensity
 RedOverlapIntensityRatio=redoverlapintensity_sum/red_intensity_sum;
% overlap green integrated intensity/green integrated intensity
 GreenOverlapIntensityRatio=greenoverlapintensity_sum/green_intensity_sum;
 
% green_integrated_intensity_cilia
 green_integrated_intensity_cilia=greenoverlapintensity_sum;
%--------------------------------------------------------------------------
% data saving
%--------------------------------------------------------------------------
data.threshold=[threshold_red,threshold_green];
data.cell_volume=cell_volume;
data.DNAH11_integratedintensity=green_intensity_sum;
data.tubulin_integratedintensity=red_intensity_sum;
data.DNAH11_cilia_integratedintensity=green_integrated_intensity_cilia; 
data.colocalization_RedOverlapArea=OverlapAreaDividedByRed;
data.colocalization_RedOverlapIntIntensityRatio=RedOverlapIntensityRatio;
data.colocalization_GreenOverlapIntIntensityRatio=GreenOverlapIntensityRatio;
%data.threshold=[level_red,level_green];
save([FileName(1:end-9) '_PCD_diagnosis_requireddata.mat'],'data','-v7.3');
save([FileName(1:end-9) '_PCD_diagnosis_rawdata.mat'],'-v7.3');

saveas(figure(101),[FileName(1:end-9) '_maxcontour.fig'],'fig');

% an additional z plot to show the cell/the red/ green









