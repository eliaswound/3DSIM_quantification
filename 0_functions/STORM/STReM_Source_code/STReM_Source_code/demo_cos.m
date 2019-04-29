clear all
close all
clc



m_z = 2;
z_max = m_z/2;
mode=0;
[X, Y] = meshgrid(1:200, 1:200);
rm = sqrt((X-100.5).^2+(Y-100.5).^2)<=100.5;
kdph = 1-0.5*((X-100.5).^2+(Y-100.5).^2)/100^2*(2.7/2/100)^2;% 2.7 mm beam size
load('mask_record_ww.mat');%phase mask of different orientations

i = 1:200;
[ii,jj] = meshgrid(i,i);
cir = sqrt((ii-100.5).^2+(jj-100.5).^2)<100;%circular aparture
N = 320;
phase_max = 0;
%% Generation of A matrix and the partial difference of A
for i=1:1:1
rsz = 44;

zn = 21;
up = 3;
A = zeros(up*rsz, up*rsz, zn);
zp = linspace(-m_z/2, m_z/2, zn);
PSF=zeros(N*up,N*up,zn);

for n = 1:zn
    for j=1:1:1
        u2=fftshift(ifft2(cir.*exp(1i*angle(1*mask_record(:,:,(n-1)*10+j))),N*up,N*up));
        u2=u2(round(N/2*up)-rsz/2*up+1:round(N/2*up)+rsz/2*up,round(N/2*up)-rsz/2*up+1:round(N/2*up)+rsz/2*up,:);
        temp=abs(u2).^2/10;
        A(:,:,n)=A(:,:,n)+temp;%A matrix contains 21 different layers
    end
end
ri = 1/max(A(:));
A = A*ri;

delta = 0.5;
sft = delta/6.6545;

PSF_temp1 = psf3d_kernel_07302015(mask_record, kdph, zn, up, -sft, 0, 0, N, ri, phase_max);
PSF_temp2 = psf3d_kernel_07302015(mask_record, kdph, zn, up, sft, 0, 0, N, ri, phase_max);


PSF_dev_x = (PSF_temp2-PSF_temp1)/delta/2;
dx = PSF_dev_x(round(N/2*up)-rsz/2*up+1:round(N/2*up)+rsz/2*up,round(N/2*up)-rsz/2*up+1:round(N/2*up)+rsz/2*up,:);

clear PSF_dev_x

PSF_temp1 = psf3d_kernel_07302015(mask_record, kdph, zn, up, 0, -sft, 0, N, ri, phase_max);
PSF_temp2 = psf3d_kernel_07302015(mask_record, kdph, zn, up, 0, sft, 0, N, ri, phase_max);


PSF_dev_y = (PSF_temp2-PSF_temp1)/delta/2;
dy = PSF_dev_y(round(N/2*up)-rsz/2*up+1:round(N/2*up)+rsz/2*up,round(N/2*up)-rsz/2*up+1:round(N/2*up)+rsz/2*up,:);

clear PFS_dev_y


PSF_temp1 = psf3d_kernel_07302015(mask_record, kdph, zn, up, 0, 0, -5, N, ri, phase_max);
PSF_temp2 = psf3d_kernel_07302015(mask_record, kdph, zn, up, 0, 0, +5, N, ri, phase_max);


PSF_dev_z = (PSF_temp2-PSF_temp1)/delta/2;
dz = PSF_dev_z(round(N/2*up)-rsz/2*up+1:round(N/2*up)+rsz/2*up,round(N/2*up)-rsz/2*up+1:round(N/2*up)+rsz/2*up,:);
%fdz = fftn(dz);
clear PSF_dev_z
clear PSF_temp*

end

%addpath('C:\Users\ww20\Desktop\06262015');
%% Recovery 
np = 40;
itr_max = 1;
err_t_rec=[];
err_dis_rec=[];
for j=1:itr_max
    
    cos_movement; %Simulation of the cos_trajectory
    im2=im2-min(im2(:));
    [u1,p1,pp1,img_raw_new] = ADMM_lessfft_learning(im2, A,2000);% ADMM L1 norm constrained minimization
    lambda=0.1; %step size
    ratio=0.03; 
    max_loop = 1;
    paratrj = step3_solver_ww(u1, A, dx,dy,dz,img_raw_new,max_loop,lambda,ratio);% L2 norm constrained confinement
    I = paratrj(:,end-3);
    pos2 = paratrj(I>0,end-2:end);%Pos2: Recovered position
end
%% Plotting

pos11 = sortrows(pos2,3);
close all;
pos2=pos11;
pos1=pos2;
tt=pos2(:,3);
t1=tt/210*100;
pos1(:,3)=t1;
pos1=sortrows(pos1,1);
flag=1; 
figure;plot(1);colorbar;
ab=[];

t11=1-pos1(:,3)/max(pos1(:,3));
for i=1:1:numel(t11)
f=t11(i);
cm = colormap; % returns the current color map
colorID = max(1, sum(f > [0:1/length(cm(:,1)):1])); 
myColor = cm(colorID, :); % returns color
ab=[ab;myColor];%store the color information of the emitters
end

ak=im2;
figure(101);imagesc(ak);colormap gray;hold on;axis square;

params2=pos1;
for i=1:1:size(ab,1)
    plot(params2(i,1)/3+0,params2(i,2)/3-0,'+','Markersize',7,'linewidth',3,'Color',[ab(i,1)*1,ab(i,2)*1,ab(i,3)]*1);
end


