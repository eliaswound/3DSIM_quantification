clear;close all;clc;
[FileName,PathName]=uigetfile({'*.tif';'*.tiff';'*.png';'*.jpeg';'*.bmp'},'Select the image file');
cd(PathName);
info = imfinfo(FileName);
num_images = numel(info);
% input a threshold for binary image
threshold=input('please input the threshold to change the raw tif data into binary image');
level=threshold/256; % this is for 8 bit image
s=cell(1,num_images);
for k = 1:num_images
    SpecificFrameImage=imread(FileName, k, 'Info', info);
    SpecifFrameBw = im2bw(SpecificFrameImage,level);
    movie_raw(:,:,1,k)=SpecificFrameImage;
    %movie_bw(:,:,1,k)=SpecifFrameBw;
    s{1,k}=regionprops(SpecifFrameBw, SpecificFrameImage, {'WeightedCentroid','EquivDiameter'});     
end
 % Montage label
 % fist frame, each identified oject is right
 % from the second frame, compare the central position with previous
 % frame, if distance< x pixel and frame length< y frame
 % the identified object is considered to be an old one and was filtered
 % repeat the whole process until the last frame.
 % CellToMatrix
 identified=[];
 for i=1:length(s)
    for j=1:numel(s{1,i})
        a=s{1,i};
        if ~isempty(a)
          temp=[i,j,a(j).WeightedCentroid,a(j).EquivDiameter];
          identified=[identified;temp];
        end
    end
 end
% Reduce the redundancy 
% find nearest neighbor
% 是否允许间断
% step 1: 将最小帧的点直接计数
index_initial=find(identified(:,1)==min(identified(:,1)));
identified(index_initial,6)=identified(index_initial,2);
% column 6, the label of each object 
identified(:,7)=1;
% column 7, how many frames it last
% step 2; 对每一个非最小帧的点, 寻找此帧最邻近的前帧
for i=(length(index_initial)+1):length(identified)
    frame_dist=identified(i,1)-identified(1:i-1,1);
    % if 两帧distance>2?,直接标记为新点
    t=min(frame_dist);
    switch t
        case t>2
         identified(i,6)=max(identified(1:(i-1),6))+1;
        otherwise
        % else 在所有点中寻找nearest neighbor, 计算距离    
            candidate=identified(frame_dist==t,:);
            [index2,distance]=knnsearch(candidate(:,3:4),identified(i,3:4));
            if distance>20 % unit pixel
                identified(i,6)=max(identified(1:(i-1),6))+1;
            elseif identified((identified(:,2)==candidate(index2,2))&(identified(:,3)==candidate(index2,3))&(identified(:,4)==candidate(index2,4)),7)> 5 % unit 5
                identified(i,6)=max(1:identified((i-1),6))+1;
            else
                identified(i,6)=identified((identified(:,2)==candidate(index2,2))&(identified(:,3)==candidate(index2,3))&(identified(:,4)==candidate(index2,4)),6);
                identified(i,7)=identified((identified(:,2)==candidate(index2,2))&(identified(:,3)==candidate(index2,3))&(identified(:,4)==candidate(index2,4)),7)+1;
            end
    end    
end
figure;
scatter(identified(:,3),identified(:,4),20,identified(:,1),'o','filled')
axis equal;
colorbar
hold on
for k = 1 : length(identified)
    text(identified(k,3),identified(k,4), ...
        sprintf('%4d', [identified(k,6),identified(k,7)]), ...
        'Color','k');
end
hold off




% index
    %          else check length 
    %                  如果length>5
    %                 标记为新点
    %        如果length<5
    %      采用原先的标记然后length+1    
%                  
%

 
 
mov=immovie(movie_raw,Gray);
implay(mov);

