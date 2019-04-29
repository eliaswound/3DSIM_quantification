%--------------------------------------------------------------------------
% Cilia_Direction_Calculation
%--------------------------------------------------------------------------
% This MATLAB script is written to calculate the direction of the
% cilia in a cell.
%--------------------------------------------------------------------------
% Input: a dual color image with a single cell in it. 
%        the green signal represents the Centriolin representing the
%            centriolin signal.
%        the red signal represents the poc1B signal.
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
% March 13th, 2017
%--------------------------------------------------------------------------
% Version 2.0
% fig5: y axis reverse
% fig6: y axis reverse
% (y2-y1)/(x2-x1)-> -(y2-y1)/(x2-x1) y axis reverse
%--------------------------------------------------------------------------
% Version 3.0
%	3.1 Raw image -> binary image
%	      manual change the contrast of the image and remember the contrast ratio finally adapted.
%	      Notes: The shape of the centriolin signal determines the accuracy 
%	3.2 After the binary image, use a filter to erase the particles that are too small. 
%	3.3 change the method to calculate the direction of the cili			
%	3.4 Refine step:
%	       If it is directionally distributed, make a refine step. Use the direction obtained to redone the matching games.
%	    The directions gets here are much more accurate	
%--------------------------------------------------------------------------
% Creative Commons License 3.0 CC BY  
%--------------------------------------------------------------------------
clear;close all;clc;
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
axis equal;
imcontrast;
value_min=input('please input the minimum you adjusted'); % This parameter is important! 
level=value_min/double(max(max(red)));
bw_red = im2bw(red,level); 
fig2=figure(2);imshow(bw_red); title('Red Channel Binary')

s_red=regionprops(bw_red, red, 'WeightedCentroid','Area');
% use a filter to erase the upper outlier and lower outlier
numObj = numel(s_red);
parameters=[];
for k = 1 : numObj
    parameter=[k,s_red(k).WeightedCentroid,s_red(k).Area];
    parameters=[parameters;parameter];
    clear parameter
end

% Structure for parameters. 
% column 1: particle index, 
% column 2: particle weighted centroid x
% column 3: particle weighted centroid y
% column 4: particle area

% erase the outlier
area_quantile=quantile(parameters(:,4),[0.25 0.75]); % the quartiles of x
area_upper=area_quantile(2)+1.5*(area_quantile(2)-area_quantile(1));
area_lower=area_quantile(1)-1.5*(area_quantile(2)-area_quantile(1));
parameters_calibration=parameters(parameters(:,4)>area_lower&parameters(:,4)<area_upper,:);

% update the binary signal

%--------------------------------------------------------------------------
% get the green objects 
%--------------------------------------------------------------------------
fig3=figure(3);imshow(green); title('Green channel')
axis equal;
imcontrast;
value_min=input('please input the minimum you adjusted'); % This parameter is important! 
level=value_min/double(max(max(green)));
bw_green = im2bw(green,level); 
fig4=figure(4);imshow(bw_green); title('Green Channel Binary')

s_green=regionprops(bw_green, green, 'WeightedCentroid','Area','Orientation','MajorAxisLength','MinorAxisLength');
numObj2 = numel(s_green);
parameters2=[];
for k = 1 : numObj2
    parameter2=[k,s_green(k).WeightedCentroid,s_green(k).Area,s_green(k).Orientation,s_green(k).MajorAxisLength,s_green(k).MinorAxisLength];
    parameters2=[parameters2;parameter2];
    clear parameter2
end
parameters2(:,8)=parameters2(:,6)./parameters2(:,7);
% Structure for parameters2. 
% column 1: particle index, 
% column 2: particle weighted centroid x
% column 3: particle weighted centroid y
% column 4: particle area
% column 5: particle orientation
% column 6: particle major axis length
% column 7: particle minor axis length
% column 8: particle major/minor ratio

% erase the outlier
area_quantile2=quantile(parameters2(:,4),[0.25 0.75]); % the quartiles of x
area_upper2=area_quantile2(2)+1.5*(area_quantile2(2)-area_quantile2(1));
area_lower2=area_quantile2(1)-1.5*(area_quantile2(2)-area_quantile2(1));
parameters2_calibration=parameters2(parameters2(:,4)>area_lower2&parameters2(:,4)<area_upper2,:);

