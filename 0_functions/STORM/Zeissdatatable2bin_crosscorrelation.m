% zeiss data table to bin + cross correlation 
% zeiss datatable to bin file
clear;close all;clc;

[FileName,PathName] = uigetfile('*.txt','select the zeiss data table');
cd(PathName);
DATA=importdata(FileName);
vars = fieldnames(DATA);
for i = 1:length(vars)
    assignin('base', vars{i}, DATA.(vars{i}));
end
% erase the NaN rows
data(data(:,5)==NaN|data(:,6)==NaN|data(:,7)==NaN)=[];
pixelsize=160; %nm
coords(:,1:2)=data(:,5:6)/pixelsize;
coords(:,3)=data(:,2);

[coordscorr, finaldrift, A,b] = RCC(coords, 2000, 128, pixelsize, 30,0.2);
clc;
display('auto correlation finished')
%index=find(data(:,7)>50);
%coordscorr(index,:)=[];
%data(index,:)=[];

figure
scatter(finaldrift(1:500:end,1)*pixelsize,finaldrift(1:500:end,2)*pixelsize,20,(1:500:length(finaldrift))','o','filled')
%hold on
%plot(finaldrift(1:500:end,1),finaldrift(1:500:end,2),'k-')
xlabel('drift in x(nm)')
ylabel('drift in y(nm)')
title('drift corretion by cross correlation')
colorbar

% assign the molecule list
zposition=(data(:,7)-mean(data(:,7)))*0.72;   % calibration the error brought by index mismatch
moleculelist.x=single(coordscorr(:,1));   % pixel
moleculelist.xc=single(coordscorr(:,1));
moleculelist.y=single(coordscorr(:,2));
moleculelist.yc=single(coordscorr(:,2));
moleculelist.z=single(zposition);
moleculelist.zc=single(zposition);
moleculelist.h=single(1000*ones(length(data),1));
moleculelist.a=single(10000*ones(length(data),1));
%moleculelist.a=single(data(:,10));
moleculelist.w=single(300*ones(length(data),1));
moleculelist.phi=single(300*ones(length(data),1));
moleculelist.ax=single(300*ones(length(data),1));
moleculelist.bg=single(data(:,11));
moleculelist.i=single(1000*ones(length(data),1));
moleculelist.c=int32(ones(length(data),1));
moleculelist.density=int32(ones(length(data),1));
moleculelist.frame=int32(data(:,2));
moleculelist.length=int32(data(:,3));
moleculelist.link=int32(300*ones(length(data),1));
% write molecule list
WriteMoleculeList(moleculelist,[FileName(1:end-4) '_crosscorr_50nm.bin'])
display('finished')