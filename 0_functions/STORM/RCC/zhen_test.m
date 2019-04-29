mol(:,1:2)=data(:,5:6)/160;
mol(:,3)=data(:,2);
[coordscorr, finaldrift, A,b] = RCC(coords(1:50000,:), 1000, 128, 160, 30,0.2);

