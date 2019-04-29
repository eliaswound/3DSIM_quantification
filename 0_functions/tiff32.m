%
% Start with:
% http://www.mathworks.com/help/matlab/import_export/exporting-to-images.html#br_c_iz-1
data = uint32(magic(10));
%%
% This is a direct interface to libtiff
t = Tiff('myfile.tif','w');
% Setup tags
% Lots of info here:
% http://www.mathworks.com/help/matlab/ref/tiffclass.html
tagstruct.ImageLength     = size(data,1);
tagstruct.ImageWidth      = size(data,2);
tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample   = 32;
tagstruct.SamplesPerPixel = 1;
tagstruct.RowsPerStrip    = 16;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software        = 'MATLAB';
t.setTag(tagstruct)
t.write(data);
t.close();
%%
d = imread('myfile.tif');
disp(class(d));
assert(isequal(d,data))