%stack_to_rgb
[filename,foldename]=uigetfile('*.tiff','select the tif file you want to transform');
cd(foldename);
info = imfinfo(filename);
num_images = numel(info);
 for k = 1:num_images
     SpecificFrameImage=imread(filename, k, 'Info', info);
     movie_raw(:,:,k)=SpecificFrameImage;
 end
imwrite(movie_raw,[filename(1:end-9) '_rgb.tiff'],'compression','none');

