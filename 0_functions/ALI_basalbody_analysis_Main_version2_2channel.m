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
    info=imfinfo(FileName);
    num_images=numel(info);
 for k = 1:num_images
     SpecificFrameImage=imread(FileName, k, 'Info', info);
     image(:,:,k)=SpecificFrameImage;
 end
    red=image(:,:,1);
    red_copy=red;
    green=image(:,:,2);
    [a1,b1]=size(red);
    image(:,:,3)=zeros(a1,b1);
    green_copy=green;
% step 2: adjust the image to define a global threshold.

    scrsz = get(0,'ScreenSize');
    hfigure1=imtool(red_copy);
    set(hfigure1,'Position',[10 45 scrsz(3)/2 scrsz(4)-150]);
    hfigure2=imcontrast(hfigure1);
    set(hfigure2,'position',[scrsz(3)/2 scrsz(4)/4 scrsz(3)/2 scrsz(4)/2])
    uiwait(hfigure2);
    red_modified=getimage(imgca);
    close(hfigure1)
    hfigure1=imtool(green_copy);
    set(hfigure1,'Position',[10 45 scrsz(3)/2 scrsz(4)-150]);
    hfigure2=imcontrast(hfigure1);
    set(hfigure2,'position',[scrsz(3)/2 scrsz(4)/4 scrsz(3)/2 scrsz(4)/2])
    uiwait(hfigure2);
    green_modified=getimage(imgca);
    close(hfigure1)
    figure_contrast=figure('Position',[10 45 scrsz(3)/2 scrsz(4)-150]);
    subplot(2,2,1)
    imshow(red);title('red channel raw data');
    subplot(2,2,2)
    imshow(red_modified);title('red channel adusted contrast');
    subplot(2,2,3)
    imshow(green);title('green channel raw data');
    subplot(2,2,4)
    imshow(green_modified);title('green channel adusted contrast');
    saveas(figure_contrast,[FileName(1:end-4) '_contrastadjustment.fig'],'fig');
    
    % finding the threshold based on the raw image and modified image
    Index_red=setdiff(find(red_modified==0),find(red==0));
    threshold(1)=max(max(red(Index_red)));
    Index_green=setdiff(find(green_modified==0),find(green==0));
    threshold(2)=max(max(green(Index_green)));
    
           
% step 3: use freedraw tools to define the contour of the cell, crop and
%         save as a seperate image 
  i=1;
  finish=1;
  image_modified(:,:,1)=red_modified;
  image_modified(:,:,2)=green_modified;
  image_modified(:,:,3)=image(:,:,3);
  cell_centroid=[];
  while finish~=0 
  h=figure(100); clf;
  set(h,'position',[1 1 scrsz(3) scrsz(4)]);
  hold on 
  imshow(autocontrast(image))
  if i>=2
      for j=1:i-1
          text(cell_centroid(j,1),cell_centroid(j,2),['\color{blue} cell'  num2str(j)],'FontSize',15);
      end          
  end
  uicontrol('Style', 'pushbutton', 'String', 'Freedraw',...
        'Position', [20 20 50 20],...
        'Callback', 'h_red=imfreehand;finish=1');  
  uicontrol('Style', 'pushbutton', 'String', 'Zoom',...
        'Position', [20 340 50 20],...
        'Callback', 'zoom');       
  uicontrol('Style', 'pushbutton', 'String', 'Pan',...
        'Position', [20 500 50 20],...
        'Callback', 'pan');  
  uicontrol('Position',[20 600 50 20],'String','This is the last',...
              'Callback','h_red=imfreehand;finish=0'); 
