function [Ia, stage, Icollection]=MCC_differentiatestage_M2014
% This function is a test one. It is used to calculate the differentiate stage of
%  multiciliated cell. The input is the coordinates of all the basal bodies
%  in 2D
% Reference: Elisa Herawati etal. JCB 2016
%            Multiciliated cell basal bodies align in stereotypical 
%            patterns coordinated by the apical cytoskeleton
% Differentiate stage
% Floret Ia: <0.22
% Scatter Ia: 0.22-0.33
% Partcial alignment Ia: 0.33-0.43
% Alignment Ia: >0.43
% Step 1 Import the basal body position list
         cd('F:\20170712_MATLABtest_MCC differentiation stage');
         load samplecell3   
% Step 2 Determination of neighboring basal bodies
         d=8.3; % first class neighboring bb distance. unit pixel 
         ratio=1.3;
         [idx,D]=rangesearch(data,data,ratio*d);
% Step 3 Local evaluation of the alignment
         Icollection=NaN(length(data),2);
         for i=1:length(data)
             number_of_neighboring_bbs=length(D{i,1})-1; % the first coordinate is erased
%              if number_of_neighboring_bbs >4
%                 number_of_neighboring_bbs=100;
%              end
             coordinates_index=idx{i,1};
             coordinates=data(coordinates_index,:);     % the first coordinate is the point itself.   
             switch number_of_neighboring_bbs
                 case 0
                      I=0;
                      label=100;
                 case 1
                      index_j=coordinates_index(2);
                      number_of_neighboring_bbs_j=length(D{index_j,1})-1;
                      if number_of_neighboring_bbs_j==2
                         coordinates_index_j=idx{index_j,1};
                         coordinates_j=data(coordinates_index_j,:);
                         coordinate1=coordinates_j(1,:);
                         coordinate2=coordinates_j(2,:);
                         coordinate3=coordinates_j(3,:);
                         L=L_function(coordinate1, coordinate2, coordinate3);
                         I=L;                       
                      else
                         I=0;
                      end
                       label=101;
                 case 2
                      coordinate1=coordinates(1,:);
                      coordinate2=coordinates(2,:);
                      coordinate3=coordinates(3,:);
                      L=L_function(coordinate1, coordinate2, coordinate3);
                      I=L;
                      label=102;
                 case 3
                      coordinate1=coordinates(1,:);
                      coordinate_others=coordinates(2:end,:);
                      wllist=zeros(length(coordinate_others),1);
                      for j=1:length(coordinate_others)
                          wllist(j,1)=wl_function(coordinate1,coordinate_others(j,:),d,ratio);
                      end
                      clear j;
                      wjklist=zeros(3,1);
                      Ljklist=zeros(3,1);                     
                      for j=1:length(coordinate_others)-1
                          for k=j+1:length(coordinate_others)
                              wjk=wllist(j,1)*wllist(k,1);
                              Ljk=L_function(coordinate1,coordinate_others(j,:),coordinate_others(k,:));
                              wjklist=[wjklist;wjk];
                              Ljklist=[Ljklist;Ljk]; 
                          end
                      end
                      I=sum(wjklist.*Ljklist)/sum(wjklist);
                      clear j k;
                      label=103;
                 case 4
                      I=1;
                      label=104;
                 otherwise
                     I=0;
                     label=100+number_of_neighboring_bbs;
             end
             Icollection(i,1)=I;
             Icollection(i,2)=label;
             
             clear I;
         end
% Step 4 Averaging all the Ia measured in Step3
         Ia=mean(Icollection(:,1));
% Step 5 Differentiation stage determination
         if Ia <0.22
             stage='Floret';
         elseif Ia>=0.22 && Ia<0.33
             stage='Scatter';
         elseif Ia>=0.33 && Ia<0.43
             stage='Partcila alignment';
         else
             stage='Alignment';
         end
% Step 6 Plot all the basal bodies in one plot colored by the Icollection vaule
         scatter(data(:,1),data(:,2),50,Icollection(:,1),'fill');
         hold on
         str=num2str(Icollection(:,2)-100);
         for i=1:length(data)
             text(data(i,1)+2,data(i,2)+2,str(i,1),'FontSize',10);
         end
         axis equal
         colorbar;
% Step 7 Display the Ia value and differentiation stage
%        Save Ia and differentiation stage    
         display('------------------------------------------------------');
         display('The Ia value for this cell is');
         display(Ia);
         display('The differentiation stage for this cell is');
         display(stage);
         display('------------------------------------------------------');
         %save(Ia)
         %save(stage)
 end       
         
 function wl=wl_function(coordinate1,coordinate2,d,ratio)
          distance=((coordinate1(1)-coordinate2(1))^2+(coordinate1(2)-coordinate2(2))^2)^0.5;
          if distance <=ratio*d && distance >=0
             wl=min(1, 1-((distance-d)/((ratio-1)*d)));
          else
              error('wl_function: distance fall out of range')
          end
 end
         
 function L=L_function(coordinate1, coordinate2, coordinate3)
          vector12=[coordinate2(1)-coordinate1(1),coordinate2(2)-coordinate1(2)];
          vector13=[coordinate3(1)-coordinate1(1),coordinate3(2)-coordinate1(2)];
          costheta = dot(vector12,vector13)/(norm(vector12)*norm(vector13));
          acute_angle = acos(costheta);
          % it is less than 180 degrees and more than 0 degrees
          if acute_angle<=pi && acute_angle >=0
             L=max(0,-cos(acute_angle));
          else
             error('L_function: anglee fall out of range')
          end
 end