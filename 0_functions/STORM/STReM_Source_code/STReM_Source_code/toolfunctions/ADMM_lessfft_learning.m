function [u1, recall, precision,img_raw_new] = ADMM_lessfft_learning(imgs, dhpsf,N)
img_raw_new=0;
[ny, nx, nz] = size(dhpsf);
%nz = size(dhpsf, 3);
up_res = 3;% each pixel in image is break into 3X3 pixels, meaning dhpsf should be 3X3 larger than image
im_temp = zeros(ny, nx);
inx1 = round(up_res/2):up_res:ny;
inx2 = round(up_res/2):up_res:nx;
size(imgs);
inx1;
inx2;
im_temp(inx1, inx2) = imgs;
y = im_temp(:)';
T = zeros(1, nz); T(nz) = 1;
A = dhpsf;
fx = zeros(size(dhpsf));
feta0 = fx; feta1 = fx;
lambda = 0.005; % lambda = 0.005 was very good
mu = min(1,50000*lambda);% those three parameters may difficult to decide, 0.5 was good
%mu = 1;
nu = mu/10/lambda;
%nu = 20;
%nu=1;
%mu = 1;nu=1;
%N = 1000;
TT = (T'*T+mu*eye(nz));
fA = fftn(A);
invall = abs(fA).^2+nu;
thd = max(imgs(:))/max(dhpsf(:))*0.1/5;
%thd = 0;

%%
u0_2d = TT\(T'*y);
u0 = reshape(u0_2d', ny, nx, nz);
fu0 = fftn(u0);
fu1 = zeros(size(u0));
fig_i = 20000+round(rand*100);
%N2 = 1000;
recall = zeros(1, N);
precision = zeros(1, N);
for k = 1:N
    %k    
    if mod(k+1,floor(N/4))==0
        disp([num2str(round(k*100/N)),'% complished']);
    end
    
    ftemp_1 = conj(fA).*(fu0-feta0);            % deconvolution with PSF without normalization
    %ftemp_1 = conj(fA).*(fu0-feta0)./abs(fA);
    fx = (ftemp_1+nu*(fu1-feta1))./invall;
    fAx = fA.*fx;
    feta0 = feta0-(fu0-fAx);
    feta1 = feta1-(fu1-fx);
    Ax_eta_2d = ifftn(fAx+feta0);               % updated 3D raw images + original raw image
    if nz > 1
        Ax_eta_2d = reshape(XYZ_rot(Ax_eta_2d, [3,1,2]), nz, ny*nx);
    else
        Ax_eta_2d = Ax_eta_2d(:)';
    end
    u0_2d = TT\(T'*y+mu*Ax_eta_2d);
    u0 = reshape(u0_2d', ny, nx, nz);
    
    fu0 = fftn(u0);
    
    x_eta1 = ifftn(fx+feta1);
    %x_eta1 = ifftn(fx+feta1-lambda/nu);
    
    u1 = max(x_eta1-thd, 0);
    
    fu1 = fftn(u1);
%
    if rem(k,100)==0
        eta0 = ifftn(feta0);
        tp = eta0(2:up_res:end,2:up_res:end,end);
        %median(tp(:))
        im_temp(inx1, inx2) = im_temp(inx1, inx2)+median(tp(:));
        y = im_temp(:)';
    end
    img_raw_new=im_temp(inx1,inx2);
 %}
    
    
    %{
    u11 = fftshift(u1);
    u11 = ifftshift(u11,3);
    [center, elx, ely, elz] = local_max(u11);
    elx = elx(center>0);
    ely = ely(center>0);
    elz = elz(center>0);
    %I = center(center>0);
    q = find(center>0);
    [iy,ix,iz] = ind2sub(size(center), q);
    pos2 = [elx+ix, ely+iy, elz+iz];
    map2 = mapping_frames_2(pos1,pos2,3);
    recall(k) = sum(map2(:,1)>0 & map2(:,2)>0)/size(pos1,1);
    if size(pos2,1)==0
        precision(k) = 0;
    else
        precision(k) = sum(map2(:,1)>0 & map2(:,2)>0)/size(pos2,1);
    end
    
    figure(fig_i)
    colormap gray
    imagesc(fftshift(sum(u1,3))); hold on
    plot(pos1(:,1), pos1(:,2),'og');
    title(['k=' num2str(k) '  recall is:' num2str(recall(k)) '  precision is:' num2str(precision(k))]);
    hold off;
    pause(0.001)
    %}
end



%%
%{
thread = max(u1(:))*0.05;
u1(u1<thread) = 0;
inx = u1>0;
fu1 = fftn(u1);
for k = N+1:N2+N

    ftemp_1 = conj(fA).*(fu0-feta0);
    fx = (ftemp_1+nu*(fu1-feta1))./invall;
    fAx = fA.*fx;
    feta0 = feta0-(fu0-fAx);
    feta1 = feta1-(fu1-fx);
    Ax_eta_2d = ifftn(fAx+feta0);
    if nz > 1
        Ax_eta_2d = reshape(XYZ_rot(Ax_eta_2d, [3,1,2]), nz, ny*nx);
    else
        Ax_eta_2d = Ax_eta_2d(:)';
    end
    u0_2d = TT\(T'*y+mu*Ax_eta_2d);
    u0 = reshape(u0_2d', ny, nx, nz);
    fu0 = fftn(u0);
    x_eta1 = ifftn(fx+feta1);
    u1(inx) = max(x_eta1(inx)-thd, 0);
    fu1 = fftn(u1);
    
    
    u11 = fftshift(u1);
    u11 = ifftshift(u11,3);
    [center, elx, ely, elz] = local_max(u11);
    elx = elx(center>0);
    ely = ely(center>0);
    elz = elz(center>0);
    %I = center(center>0);
    q = find(center>0);
    [iy,ix,iz] = ind2sub(size(center), q);
    pos2 = [elx+ix, ely+iy, elz+iz];
    map2 = mapping_frames_2(pos1,pos2,3);
    recall(k) = sum(map2(:,1)>0 & map2(:,2)>0)/size(pos1,1);
    if size(pos2,1)==0
        precision(k) = 0;
    else
        precision(k) = sum(map2(:,1)>0 & map2(:,2)>0)/size(pos2,1);
    end
    
    figure(fig_i+1)
    colormap gray
    imagesc(fftshift(sum(u1,3))); hold on
    plot(pos1(:,1), pos1(:,2),'og');
    title(['k=' num2str(k) '  recall is:' num2str(recall(k)) '  precision is:' num2str(precision(k))]);
    hold off;
    pause(0.001)
end
%}
u1 = fftshift(u1);
u1 = ifftshift(u1,3);

%figure
%imagesc(sum(u1,3))

%%
%thread = max(u1(:))*0.05;

