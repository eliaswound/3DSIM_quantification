Aligned=[0.951 0.5116	0.5036	0.6056	0.955]';
Random=[0.049 0.4884	0.4964	0.3944	0.045]';
fig = figure;
bar(1:5, [Aligned Random], 0.5, 'stack','FaceColor',[0.992 0.26 0.39],'EdgeColor',[0.992 0.26 0.39]);
hold on 
bar(1:5,Aligned,0.5,'FaceColor',[0.51 0.684 0.61],'EdgeColor',[0.51 0.684 0.61]);
box off
ylim([0 1.1])
ylabel('Percentage of cells with aligned basal bodies')
set(gca,'XTick',1:5)
set(gca,'XTickLabel',{'WT','DNAH5','DNAH11','HYDIN','Cystic Fibrosis'})


