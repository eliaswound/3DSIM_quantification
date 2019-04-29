% PCD diagnosis_machine learning_image cropping
clear;close all;clc;
folder_name=uigetdir('Please select the folder that contains all the .tiff file you want to crop');
cd(folder_name);
files = dir([folder_name '\*.ome.tiff']);
figure(1)
for i=1:length(files)
    figure(1);clf
    frame_1=imread(files(i).name,'Index',1);
    frame_2=imread(files(i).name,'Index',2);
    image(:,:,1)=frame_2;
    image(:,:,2)=frame_1;   
    [a,b]=size(frame_1);
    image(:,:,3)=zeros(a,b);
    imshow(autocontrast(image));
    h = imrect;
    pos = getPosition(h);  %[xmin ymin width height]
    image_subset=image(floor(pos(2)):floor(pos(2))+pos(4)+1,floor(pos(1)):floor(pos(1))+pos(3)+1,1:3);
    figure(2);clf
    imshow(autocontrast(image_subset))
    imwrite(image_subset,[files(i).name(1:end-8) '_crop.tif'],'tiff', 'Compression', 'none', 'WriteMode',  'overwrite');
    clear frame_1 frame_2 a b h pos image_subset 
end


 