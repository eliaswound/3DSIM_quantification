clear;close all;clc
a=-pi:pi/200:pi;
b=-pi:pi/200:pi;
R=10;
r=4;
x=(R+r*cos(a)).*cos(b);
y=(R+r*cos(a)).*sin(b);
z=r*sin(a);
figure
plot3k({x y z},...
       'ColorData',z,'ColorRange',[-0.5 0.5],'Marker',{'o',2},...
       'Labels',{'Peaks','Radius','','Intensity','Lux'},...
       'PlotProps',{'FontSize',12});
axis equal
