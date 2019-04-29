clear;close all;clc;
% cilia_direction_calculation

% Step1: import the tif data
[FileName,PathName]=uigetfile({'*.tif';'*.tiff';'*.png';'*.jpeg';'*.bmp'},'Select the image file');
cd(PathName);
image=imread(FileName);
red=image(:,:,1);
green=image(:,:,2);
% get the red objects
fig1=figure(1);imshow(red); title('Red channel')
level=graythresh(red);
bw_red = im2bw(red,level);
fig2=figure(2);imshow(bw_red); title('Red Channel Binary')

s_red=regionprops(bw_red, red, 'WeightedCentroid');

numObj = numel(s_red);
parameters=[];
for k = 1 : numObj
    parameter=[k,s_red(k).WeightedCentroid];
    parameters=[parameters;parameter];
    clear parameter
end


% get the green objects 
fig3=figure(3);imshow(green); title('Green channel')
level2=graythresh(green);
bw_green=im2bw(green,level2);
fig4=figure(4);imshow(bw_green); title('Green Channel Binary')

s_green=regionprops(bw_green, green, 'WeightedCentroid');

numObj2 = numel(s_green);
parameters2=[];
for k = 1 : numObj2
    parameter2=[k,s_green(k).WeightedCentroid];
    parameters2=[parameters2;parameter2];
    clear parameter2
end

% green-red matching 
fig5=figure(5);
scatter(parameters(:,2),parameters(:,3),'red','filled')
hold on
scatter(parameters2(:,2),parameters2(:,3),'green','filled')
axis equal


[IDX,D]=knnsearch(parameters2(:,2:3),parameters(:,2:3));
% finds the nearest neighbor in X for each point in Y red
nearestgreen=parameters2(IDX,:);
[IDX2,D2]=knnsearch(parameters(:,2:3),nearestgreen(:,2:3));
nearestgreen_nearestred=parameters(IDX2,:);
% calculate the directions

filtered=[];
for i=1:length(parameters)
    if parameters(i,1)==nearestgreen_nearestred(i,1)
    filtered=[filtered;parameters(i,:),nearestgreen(i,:),D(i)];
    else 
    end
end

figure(5)
scatter(filtered(:,2),filtered(:,3),50,'bo')
scatter(filtered(:,5),filtered(:,6),50,'bo')


filtered_interest=filtered(filtered(:,7)<=5,:); %%%%% 


figure(5)

dp=[filtered_interest(:,2)-filtered_interest(:,5),filtered_interest(:,3)-filtered_interest(:,6)];
quiver(filtered_interest(:,5),filtered_interest(:,6),dp(:,1),dp(:,2),0);

figure(6)
quiver(filtered_interest(:,5),filtered_interest(:,6),10*dp(:,1),10*dp(:,2),0,'LineWidth',2);

figure(7)

for i=1:length(dp)
    dp(i,3)=(dp(i,1)^2+dp(i,2)^2)^0.5;
    dp(i,4)=dp(i,1)/dp(i,3);
    dp(i,5)=dp(i,2)/dp(i,3); 
    dp(i,6)=atan2(dp(i,5),dp(i,4));
end

compass(dp(:,4),dp(:,5));
figure(8)
rose(dp(:,6))

% image presenting
figure(9)
imagesc(image)
hold on
quiver(filtered_interest(:,5),filtered_interest(:,6),dp(:,1),dp(:,2),0,'LineWidth',2);
scatter(filtered_interest(:,2),filtered_interest(:,3),50,'bo');
scatter(filtered_interest(:,5),filtered_interest(:,6),50,'bo');

