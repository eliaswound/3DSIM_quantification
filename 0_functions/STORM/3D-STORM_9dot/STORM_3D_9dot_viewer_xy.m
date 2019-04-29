% -------------------------------------------------------------------------
% STORM_3D_9dot_viewer_xy
% -------------------------------------------------------------------------
% The script is used to generated the images for OFD1 or PCD19 GAG8 9 dots 
% to for alignment script developed by Xiaoyu Shi from Bo Huang Lab
% -------------------------------------------------------------------------
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
binsize=10;
%--------------------------------------------------------------------------
% Molecule Map
%--------------------------------------------------------------------------
[file, path]=uigetfile('*.bin','please select the bin file');
cd(path)
MList=ReadMasterMoleculeList_alist(file);
x_coordinate = (MList.x-min(MList.x))*pixel_size;
y_coordinate = (MList.y-min(MList.y))*pixel_size;
xc = 0:binsize:ceil(max(x_coordinate));
yc = 0:binsize:ceil(max(y_coordinate));
IHis=hist2d(x_coordinate, y_coordinate, xc, yc);
h1 = fspecial('gaussian', 5 , 1);
IHisg = imfilter(IHis, h1); 
%--------------------------------------------------------------------------
% Molecule index in the bin
%--------------------------------------------------------------------------
molecule_bin_index=[];
x_bin_index=fix(x_coordinate/binsize)+1;
y_bin_index=fix(y_coordinate/binsize)+1;
linearInd=sub2ind([length(yc) length(xc)], y_bin_index', x_bin_index');
molecule_bin_index=[molecule_bin_index;x_bin_index y_bin_index linearInd'];

%--------------------------------------------------------------------------
% show the map and draw the boundary 
%--------------------------------------------------------------------------
mkdir(file(1:end-4))
cd(file(1:end-4))
finish=1;
m=1;
cell_centroid=[];
scrsz = get(0,'ScreenSize');


while finish~=0 
    h=figure(100); clf;
    set(h,'position',[1 1 scrsz(3) scrsz(4)]);
    colormap('Gray')
    imagesc(autocontrast(IHisg))
    axis equal
    hold on
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
    %z_chosen=MList.z(molecule_index,:);
    
    for i=1:length(format)
        Molecule_chosen.(format{i,3})=MList.(format{i,3})(molecule_index,:);
    end
   
    %--------------------------------------------------------------------------
    % Show the chosen dots
    %--------------------------------------------------------------------------
    figure(101); clf;
    plot(x_chosen,y_chosen,'.')

    Par = CircleFitByPratt([x_chosen(:,1),y_chosen(:,1)]);
    hold on
    viscircles([Par(1) Par(2)], Par(3),'EdgeColor','r');
    axis equal
    %--------------------------------------------------------------------------
    % normalize the data:
    %--------------------------------------------------------------------------
    x_normalize=x_chosen(:,1)-Par(1)+3;   % 2 pixel
    y_normalize=y_chosen(:,1)-Par(2)+3;   % 2 pixel
    Molecule_chosen.x=x_normalize;
    Molecule_chosen.xc=x_normalize;
    Molecule_chosen.y=y_normalize;
    Molecule_chosen.yc=y_normalize;
    %--------------------------------------------------------------------------
    % saving the data
    %--------------------------------------------------------------------------
    WriteMoleculeList(Molecule_chosen,[num2str(m) '_list.bin'])
    m=m+1;
end
    saveas(figure(100),'Chosen.fig','fig');
    cd ..
