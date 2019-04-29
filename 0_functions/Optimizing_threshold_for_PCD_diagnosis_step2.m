[B,IX] = sort(all(:,2));
all=all(IX,:);
threshold_unique=unique(all(:,2));

final_wt=[];
final_p=[];


for w=1:length(threshold_unique)
    DNAH11_wt_mean=mean(all(all(:,2)==threshold_unique(w)&all(:,10)==1,4));
    DNAH11_wt_std=std(all(all(:,2)==threshold_unique(w)&all(:,10)==1,4));
    atub_wt_mean=mean(all(all(:,2)==threshold_unique(w)&all(:,10)==1,5));
    atub_wt_std=std(all(all(:,2)==threshold_unique(w)&all(:,10)==1,5));
    DNAH11cilia_wt_mean=mean(all(all(:,2)==threshold_unique(w)&all(:,10)==1,6));
    DNAH11cilia_wt_std=std(all(all(:,2)==threshold_unique(w)&all(:,10)==1,6));
    RedArea_wt_mean=mean(all(all(:,2)==threshold_unique(w)&all(:,10)==1,7));
    RedArea_wt_std=std(all(all(:,2)==threshold_unique(w)&all(:,10)==1,7));
    RedInten_wt_mean=mean(all(all(:,2)==threshold_unique(w)&all(:,10)==1,8));
    RedInten_wt_std=std(all(all(:,2)==threshold_unique(w)&all(:,10)==1,8));
    GreenInten_wt_mean=mean(all(all(:,2)==threshold_unique(w)&all(:,10)==1,9));
    GreenInten_wt_std=std(all(all(:,2)==threshold_unique(w)&all(:,10)==1,9));
    final_wt=[final_wt;threshold_unique(w),DNAH11_wt_mean,DNAH11_wt_std,atub_wt_mean,atub_wt_std,DNAH11cilia_wt_mean,...
        DNAH11cilia_wt_std,RedArea_wt_mean, RedArea_wt_std,RedInten_wt_mean,RedInten_wt_std,GreenInten_wt_mean,GreenInten_wt_std];
    
    DNAH11_pa_mean=mean(all(all(:,2)==threshold_unique(w)&all(:,10)==0,4));
    DNAH11_pa_std=std(all(all(:,2)==threshold_unique(w)&all(:,10)==0,4));
    atub_pa_mean=mean(all(all(:,2)==threshold_unique(w)&all(:,10)==0,5));
    atub_pa_std=std(all(all(:,2)==threshold_unique(w)&all(:,10)==0,5));
    DNAH11cilia_pa_mean=mean(all(all(:,2)==threshold_unique(w)&all(:,10)==0,6));
    DNAH11cilia_pa_std=std(all(all(:,2)==threshold_unique(w)&all(:,10)==0,6));
    RedArea_pa_mean=mean(all(all(:,2)==threshold_unique(w)&all(:,10)==0,7));
    RedArea_pa_std=std(all(all(:,2)==threshold_unique(w)&all(:,10)==0,7));
    RedInten_pa_mean=mean(all(all(:,2)==threshold_unique(w)&all(:,10)==0,8));
    RedInten_pa_std=std(all(all(:,2)==threshold_unique(w)&all(:,10)==0,8));
    GreenInten_pa_mean=mean(all(all(:,2)==threshold_unique(w)&all(:,10)==0,9));
    GreenInten_pa_std=std(all(all(:,2)==threshold_unique(w)&all(:,10)==0,9));
    final_p=[final_p;threshold_unique(w),DNAH11_pa_mean,DNAH11_pa_std,atub_pa_mean,atub_pa_std,DNAH11cilia_pa_mean,...
        DNAH11cilia_pa_std,RedArea_pa_mean, RedArea_pa_std,RedInten_pa_mean,RedInten_pa_std,GreenInten_pa_mean,GreenInten_pa_std];
    
end
figure;
subplot(3,2,1);
errorbar(final_wt(:,1),final_wt(:,2),final_wt(:,3),'b-');
hold on
errorbar(final_p(:,1),final_p(:,2),final_p(:,3),'r-');
xlabel('threshold');
ylabel('DNAH11 in cell');
subplot(3,2,3);
errorbar(final_wt(:,1),final_wt(:,4),final_wt(:,5),'b-');
hold on
errorbar(final_p(:,1),final_p(:,4),final_p(:,5),'r-');
xlabel('threshold');
ylabel('atubulin in cell');
subplot(3,2,5);
errorbar(final_wt(:,1),final_wt(:,6),final_wt(:,7),'b-');
hold on
errorbar(final_p(:,1),final_p(:,6),final_p(:,7),'r-');
xlabel('threshold');
ylabel('DNAH11 in cilia');

subplot(3,2,2);
errorbar(final_wt(:,1),final_wt(:,8),final_wt(:,9),'b-');
hold on
errorbar(final_p(:,1),final_p(:,8),final_p(:,9),'r-');
xlabel('threshold');
ylabel('redoverlaparea');
subplot(3,2,4);
errorbar(final_wt(:,1),final_wt(:,10),final_wt(:,11),'b-');
hold on
errorbar(final_p(:,1),final_p(:,10),final_p(:,11),'r-');
xlabel('threshold');
ylabel('redoverlapintensity');

subplot(3,2,6);

errorbar(final_wt(:,1),final_wt(:,12),final_wt(:,13),'b-');
hold on
errorbar(final_p(:,1),final_p(:,12),final_p(:,13),'r-');
xlabel('threshold');
ylabel('greenoverlapintensity');

% final format
% column1:threshold
% column2: mean_
% column3: std

%  temp2=[double(temp.threshold(1)),double(temp.threshold(2)),...
%        double(temp.cell_volume),double(temp.DNAH11_integratedintensity),...
%    double(temp.tubulin_integratedintensity),...
%    double(temp.DNAH11_cilia_integratedintensity),...
%    double(temp.colocalization_RedOverlapArea),...
%   double(temp.colocalization_RedOverlapIntIntensityRatio),...
%   double(temp.colocalization_GreenOverlapIntIntensityRatio),double(temp.wt),double(j)];