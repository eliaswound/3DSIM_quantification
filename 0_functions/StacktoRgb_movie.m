%stack_to_rgb
[filename,foldename]=uigetfile('*.tiff','select the tif file you want to transform');
cd(foldename);
info = imfinfo(filename);
num_images = numel(info);
 for k = 1:num_images
     SpecificFrameImage=imread(filename, k, 'Info', info);
     if rem(k,2)~=0
     movie_raw(:,:,1,fix(k/2)+1)=SpecificFrameImage;
     else
     movie_raw(:,:,2,fix(k/2)+1)=SpecificFrameImage;
     end
     movie_raw(:,:,3,fix(k/2)+1)=zeros(info(1,1).Height,info(1,1).Width);
 end
%implay(movie_raw);


outputFileName =[filename(1:end-9) '_rgb.tiff'];
for K=1:length(movie_raw(1,1,1,:))
   imwrite(movie_raw(:,:,:,K), outputFileName, 'WriteMode', 'append',  'Compression','none');
end
%imwrite(movie_raw,[filename(1:end-9) '_rgb.tiff'],'compression','none');


