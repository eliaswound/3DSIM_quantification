% 3D-STORM 9 dot viewer
  clear;close all;clc;
%--------------------------------------------------------------------------
% Default Variables
%--------------------------------------------------------------------------
  pixel_size = 160; % unit: nanometer
  format = {...
    'single' [1 1] 'x'; ...
    'single' [1 1] 'y'; ...
    'single' [1 1] 'xc'; ...
    'single' [1 1] 'yc'; ...
    'single' [1 1] 'h'; ...
    'single' [1 1] 'a'; ...
    'single' [1 1] 'w'; ...
    'single' [1 1] 'phi'; ...
    'single' [1 1] 'ax'; ...
    'single' [1 1] 'bg'; ...
    'single' [1 1] 'i'; ...
    'int32' [1 1] 'c'; ...
    'int32' [1 1] 'density'; ...
    'int32' [1 1] 'frame'; ...
    'int32' [1 1] 'length'; ...
    'int32' [1 1] 'link'; ...
    'single' [1 1] 'z'; ...
    'single' [1 1] 'zc';};
%--------------------------------------------------------------------------
% Molecule Map
%--------------------------------------------------------------------------
[file, path]=uigetfile('*.bin','please select the bin file');
cd(path)
MList=ReadMasterMoleculeList_alist(file);
x_coordinate = (MList.x-min(MList.x))*pixel_size;
y_coordinate = (MList.y-min(MList.y))*pixel_size;
xc = 0:10:ceil(max(x_coordinate));
yc = 0:10:ceil(max(y_coordinate));
IHis=hist2d(x_coordinate, y_coordinate, xc, yc);
molecule_bin_index=[];
for i=1:length(x_coordinate)
    x_bin_index=fix(x_coordinate(i,1)/10)+1;
    y_bin_index=fix(y_coordinate(i,1)/10)+1;
    linearInd=sub2ind([length(yc) length(xc)], y_bin_index, x_bin_index);
    molecule_bin_index=[molecule_bin_index;x_bin_index y_bin_index linearInd];
