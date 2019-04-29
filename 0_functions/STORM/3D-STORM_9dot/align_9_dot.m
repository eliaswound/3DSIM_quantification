% combine all bin file into 1 bin
% fastmap each bin file
clear;close all;clc
folder_name=uigetdir('Please select the folder');
cd(folder_name);
files = dir([folder_name '\*.bin']);
if isempty(files)
    display('no files identified under the current folder')
end

% defauts
fieldNames = {'x','y','xc','yc','h','a','w','phi','ax','bg','i','c','density',...
    'frame','length','link','z','zc'};
fieldTypes = {'single','single','single','single','single','single','single',...
    'single','single','single','single','int32','int32','int32','int32',...
    'int32','single','single','single'};
pixelsize=160;
bin=5;
resolution=12;
Xpixel=160;
Ypixel=160;
%
all=struct('x',[],'y',[],'xc',[],'yc',[],'h',[],'a',[],'w',[],'phi',[],'ax',[],'bg',[],'i',[],'c',[],'density',[],...
    'frame',[],'length',[],'link',[],'z',[],'zc',[]);
for i=1:length(files)
    data=ReadMasterMoleculeList(files(i).name);
    %% center and normalize size
    x=data.xc;z=data.z; y=data.yc;
    data.frame=i*ones(length(data.x),1);           
    for j=1:length(fieldNames)
            all.(fieldNames{j})=[all.(fieldNames{j});data.(fieldNames{j})(:,:)];
    end
    xwidth = 6 * Xpixel/1000;  % um values (160nm pixel)
    yheight = 6* Ypixel/1000;    
    binsize = bin/1000.;   % binsize in um
    nxbins = ceil(xwidth/binsize);
    nybins = ceil(yheight/binsize);
    xc = linspace(0,xwidth, nxbins);
    yc = linspace(0,yheight, nybins)';
    tic
    %IHis = zeros([length(xc) length(yc)]);
    IHis = hist2d(x*0.16, y*0.16, xc, yc);
    toc   
    GaussianBottom=ceil(resolution*3/bin); % unit - pixel
% resolution is 2.355fold of standard deviation (sigma)
% the bottome of the gaussian peak is 3-fold of resolution 
   if mod(GaussianBottom,2)==1
    GaussianBottom=GaussianBottom;
   else
    GaussianBottom=GaussianBottom+1;
end
GaussianStd=floor(GaussianBottom/6); % unit - pixel
h1 = fspecial('gaussian', 200 , 2);
tic
IHisg = imfilter(IHis, h1); 
toc
norm = double(max(max(IHisg)));
nNorm = double(IHisg)./norm; 
%level = 0.3*graythresh(nNorm); 
imwrite(uint16(60000*nNorm),[num2str(i) '.tiff'],'tif', 'Compression', 'none', 'WriteMode',  'overwrite');
imwrite(uint16(60000*nNorm),[num2str(i) '.png'],'png', 'Compression', 'none', 'WriteMode',  'overwrite');
end

figure
scatter(all.x,all.y,5,all.frame,'.');axis equal
cd ..
WriteMoleculeList(all,'all.bin')
