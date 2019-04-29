


Aligned=[0.904 0.6368	0.9099	0.8235	0.8902]';
Random=[0.096 0.3632	0.0901	0.1765	0.1098]';
fig = figure;
bar(1:5, [Aligned Random], 0.5, 'stack','FaceColor',[0.992 0.26 0.39],'EdgeColor',[0.992 0.26 0.39]);
hold on 
bar(1:5,Aligned,0.5,'FaceColor',[0.51 0.684 0.61],'EdgeColor',[0.51 0.684 0.61]);
box off
ylim([0 1.1])
ylabel('Aligned vector distrbution')
set(gca,'XTick',1:5)
set(gca,'XTickLabel',{'WT','RP11','RP13','RP14','RP15'})


