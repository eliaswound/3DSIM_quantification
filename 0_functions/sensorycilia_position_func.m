% sensory cilia position
function [x_distance_norm,y_distance_norm]=sensorycilia_position_func(imageName,cell_direction,centroid)

% Analyze the relative position of the sensory like structure in the whole
% cell
% input
%  1.1 the cell image: a RGB 8 bit image. 
%                      Red channel for poc1B
%                      Green channel for centriolin
%  1.2 the direction of the cell determined by the cilia direction
%  1.3 the centroid of the cell determined by the cell

% step 1:    based on the direction and centroid, rotate the cells;
image=imread(imageName);
figure(3000);clf;
subplot(1,3,1);
imshow(image);
axis equal;
title('before rotation')
% get the centroid of the cell
% get the center of the image
[a,b]=size(image(:,:,1));
center=[(b+1)/2,(a+1)/2];
% image translation: move the centroid of the cell to the center of the
%                    image
translate_direction=[center(1)-centroid(1),center(2)-centroid(2)];

image_translate= imtranslate(image,[translate_direction,0],0,'linear',0);

subplot(1,3,2);
imshow(image_translate);
axis equal;
title('image translation')
% image rotation?
image_translate_rotate=imrotate(image_translate,cell_direction,'bicubic','loose'); % need to change to the cilia direction 
%image_translate_rotate(:,:,3)=zeros(a,b);

subplot(1,3,3);

imshow(image_translate_rotate);
axis equal;
title('image translation rotate')

% step 2:    ginput to get the position of the sensory like structure;
% step 3:    get the position relative to the centre of the cell;
% step 4:    save all the parameters;
% step 5:    plot the position of sensory cilia on the rotated image;


% change the contrast of the image to help it identify the sensory cilia
% image more easily
h=figure(3001);clf;
scrsz = get(0,'ScreenSize');
set(h,'position',[scrsz(3)/4 scrsz(4)/4 scrsz(3)/2 scrsz(4)/2])
output_img=image_translate_rotate;
output_img(:,:,2)=autocontrast(image_translate_rotate(:,:,2));
imshow(output_img)
hold on
[sensory_x,sensory_y] = ginput;
hold on
% save
% plot
[a2,b2]=size(image_translate_rotate(:,:,1));
center=[(b2+1)/2,(a2+1)/2];
plot([center(1),center(1)],[1,a2],'b-')
plot([1,b2],[center(2),center(2)],'b-')
scatter(sensory_x,sensory_y,30,'ys')
for i=1:length(sensory_x)
    x_distance(i,1)=sensory_x(i)-center(1);
    y_distance(i,1)=sensory_y(i)-center(2);
    quiver(center(1),center(2),x_distance(i,1),y_distance(i,1),0)
end

% find the width and height of the cell in the direction of the cilia

% get the contour of the cell
 rotated_red=image_translate_rotate(:,:,1);
 index=find(rotated_red~=0);    
 [I2,J2]=ind2sub(size(rotated_red),index);
 %scatter(J,I,'r.');
 bounding_x_min=min(J2);
 bounding_x_max=max(J2);
 bounding_y_min=min(I2);
 bounding_y_max=max(I2);
 plot([bounding_x_min,bounding_x_min],[1,a2],'r-.');
 plot([bounding_x_max,bounding_x_max],[1,a2],'r-.');
 plot([1,b2],[bounding_y_min,bounding_y_min],'r-.')
 plot([1,b2],[bounding_y_max,bounding_y_max],'r-.')

% the distance to the ceiling compared to the cell height
% the distance to the center compared to the cell width 
 heighth=bounding_y_max-bounding_y_min;
 width=bounding_x_max-bounding_x_min;
 
 x_distance_norm=x_distance/width;
 y_distance_norm=(bounding_y_max-y_distance)/heighth;
 % output figure
 % output x_distance y_distance
 % save the figure
saveas(figure(3000),[imageName(1:end-4) '_sensorycilia_func_1.fig'],'fig');
saveas(figure(3001),[imageName(1:end-4) '_sensorycilia_func_2.fig'],'fig'); 
save([imageName(1:end-4) '_sensoryposition_generateddata.mat']);


end
