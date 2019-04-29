% zeiss datatable to bin file
[FileName,PathName] = uigetfile('*.txt','select the zeiss data table');
cd(PathName);
DATA=importdata(FileName);
vars = fieldnames(DATA);
for i = 1:length(vars)
    assignin('base', vars{i}, DATA.(vars{i}));
end
% erase the NaN rows
data(data(:,5)==NaN|data(:,6)==NaN|data(:,7)==NaN)=[];
% assign the molecule list
pixelsize=160;
zposition=(data(:,7)-mean(data(:,7)))*0.72;   % calibration the error brought by index mismatch
moleculelist.x=single(data(:,5)/pixelsize);   % pixel
moleculelist.xc=single(data(:,5)/pixelsize);
moleculelist.y=single(data(:,6)/pixelsize);
moleculelist.yc=single(data(:,6)/pixelsize);
moleculelist.z=single(zposition);
moleculelist.zc=single(zposition);
moleculelist.h=single(1000*ones(length(data),1));
%moleculelist.a=single(10000*ones(length(data),1));
moleculelist.a=single(data(:,10));
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
WriteMoleculeList(moleculelist,[FileName(1:end-4) '.bin'])