% confine the major axis length/minor axis length ratio (>1.2) manual
% define the ratio
%parameters2_calibration=parameters2_calibration(parameters2_calibration(:,8)>1.2,:);

%--------------------------------------------------------------------------
% green-red matching 
%--------------------------------------------------------------------------
fig5=figure(5);
scatter(parameters_calibration(:,2),parameters_calibration(:,3),'red','filled')
hold on
scatter(parameters2_calibration(:,2),parameters2_calibration(:,3),'green','filled')
axis equal
[IDX,D]=knnsearch(parameters2_calibration(:,2:3),parameters_calibration(:,2:3));
% finds the nearest neighbor in X for each point in Y red
nearestgreen=parameters2_calibration(IDX,:);
[IDX2,D2]=knnsearch(parameters_calibration(:,2:3),nearestgreen(:,2:3));
nearestgreen_nearestred=parameters_calibration(IDX2,:);
% calculate the directions
filtered=[];
for i=1:length(parameters_calibration)
    if parameters_calibration(i,1)==nearestgreen_nearestred(i,1)
       filtered=[filtered;parameters_calibration(i,:),nearestgreen(i,:),D(i)];
    else 
    end
end
figure(5)
scatter(filtered(:,2),filtered(:,3),50,'bo')
scatter(filtered(:,6),filtered(:,7),50,'bo')

% Structure for filtered. 
% column 1: red particle index, 
% column 2: red particle weighted centroid x
% column 3: red particle weighted centroid y
% column 4: red particle area

% column 5: green particle index, 
% column 6: green particle weighted centroid x
% column 7: green particle weighted centroid y
% column 8: green particle area
% column 9: green particle orientation
% column 10: green particle major axis length
% column 11: green particle minor axis length
% column 12: green particle major minor ratio
% column 13:  distance between match green and red pair

filtered_interest=filtered(filtered(:,13)<=8,:); 
% Threshold 3 setting, unit in pixels %%%%%%%%!!!!!!!!!!%%%%%%%%% 

figure(5)
dp=[filtered_interest(:,6)-filtered_interest(:,2),-(filtered_interest(:,7)-filtered_interest(:,3))]; % version2: -(y2-y1), y axis reverse
quiver(filtered_interest(:,2),filtered_interest(:,3),dp(:,1),-dp(:,2),0); % version2
set(gca,'YDir','reverse')
grid on;



% %--------------------------------------------------------------------------
% % green-red matching
% %--------------------------------------------------------------------------
% fig6=figure(6);
% quiver(filtered_interest(:,2),filtered_interest(:,3),10*dp(:,1),-10*dp(:,2),0,'LineWidth',2);%version2
% set(gca,'YDir','reverse')
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
quiver(filtered_interest(:,2),filtered_interest(:,3),dp(:,1),-dp(:,2),0,'LineWidth',2);% version2 y axis reverse
scatter(filtered_interest(:,2),filtered_interest(:,3),50,'bo');
scatter(filtered_interest(:,6),filtered_interest(:,7),50,'bo');
grid on;
%--------------------------------------------------------------------------
% Adding a refining step
%--------------------------------------------------------------------------
directions=dp(:,6);
   % 1) Calculate the mean direction of the cilia
   % 2) For each red dot, find all the green dots in distance
   % 3) Calculate the vector between the red dot to all the green dots
   % 4) Calculate the angle between the direction of the cilia and the angle
   % 5) Choose the nearest one
   % 6) Re-plot all the angles and redo all the calculations 
 mean_direction=circ_mean(directions);
 [p_value,z_value]=circ_rtest(directions);

 if p_value<0.05
    % redo the matches
    % red: parameters_calibration
    % green: parameters2_calibration
    [IDX,D]=knnsearch(parameters2_calibration(:,2:3),parameters_calibration(:,2:3),'k',5);
    [a3,b3]=size(D);
    angle_row=[];
    mean_direction_vector=[cos(mean_direction),sin(mean_direction)];
    final=[];
    temp=[];
    for i=1:a3
     % find  the distances shorter than the limit
     for j=1:b3
         if D(i,j)<=8 %!!!!!!!!!!
            % calculate the direction
            redtogreen=[parameters2_calibration(IDX(i,j),2)-parameters_calibration(i,2),parameters2_calibration(IDX(i,j),3)-parameters_calibration(i,3)];
            CosTheta = dot(redtogreen,mean_direction_vector)/(norm(redtogreen)*norm(mean_direction_vector));
            ThetaInDegrees = acosd(CosTheta);
            new_angle=-atan2(redtogreen(2),redtogreen(1));% version2 y axis reverse
            angle_row=[angle_row;i,j,ThetaInDegrees,new_angle];
         end
     end
         if ~isempty(angle_row)
            [value,index]=min(angle_row(:,3));
            if value<90
              final=[final;angle_row(index,4),parameters_calibration(i,2),parameters_calibration(i,3),parameters2_calibration(IDX(angle_row(index,1),angle_row(index,2)),2),parameters2_calibration(IDX(angle_row(index,1),angle_row(index,2)),3)]; 
            end
         end
         temp=[temp;angle_row];
         angle_row=[];
    end

    fig10=figure(10);
    rose(final(:,1));
    fig11=figure(11);
    imagesc(image)
    hold on
    final(:,6)=final(:,4)-final(:,2);
    final(:,7)=final(:,5)-final(:,3);
    quiver(final(:,2),final(:,3),final(:,6),final(:,7),0,'LineWidth',2);% version2 y axis reverse
    scatter(final(:,2),final(:,3),50,'bo');
    scatter(final(:,4),final(:,5),50,'ro');
    grid on;
    axis equal
 else
 end