end
h1 = fspecial('gaussian', 10 , 1);
IHisg = imfilter(IHis, h1); 
%--------------------------------------------------------------------------
% show the map and draw the boundary 
%--------------------------------------------------------------------------
mkdir(file(1:end-4))
cd(file(1:end-4))
finish=1;
m=1;
cell_centroid=[];
while finish~=0 
    scrsz = get(0,'ScreenSize');
    h=figure(100); clf;
    set(h,'position',[1 1 scrsz(3) scrsz(4)]);
    hold on
    colormap('Gray')
    imagesc(IHisg)
    axis equal
    if m>=2
      for n=1:m-1
          text(cell_centroid(n,1),cell_centroid(n,2),['\color{red} 9 dot'  num2str(n)],'FontSize',15);
      end          
    end
    uicontrol('Style', 'pushbutton', 'String', 'Freedraw',...
        'Position', [20 100 50 20],...
        'Callback', 'selected=imfreehand;finish=1');
    uicontrol('Style', 'pushbutton', 'String', 'Zoom',...
        'Position', [20 340 50 20],...
        'Callback', 'zoom');
    uicontrol('Style', 'pushbutton', 'String', 'Pan',...
        'Position', [20 500 50 20],...
        'Callback', 'pan');
    uicontrol('Position',[20 600 50 20],'String','This is the last',...
        'Callback','selected=imfreehand;finish=0');
    uiwait(gcf);
    selected_binary=createMask(selected);
    object_chosen=regionprops(selected_binary, IHisg, 'Centroid','Area','BoundingBox','PixelIdxList');
    area_list=[];
    for q=1:length(object_chosen);
        area_list=[area_list;object_chosen(q).Area];
    end
    [s_area,s_index]=max(area_list);
    object_chosen2=object_chosen(s_index);
    cell_centroid=[cell_centroid;object_chosen2.Centroid];
    %--------------------------------------------------------------------------
    % Trace back to the original MList points
    %--------------------------------------------------------------------------
    molecule_index=[];
    for i=1:length(object_chosen2.PixelIdxList)
        molecule_index_single=find((molecule_bin_index(:,3)==single(object_chosen2.PixelIdxList(i,1)))&(MList.z<=750)&(MList.z>=-750));
        molecule_index=[molecule_index;molecule_index_single];
    end
    
    x_chosen=MList.x(molecule_index,:);
    y_chosen=MList.y(molecule_index,:);
    z_chosen=MList.z(molecule_index,:);
    
    for i=1:length(format)
        Molecule_chosen.(format{i,3})=MList.(format{i,3})(molecule_index,:);
    end
    
    %--------------------------------------------------------------------------
    % Show the chosen dots
    %--------------------------------------------------------------------------
    figure(101); clf;
    plot(x_chosen,y_chosen,'.')
    axis equal
    hold on
    %--------------------------------------------------------------------------
    % Polyfit the molecule and show the fit
    %--------------------------------------------------------------------------
    p=polyfit(x_chosen,y_chosen,1);
    slope=atan(p(1)); % slope in radian
    center_x=mean(x_chosen);
    center_y=mean(y_chosen);
    x_1=(center_x-2):0.1:(center_x+2);
    y_1=x_1*p(1)+p(2);
    plot(x_1,y_1,'r-');
    plot(center_x,center_y,'go')
    y_bar_x=[center_x;center_x];
    y_bar_y=[center_y-2;center_y+2];
    plot(y_bar_x,y_bar_y,'r--')
    hold off
    %--------------------------------------------------------------------------
    % Rotate the bacteria (manually if the fit is not very good).
    %--------------------------------------------------------------------------
    %refine=input('Do you want to define the rotation angle manually? y/n','s');
     refine='y';
    if refine=='y'
        display('-------------------------------------------------------------');
        display('Please choose two point by single click manually')
        display('-------------------------------------------------------------');
        [x_refine,y_refine]=ginput(2);
        p_refine=polyfit(x_refine,y_refine,1);
        slope_refine=atan(p_refine(1));
        angle_refine=-slope_refine;
        rotated_coords=rotation([x_chosen y_chosen],...
            [center_x,center_y],angle_refine,'radians');
    else
        angle=-slope;
        rotated_coords=rotation([x_chosen y_chosen],...
            [center_x,center_y],angle,'radians');
    end
    figure(102);clf
    plot(rotated_coords(:,1),rotated_coords(:,2),'.');
    axis equal
    figure(103);clf
    plot(rotated_coords(:,1),z_chosen/pixel_size,'.')
    axis equal
    %--------------------------------------------------------------------------
    % Refine the data/circle fitting
    %--------------------------------------------------------------------------
    rect=getrect(figure(103));
    %[xmin ymin width height]
    figure(104);clf
    index=find((rotated_coords(:,1)>rect(1))&(rotated_coords(:,1)<(rect(1)+rect(3)))&((z_chosen/pixel_size)>rect(2))&((z_chosen/pixel_size)<rect(2)+rect(4)));
    for i=1:length(format)
        Molecule_chosen_rect.(format{i,3})=Molecule_chosen.(format{i,3})(index,:);
    end
    plot(rotated_coords(index,1),z_chosen(index,1)/pixel_size,'.');
    axis equal
    Par = CircleFitByPratt([rotated_coords(index,1),z_chosen(index,1)/pixel_size]);
    hold on
    viscircles([Par(1) Par(2)], Par(3),'EdgeColor','r');
    %--------------------------------------------------------------------------
    % normalize the data:
    %--------------------------------------------------------------------------
    x_normalize=rotated_coords(index,1)-Par(1)+2;   % 2 pixel
    z_normalize=z_chosen(index,1)/pixel_size-Par(2)+2;   % 2 pixel
    Molecule_chosen_rect.x=x_normalize;
    Molecule_chosen_rect.xc=x_normalize;
    Molecule_chosen_rect.z=rotated_coords(index,2)*pixel_size;
    Molecule_chosen_rect.zc=rotated_coords(index,2)*pixel_size;
    Molecule_chosen_rect.y=z_normalize;
    Molecule_chosen_rect.yc=z_normalize;
    %--------------------------------------------------------------------------
    % saving the data
    %--------------------------------------------------------------------------
    WriteMoleculeList(Molecule_chosen_rect,[num2str(m) '_list.bin'])
    m=m+1;
end
    saveas(figure(100),'Chosen.fig','fig');
    cd ..
