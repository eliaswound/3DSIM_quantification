function [Images0, Images] = ReadMultiImageLowCon(path,n)
% path: the folder in which ur images exists
% Output: Images is original images; Images) is low contrast images

dirname = [path,'*.png']
srcFiles = dir(dirname); 
L=length(srcFiles);
for i = 1 : L
    i
    filename = strcat(path,srcFiles(i).name);
    Irgb = imread(filename);
    I = double(rgb2gray(Irgb));
    Images(:,:,i) = I;
    
    [Ifinal] = LowerImages(I,n);
    Images0(:,:,i) = Ifinal;
    
end