%--------------------------------------------------------------------------
% structure of final 
% final(:,1) contains all the refined angles
%--------------------------------------------------------------------------
% column 1: angle
% column 2:column 3: red coordinates
% column 4:column 5: green coordinates
% column 6:column 7: red to green vector

%--------------------------------------------------------------------------
% image and data saving
%--------------------------------------------------------------------------
saveas(fig1,[FileName(1:end-4) '_fig1_redraw.fig'],'fig');
saveas(fig2,[FileName(1:end-4) '_fig2_redbinary.fig'],'fig');
saveas(fig3,[FileName(1:end-4) '_fig3_greenraw.fig'],'fig');
saveas(fig4,[FileName(1:end-4) '_fig4_greenbinary.fig'],'fig'); 
saveas(fig5,[FileName(1:end-4) '_fig5_redgreenmatch.fig'],'fig');
%saveas(fig6,[FileName(1:end-4) '_fig6_alldirectionsonwhitebg.fig'],'fig');
saveas(fig7,[FileName(1:end-4) '_fig7_compass.fig'],'fig');
saveas(fig8,[FileName(1:end-4) '_fig8_rose.fig'],'fig');
saveas(fig9,[FileName(1:end-4) '_fig9_alldirectionsoncell.fig'],'fig');
if p_value<0.05
 saveas(fig10,[FileName(1:end-4) '_fig8_rose_refine.fig'],'fig');
 saveas(fig11,[FileName(1:end-4) '_fig9_alldirectionsoncell_refine.fig'],'fig');
end
%--------------------------------------------------------------------------
saveas(fig1,[FileName(1:end-4) '_fig1_redraw.tif'],'tiffn');
saveas(fig2,[FileName(1:end-4) '_fig2_redbinary.tif'],'tiffn');
saveas(fig3,[FileName(1:end-4) '_fig3_greenraw.tif'],'tiffn');
saveas(fig4,[FileName(1:end-4) '_fig4_greenbinary.tif'],'tiffn');
saveas(fig5,[FileName(1:end-4) '_fig5_redgreenmatch.tif'],'tiffn');
%saveas(fig6,[FileName(1:end-4) '_fig6_alldirectionsonwhitebg.tif'],'tiffn');
saveas(fig7,[FileName(1:end-4) '_fig7_compass.tif'],'tiffn');
saveas(fig8,[FileName(1:end-4) '_fig8_rose.tif'],'tiffn');
saveas(fig9,[FileName(1:end-4) '_fig9_alldirectionsoncell.tif'],'tiffn');
if p_value<0.05
 saveas(fig10,[FileName(1:end-4) '_fig8_rose_refine.tif'],'tiffn');
 saveas(fig11,[FileName(1:end-4) '_fig9_alldirectionsoncell_refine.tif'],'tiffn');
end
%---------------------------------------------------------------------------
save([FileName(1:end-4) '_generateddata.mat']);


% figure
% subplot(1,2,1)
% rose(dp(:,6),30)
% subplot(1,2,2)
% rose(final(:,1),30)
% a=circ_std(dp(:,6)); 
% b=circ_std(final(:,1));


% p_value
% P_value_optimized
% mean_direction
