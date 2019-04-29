function []=func_cilia_direction_calculation_v2()
%--------------------------------------------------------------------------
% Cilia_Direction_Calculation
%--------------------------------------------------------------------------
% This MATLAB script is written for James to calculate the direction of the
% cilia in a cell.
%--------------------------------------------------------------------------
% Input: a dual color image with a single cell in it. 
%        the green signal represents the Centriolin 
%        the red signal represents tubulin in cilia
% Outputs: 
%         fig1: red channel raw image
%         fig2: red channel binary image
%         fig3: green channel raw image
%         fig4: green channel binary image
%         fig5: red center/green center matching
%         fig6: plot all the directions on a white background       
%         fig7: compass plot
%         fig8: rose plot
%         fig9: plot all the directions on a cell
%--------------------------------------------------------------------------
% Zhen Liu
% liuzhorizon@gmail.com
% September 1st, 2016
%--------------------------------------------------------------------------
% Version 2.0
% fig5: y axis reverse
% fig6: y axis reverse
% (y2-y1)/(x2-x1)-> -(y2-y1)/(x2-x1) y axis reverse
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------
%clear;close all;clc;
%--------------------------------------------------------------------------
% Step1: import the tif data
%--------------------------------------------------------------------------
[FileName,PathName]=uigetfile({'*.tif';'*.tiff';'*.png';'*.jpeg';'*.bmp'},'Select the image file');
cd(PathName);
image=imread(FileName);
red=image(:,:,1);
green=image(:,:,2);
%--------------------------------------------------------------------------
% get the red objects
%--------------------------------------------------------------------------
fig1=figure(1);imshow(red); title('Red channel')
level=graythresh(red);

bw_red = im2bw(red,level-0.15); %Threshold 1 setting %%%%%%%%!!!!!!!!!!%%%%%%%%%
fig2=figure(2);imshow(bw_red); title('Red Channel Binary')
s_red=regionprops(bw_red, red, 'WeightedCentroid');
numObj = numel(s_red);
parameters=[];
for k = 1 : numObj
    parameter=[k,s_red(k).WeightedCentroid];
    parameters=[parameters;parameter];
    clear parameter
end
%--------------------------------------------------------------------------
% get the green objects 
%--------------------------------------------------------------------------
fig3=figure(3);imshow(green); title('Green channel')
level2=graythresh(green);
bw_green=im2bw(green,level2+0.2);%Threshold 2 setting %%%%%%%%!!!!!!!!!!%%%%%%%%%
fig4=figure(4);imshow(bw_green); title('Green Channel Binary')
s_green=regionprops(bw_green, green, 'WeightedCentroid');
numObj2 = numel(s_green);
parameters2=[];
for k = 1 : numObj2
    parameter2=[k,s_green(k).WeightedCentroid];
    parameters2=[parameters2;parameter2];
    clear parameter2
end
%--------------------------------------------------------------------------
% green-red matching 
%--------------------------------------------------------------------------
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
filtered_interest=filtered(filtered(:,7)<=8,:); %Threshold 3 setting, unit in pixels %%%%%%%%!!!!!!!!!!%%%%%%%%% 
figure(5)
dp=[filtered_interest(:,2)-filtered_interest(:,5),-(filtered_interest(:,3)-filtered_interest(:,6))]; % version2: -(y2-y1), y axis reverse
quiver(filtered_interest(:,5),filtered_interest(:,6),dp(:,1),-dp(:,2),0); % version2
set(gca,'YDir','reverse')
grid on;
%--------------------------------------------------------------------------
% green-red matching
%--------------------------------------------------------------------------
fig6=figure(6);
quiver(filtered_interest(:,5),filtered_interest(:,6),10*dp(:,1),-10*dp(:,2),0,'LineWidth',2);%version2
set(gca,'YDir','reverse')
%--------------------------------------------------------------------------
% compass plot
%--------------------------------------------------------------------------
fig7=figure(7);
for i=1:length(dp)
    dp(i,3)=(dp(i,1)^2+dp(i,2)^2)^0.5;
    dp(i,4)=dp(i,1)/dp(i,3);
    dp(i,5)=dp(i,2)/dp(i,3); 
    dp(i,6)=atan2(dp(i,5),dp(i,4));
end
compass(dp(:,4),dp(:,5));
%--------------------------------------------------------------------------
% rose plot
%--------------------------------------------------------------------------
fig8=figure(8);
rose(dp(:,6))
%--------------------------------------------------------------------------
% image presenting
%--------------------------------------------------------------------------
fig9=figure(9);
imagesc(image)
hold on
quiver(filtered_interest(:,5),filtered_interest(:,6),dp(:,1),-dp(:,2),0,'LineWidth',2);% version2 y axis reverse
scatter(filtered_interest(:,2),filtered_interest(:,3),50,'bo');
scatter(filtered_interest(:,5),filtered_interest(:,6),50,'bo');
grid on;
%--------------------------------------------------------------------------
% image and data saving
%--------------------------------------------------------------------------
saveas(fig1,[FileName(1:end-4) '_fig1_redraw.fig'],'fig');
saveas(fig2,[FileName(1:end-4) '_fig2_redbinary.fig'],'fig');
saveas(fig3,[FileName(1:end-4) '_fig3_greenraw.fig'],'fig');
saveas(fig4,[FileName(1:end-4) '_fig4_greenbinary.fig'],'fig'); 
saveas(fig5,[FileName(1:end-4) '_fig5_redgreenmatch.fig'],'fig');
saveas(fig6,[FileName(1:end-4) '_fig6_alldirectionsonwhitebg.fig'],'fig');
saveas(fig7,[FileName(1:end-4) '_fig7_compass.fig'],'fig');
saveas(fig8,[FileName(1:end-4) '_fig8_rose.fig'],'fig');
saveas(fig9,[FileName(1:end-4) '_fig9_alldirectionsoncell.fig'],'fig');
%--------------------------------------------------------------------------
saveas(fig1,[FileName(1:end-4) '_fig1_redraw.tif'],'tiffn');
saveas(fig2,[FileName(1:end-4) '_fig2_redbinary.tif'],'tiffn');
saveas(fig3,[FileName(1:end-4) '_fig3_greenraw.tif'],'tiffn');
saveas(fig4,[FileName(1:end-4) '_fig4_greenbinary.tif'],'tiffn');
saveas(fig5,[FileName(1:end-4) '_fig5_redgreenmatch.tif'],'tiffn');
saveas(fig6,[FileName(1:end-4) '_fig6_alldirectionsonwhitebg.tif'],'tiffn');
saveas(fig7,[FileName(1:end-4) '_fig7_compass.tif'],'tiffn');
saveas(fig8,[FileName(1:end-4) '_fig8_rose.tif'],'tiffn');
saveas(fig9,[FileName(1:end-4) '_fig9_alldirectionsoncell.tif'],'tiffn');
%---------------------------------------------------------------------------
save([FileName(1:end-4) '_generateddata.mat']);
  