%   uicontrol('Position',[20 100 50 20],'String','Zhen',...
%               'Callback','clear');         
  uiwait(gcf);  
  red_binary=createMask(h_red);
  s_red=regionprops(red_binary, red, 'Centroid','Area','BoundingBox','PixelIdxList');
  area_list=[];
  for q=1:length(s_red);
      area_list=[area_list;s_red(q).Area];
  end
  [s_area,s_index]=max(area_list);
  s_red_chosen=s_red(s_index);
  cell_centroid=[cell_centroid;s_red_chosen.Centroid];
  red_chosen=red;
  green_chosen=green;
  [a,b]=size(red);
  index_exclude=setdiff((1:1:a*b)',s_red_chosen.PixelIdxList);
  red_chosen(index_exclude)=0;
  green_chosen(index_exclude)=0;
  figure(101);
  imagesc(red_chosen);
  [I,J]=ind2sub(size(red),s_red_chosen.PixelIdxList);
  y_lower=min(I);y_upper=max(I);
  x_lower=min(J);x_upper=max(J);
   red_chosen_roi=red_chosen(y_lower:y_upper,x_lower:x_upper);
   image_chosen(:,:,1)=red_chosen;
   image_chosen(:,:,2)=green_chosen;
   image_chosen(:,:,3)=zeros(a,b);
   chosen_roi=image_chosen(y_lower:y_upper,x_lower:x_upper,:);
   centroid=[s_red_chosen.Centroid(1)-x_lower+1,s_red_chosen.Centroid(2)-y_lower+1];
   imageName=[FileName(1:end-4) '_croppedcell_' num2str(i) '.tiff'];
   imwrite(chosen_roi,imageName,'tiff', 'Compression', 'none', 'WriteMode',  'overwrite');
   imageName_red=[FileName(1:end-4) '_croppedcell_red_' num2str(i) '.tiff'];
   imwrite(chosen_roi(:,:,1),imageName_red,'tiff', 'Compression', 'none', 'WriteMode',  'overwrite');
   
% calculate the direction 
try
    [p_value,mean_direction,all_directions]=basalbody_direction_func(imageName,threshold); % automatic threshold setting
    % calculate the number of cilia in the cell
    basalbody_number=basalbody_number_func(imageName_red);% automatic threshold setting
    % calculate the sensory cilia like structure position
    cell_main.threshold=threshold;
    cell_main.centroid=s_red_chosen.Centroid;
    cell_main.p_value=p_value;
    cell_main.mean_direction=mean_direction;
    cell_main.all_directions=all_directions;
    cell_main.basalbody_number=basalbody_number;
%     if p_value<0.05
%     [x_distance_norm,y_distance_norm]=sensorycilia_position_func(imageName,90-(mean_direction/pi*180),centroid);
%     cell_main.x_distance=x_distance_norm;
%     cell_main.y_distance=y_distance_norm;
%     end
    cellname=[FileName(1:end-4) '_croppedcell_' num2str(i) '_main_information.mat'];   
    save(cellname,'cell_main')
    clear cell_main
    close(figure(101));
    
    clear h_red
catch
%     [p_value,mean_direction,all_directions]=basalbody_direction_func(imageName); % automatic threshold setting
%     % calculate the number of cilia in the cell
%     basalbody_number=basalbody_number_func(imageName_red);% automatic threshold setting
%     % calculate the sensory cilia like structure position
%     cell_main.threshold=threshold;
%     cell_main.p_value=p_value;
%     cell_main.mean_direction=mean_direction;
%     cell_main.all_directions=all_directions;
%     cell_main.basalbody_number=basalbody_number;
%     if p_value<0.05
%     [x_distance_norm,y_distance_norm]=sensorycilia_position_func(imageName,90-(mean_direction/pi*180),centroid);
%     cell_main.x_distance=x_distance_norm;
%     cell_main.y_distance=y_distance_norm;
%     end
%     cellname=[FileName(1:end-4) '_croppedcell_' num2str(i) '_main_information.mat'];   
%     save(cellname,'cell_main')
%     clear cell_main
%     close(figure(101));
%     
%     clear h_red
    
end
   i=i+1;

  end
figure(100);  
text(cell_centroid(i-1,1),cell_centroid(i-1,2),['\color{blue} cell'  num2str(i-1)],'FontSize',15);
saveas(figure(100),[FileName(1:end-4) '_ChosenCells.fig'],'fig');
save([FileName(1:end-4) 'main.mat']);


