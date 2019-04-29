close all;clc
d4_all=d1_all./d3_all;
figure
subplot(1,3,1);
hist(d1_all,20)
subplot(1,3,2);
hist(d3_all,20)
subplot(1,3,3);
hist(d4_all,20)
%

display('----------------------------------------------------------------')
display('The mean value is')
display(num2str(mean(d4_all)));
display('----------------------------------------------------------------')
display('The median value is')
display(num2str(median(d4_all)));
display('----------------------------------------------------------------')
display('The standard deviation is')
display(num2str(std(d4_all)))
display('----------------------------------------------------------------')
display('The total cell number is')
display(num2str(length(d4_all)))
display('----------------------------------------------------------------')






