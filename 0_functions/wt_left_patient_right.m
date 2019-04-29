
all(all(:,10)==0,12)=1;
all(all(:,10)==1,12)=0;


figure;
subplot(3,2,1);
boxplot(all(:,4),all(:,12));
ylabel('DNAH11 In Whole Cell(Arbitary Units)');
box off
subplot(3,2,3);
boxplot(all(:,5),all(:,12));
ylabel('atubulin In Whole Cilia(Arbitary Units)');
box off
subplot(3,2,5);
boxplot(all(:,6),all(:,12));
ylabel('DNAH11 In Whole Cilia(Arbitary Units)');
subplot(3,2,2);
boxplot(all(:,7),all(:,12));
ylabel('Colocalization Percentage(Red Area)');
box off
subplot(3,2,4);
boxplot(all(:,8),all(:,12));
ylabel('Colocalization Percentage(Red Intensity)');
box off
subplot(3,2,6);
boxplot(all(:,9),all(:,12));
ylabel('Colocalization Percentage(Green Intensity)');
box off

final(final(:,14)==0,15)=1;
final(final(:,14)==1,15)=0;


figure;
subplot(3,2,1);
bar(final(:,end),final(:,2));
hold on
errorbar(final(:,end),final(:,2),final(:,3),'b.');
ylabel('DNAH11 In Whole Cell(Arbitary Units)');
box off
subplot(3,2,3);
bar(final(:,end),final(:,4));
hold on
errorbar(final(:,end),final(:,4),final(:,5),'b.');
ylabel('aTubulin In Whole Cilia(Arbitary Units)');
box off
subplot(3,2,5);
bar(final(:,end),final(:,6));
hold on
errorbar(final(:,end),final(:,6),final(:,7),'b.');
ylabel('DNAH11 In Whole Cilia(Arbitary Units)');
box off
subplot(3,2,2);
bar(final(:,end),final(:,8));
hold on
errorbar(final(:,end),final(:,8),final(:,9),'b.');
ylabel('Colocalization Percentage(Red Area)');
box off
subplot(3,2,4);
bar(final(:,end),final(:,10));
hold on
errorbar(final(:,end),final(:,10),final(:,11),'b.');
ylabel('Colocalization Percentage(Red Intensity)');
box off
subplot(3,2,6);
bar(final(:,end),final(:,12));
hold on
errorbar(final(:,end),final(:,12),final(:,13),'b.');
ylabel('Colocalization Percentage(Green Intensity)');
box off  