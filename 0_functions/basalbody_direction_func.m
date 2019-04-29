function [p_value,mean_direction,all_directions]=basalbody_direction_func(imageName,threshold)
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
% Optional?threshold, for instance,[80,100], the number should be between
% 0~254
% Outputs: 
%         fig1: red channel raw image/red channel binary image/
%               green channel raw image/green channel binary image
%         fig2: plot all the directions on a cell
%         fig3: compass plot/rose plot
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
%--------------------------------------------------------------------------
% Step1: import the tif data
%--------------------------------------------------------------------------
image=imread(imageName);
red=image(:,:,1);
green=image(:,:,2);
[a,b]=size(red);
%--------------------------------------------------------------------------
% get the red objects
%--------------------------------------------------------------------------
fig1=figure(1000);clf;subplot(2,2,1); imshow(red); title('Red channel');axis equal;
    if nargin<2
%       imcontrast;
%       value_min=input('please input the minimum you adjusted'); % This parameter is important! 
%       level=value_min/255;
%       automatic threshold setting
      level=graythresh(red);
      bw_red = im2bw(red,level); 
    else
      bw_red=true(a,b);
      index=find(red<threshold(1));
      bw_red(index)=0;
    end
figure(1000);subplot(2,2,2);imshow(bw_red);title('Red Channel Binary')
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
%area_quantile=quantile(parameters(:,4),[0.25 0.75]); % the quartiles of x
%area_upper=area_quantile(2)+1.5*(area_quantile(2)-area_quantile(1));
%area_lower=area_quantile(1)-1.5*(area_quantile(2)-area_quantile(1));
%parameters_calibration=parameters(parameters(:,4)>area_lower&parameters(:,4)<area_upper,:);
parameters_calibration=parameters;

% update the binary signal

%--------------------------------------------------------------------------
% get the green objects 
%--------------------------------------------------------------------------
figure(1000);subplot(2,2,3);imshow(green); title('Green channel');axis equal;
if nargin<2
%   imcontrast;
%   value_min=input('please input the minimum you adjusted'); % This parameter is important! 
%   level=value_min/255;
  level=graythresh(green);
  bw_green = im2bw(green,level);
else
   bw_green=true(a,b);
   index=find(green<threshold(2));
   bw_green(index)=0;
end
figure(1000);subplot(2,2,4);imshow(bw_green);title('Green Channel Binary');axis equal;

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
% area_quantile2=quantile(parameters2(:,4),[0.25 0.75]); % the quartiles of x
% area_upper2=area_quantile2(2)+1.5*(area_quantile2(2)-area_quantile2(1));
% area_lower2=area_quantile2(1)-1.5*(area_quantile2(2)-area_quantile2(1));
% parameters2_calibration=parameters2(parameters2(:,4)>area_lower2&parameters2(:,4)<area_upper2,:);
parameters2_calibration=parameters2;
% confine the major axis length/minor axis length ratio (>1.2) manual
% define the ratio
%parameters2_calibration=parameters2_calibration(parameters2_calibration(:,8)>1.2,:);

%--------------------------------------------------------------------------
% green-red matching 
%--------------------------------------------------------------------------
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

dp=[filtered_interest(:,6)-filtered_interest(:,2),-(filtered_interest(:,7)-filtered_interest(:,3))]; % version2: -(y2-y1), y axis reverse
for i=1:length(dp)
    dp(i,3)=(dp(i,1)^2+dp(i,2)^2)^0.5;
    dp(i,4)=dp(i,1)/dp(i,3);
    dp(i,5)=dp(i,2)/dp(i,3); 
    dp(i,6)=atan2(dp(i,5),dp(i,4));
end

%--------------------------------------------------------------------------
% Adding a refining step
%--------------------------------------------------------------------------
   % 1) Calculate the mean direction of the cilia
   % 2) For each red dot, find all the green dots in distance
   % 3) Calculate the vector between the red dot to all the green dots
   % 4) Calculate the angle between the direction of the cilia and the angle
   % 5) Choose the nearest one
   % 6) Re-plot all the angles and redo all the calculations 
  directions=dp(:,6);
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
            redtogreen=[parameters2_calibration(IDX(i,j),2)-parameters_calibration(i,2),-(parameters2_calibration(IDX(i,j),3)-parameters_calibration(i,3))]; % version2: -(y2-y1), y axis reverse
            CosTheta = dot(redtogreen,mean_direction_vector)/(norm(redtogreen)*norm(mean_direction_vector));
            ThetaInDegrees = acosd(CosTheta);
            new_angle=atan2(redtogreen(2),redtogreen(1));
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
 else
 end
 
%--------------------------------------------------------------------------
% image presenting
%--------------------------------------------------------------------------
fig2=figure(1001);clf;
if p_value<0.05
    subplot(1,2,1)
    %imagesc(autocontrast(image))
    imagesc(image)
    hold on
    quiver(filtered_interest(:,2),filtered_interest(:,3),dp(:,1),-dp(:,2),0,'LineWidth',2);% version2 y axis reverse
    scatter(filtered_interest(:,2),filtered_interest(:,3),50,'bo');
    scatter(filtered_interest(:,6),filtered_interest(:,7),50,'bo');
    grid on;
    axis equal
    title('before refine')
    subplot(1,2,2)
    %imagesc(autocontrast(image))
    imagesc(image)
    hold on
    final(:,6)=final(:,4)-final(:,2);
    final(:,7)=-((final(:,5)-final(:,3)));
    quiver(final(:,2),final(:,3),final(:,6),-final(:,7),0,'LineWidth',2);% version2 y axis reverse
    scatter(final(:,2),final(:,3),50,'bo');
    scatter(final(:,4),final(:,5),50,'ro');
    grid on;
    axis equal
    title('after refine')
    
else    
    imagesc(autocontrast(image))
    hold on
    quiver(filtered_interest(:,2),filtered_interest(:,3),dp(:,1),-dp(:,2),0,'LineWidth',2);% version2 y axis reverse
    scatter(filtered_interest(:,2),filtered_interest(:,3),50,'bo');
    scatter(filtered_interest(:,6),filtered_interest(:,7),50,'bo');
    grid on;
    axis equal
end


%--------------------------------------------------------------------------
% compass/rose plot
%--------------------------------------------------------------------------
fig3=figure(1002);clf;
if p_value<0.05
    subplot(2,2,1);compass(dp(:,4),dp(:,5));title('before refine')
    subplot(2,2,2);rose(dp(:,6));title('before refine')    
    subplot(2,2,3);compass(final(:,6),final(:,7));title('after refine')
    subplot(2,2,4);rose(final(:,1));title('after refine')       
else
    subplot(1,2,1);compass(dp(:,4),dp(:,5));
    subplot(1,2,2);rose(dp(:,6));    
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
saveas(fig1,[imageName(1:end-4) '_basalbody_direction_fig1_binary.fig'],'fig');
saveas(fig2,[imageName(1:end-4) '_basalbody_direction_fig2_greenbinary.fig'],'fig'); 
saveas(fig3,[imageName(1:end-4) '_basalbody_direction_fig3_.fig'],'fig');
save([imageName(1:end-4) '_directionfunction_generateddata.mat']);
direction=dp(:,6);
if p_value<0.05
    all_directions=final(:,1);
    mean_direction=circ_mean(final(:,1));
    [p_value,z_value]=circ_rtest(final(:,1));
    
else
    all_directions=dp(:,6);
end

end




