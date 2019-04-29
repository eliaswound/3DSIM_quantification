clear;close all;clc;
directoryname = uigetdir('D:', 'Pick a Directory Containing PCD diagnosis generated data');
cd(directoryname);
list=dir([directoryname '\*.ome.tiff']);
for i=1:length(list)
    info = imfinfo(list(i).name);
    num_images = numel(info);
     for k = 1:num_images
         SpecificFrameImage=imread(list(i).name, k, 'Info', info);
         movie_raw(:,:,k)=SpecificFrameImage;
     end
     [a,b]=size(SpecificFrameImage);
     movie_raw(:,:,3)=zeros(a,b);
     imwrite(movie_raw,[list(i).name(1:end-9) '_rgb.tiff'],'compression','none');

     clear info num_images a b movie_raw
end
    
    display('finished')

