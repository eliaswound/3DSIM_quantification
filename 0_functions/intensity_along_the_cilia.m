%% intensity along the cilia
% import the tif file
clear;close all;clc; 
[FileName,PathName]=uigetfile({'*.tif';'*.tiff';'*.png';'*.jpeg';'*.bmp'},'Select the image file');
    cd(PathName);
%     info=imfinfo(FileName);
%     num_images=numel(info);
%  for k = 1:num_images
%      SpecificFrameImage=imread(FileName, k, 'Info', info);
%      image(:,:,k)=SpecificFrameImage;
%  end
image=imread(FileName); 
[row,col]=size(image(:,:,1));
image(:,:,3)=zeros(row,col);
figure
% freedraw tool
imshow(autocontrast(image));
% binary 
h=imfreehand;
bw=createMask(h);
STATS_red=regionprops(bw, image(:,:,1),'PixelIdxList','PixelList','PixelValues');
STATS_green=regionprops(bw, image(:,:,2),'PixelIdxList','PixelList','PixelValues');

STATS_red=STATS_red(1);
STATS_green=STATS_green(1);
% get the coordinates of the
y=STATS_green.PixelList(:,2);
red_inten=STATS_red.PixelValues;
green_inten=STATS_green.PixelValues;
[B,IX]=sort(y);
y=y(IX);
red_inten=double(red_inten(IX));
green_inten=double(green_inten(IX));

unique_y=unique(y);
red_inten_mean=[];
red_inten_std=[];
green_inten_mean=[];
green_inten_std=[];

ysame_red=[];
ysame_green=[];



for i=1:length(unique_y)
    ysame_red=red_inten(y==unique_y(i));
    ysame_green=green_inten(y==unique_y(i));
    red_inten_mean(i)=mean(ysame_red);
    red_inten_std(i)=std(ysame_red);
    green_inten_mean(i)=mean(ysame_green);
    green_inten_std(i)=std(ysame_green);
    clear ysame_red ysame_green
end

% plot(y, intensity)
% calculate the mean and standard deviation along the cilia



xvalue=(double(unique_y)-double(min(unique_y)))*0.08;
yvalue_red_normalize=red_inten_mean'/max(red_inten_mean);
yerror_red=(red_inten_std'./red_inten_mean').*(yvalue_red_normalize);
yvalue_green_normalize=green_inten_mean'/max(green_inten_mean);
yerror_green=(green_inten_std'./green_inten_mean').*(yvalue_green_normalize);

yvalue_red_upperlimit=yvalue_red_normalize+yerror_red;
yvalue_red_lowerlimit=yvalue_red_normalize-yerror_red;
yvalue_green_upperlimit=yvalue_green_normalize+yerror_green;
yvalue_green_lowerlimit=yvalue_green_normalize-yerror_green;





figure(1);
plot(xvalue,yvalue_red_normalize,'r-');
hold on
%plot(xvalue,yvalue_red_upperlimit,'r--');
%plot(xvalue,yvalue_red_lowerlimit,'r--');
plot(xvalue,yvalue_green_normalize,'g-');
%plot(xvalue,yvalue_green_upperlimit,'g--');
%plot(xvalue,yvalue_green_lowerlimit,'g--');


xlabel('Distance(um)');
ylabel('Intesentiy Along Cilia(a.u.)');

saveas(figure(1),[FileName(1:end-4) '_intensityalongcilia.fig'],'fig')
saveas(figure(1),[FileName(1:end-4) '_intensityalongcilia.tiff'],'tiffn')
save([FileName(1:end-4) 'main.mat']);



