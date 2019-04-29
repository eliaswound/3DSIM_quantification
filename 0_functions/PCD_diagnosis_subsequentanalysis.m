% PCD diagnosis quantification subsequent analysis
  %clear;close all;clc;
  directoryname = uigetdir('D:', 'Pick a Directory Containing PCD diagnosis generated data');
  cd(directoryname);
  list=dir([directoryname '\*requireddata.mat']);
  summarytable=[];
  
  for i=1:length(list)
      name=list(i).name;
      data=importdata(name);
     % summarytable(i,1)=data.nucleus_area;
      summarytable(i,2)=data.cell_area;
      summarytable(i,3)=data.cell_perimeter;
      summarytable(i,4)=data.DNAH11_integratedintensity;  % important!
      summarytable(i,5)=data.tubulin_integratedintensity; % important!
      summarytable(i,6)=data.colocalization_RedOverlapArea; % important!
      summarytable(i,7)=data.colocalization_RedOverlapIntIntensityRatio; % important
      summarytable(i,8)=data.colocalization_GreenOverlapIntIntensityRatio; % important
      summarytable(i,9)=data.DNAH11_cilia_integratedintensity;
      %summarytable(i,9)=data.threshold(1); % important
     % summarytable(i,10)=data.threshold(2); % important
      %summarytable(i,11)=data.threshold(3); % important
      clear data
  end
