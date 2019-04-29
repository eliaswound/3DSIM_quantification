% compare the difference between the upper half of the cell and lower half
% of the cell
folder_name=uigetdir('Please select the folder that contains data genenrated by ALI_basalbody_analysis_Main');
cd(folder_name);
files = dir([folder_name '\*_directionfunction_generateddata.mat']);
vectorlength_all=[];

for i=1:length(files)
    data=importdata(files(i).name);
    try
    direction=data.final(:,1); % direction [-pi,pi]
    meandirection=circ_mean(direction);
    pair=data.filtered_interest;
    centroid=[mean(pair(:,2)),mean(pair(:,3))];
  % calculate centroid to pair vector
    centroid_to_pair=[pair(:,2)-centroid(1),pair(:,3)-centroid(2)];    
  % calculate the angle between centroid to pair vector and direction
  % vector
    direction_vector=[cos(meandirection),sin(meandirection)]; 
    for k=1:length(centroid_to_pair)
              CosTheta = dot(centroid_to_pair(k,1:2),direction_vector)/(norm(centroid_to_pair(k,1:2))*norm(direction_vector));
              ThetaInDegrees = acosd(CosTheta);
              centroid_to_pair(k,3)=ThetaInDegrees;
    end
    vectorlength_cell=circ_r(direction);
    vectorlength_upper=circ_r(direction(centroid_to_pair(:,3)<=90));
    vectorlength_lower=circ_r(direction(centroid_to_pair(:,3)>90));
    vectorlength_all=[vectorlength_all;vectorlength_cell,vectorlength_upper,vectorlength_lower];
    clear data direction meandirection pair centroid centroid_to_pair direction vector
    clear k CosTheta ThetaInDegrees
    clear vectorlength_cell vectorlength_upper vectorlength_lower
    catch
    end
end
% output all the necessary data
% [m,n]=size(vectorlength_all);
% vector_one=[];
% for j=1:n
%     vector_temp(:,1)=j*ones(m,1);
%     vector_temp(:,2)=vectorlength_all(:,j);
%     vector_one=[vector_one;vector_temp];
% end
% figure
% boxplot(vector_one(:,2),vector_one(:,1));
figure
scatter(vectorlength_all(:,2),vectorlength_all(:,3));
axis equal
xlabel('The upper half of the cell');
ylabel('The lowe half of the cell');

