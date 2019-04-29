% Zeissdatatable2bin_crosscorrelation
% combine 2 txt files
clear;close all;clc;

[FileName1,PathName1] = uigetfile('*.txt','select the first zeiss data table');
cd(PathName1);
DATA1=importdata(FileName1);
vars1 = fieldnames(DATA1);
for i = 1:length(vars1)
    assignin('base', vars1{i}, DATA1.(vars1{i}));
end
% erase the NaN rows
data(data(:,5)==NaN|data(:,6)==NaN|data(:,7)==NaN)=[];
data1=data;
clear data
[FileName2,PathName2] = uigetfile('*.txt','select the second zeiss data table');
cd(PathName2);
DATA2=importdata(FileName2);
vars2 = fieldnames(DATA2);
for i = 1:length(vars2)
    assignin('base', vars2{i}, DATA2.(vars2{i}));
end
% erase the NaN rows
data(data(:,5)==NaN|data(:,6)==NaN|data(:,7)==NaN)=[];
data2=data;
clear data
data=[data1;data2];


pixelsize=160; %nm
coords(:,1:2)=data(:,5:6)/pixelsize;
coords(:,3)=data(:,2);

[coordscorr, finaldrift, A,b] = RCC(coords, 2000, 128, pixelsize, 30,0.2);
clc;
display('auto correlation finished')
index=find(data(:,7)>50);
coordscorr(index,:)=[];
data(index,:)=[];

figure
scatter(finaldrift(1:500:end,1)*pixelsize,finaldrift(1:500:end,2)*pixelsize,20,(1:500:length(finaldrift))','o','filled')
%hold on
%plot(finaldrift(1:500:end,1),finaldrift(1:500:end,2),'k-')
xlabel('drift in x(nm)')
ylabel('drift in y(nm)')
title('drift corretion by cross correlation')
colorbar

% assign the molecule list
zposition=(data(:,7)-mean(data(:,7)))*0.79;   % calibration the error brought by index mismatch
moleculelist.x=single(coordscorr(:,1));   % pixel
moleculelist.xc=single(coordscorr(:,1));
moleculelist.y=single(coordscorr(:,2));
moleculelist.yc=single(coordscorr(:,2));
moleculelist.z=single(zposition);
moleculelist.zc=single(zposition);
moleculelist.h=single(1000*ones(length(data),1));
moleculelist.a=single(10000*ones(length(data),1));
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