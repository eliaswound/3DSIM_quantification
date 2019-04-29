function [dhpsf] = psf3d_kernel_07302015(mask_record, kdph, zn, up, xc, yc, zc, N, ri, phase_max)
%zn = 11;
%up = 3;
[X, Y] = meshgrid(1:200, 1:200);
dhpsf = zeros(up*N, up*N, zn);
zp = linspace(-2, 2, zn)+zc;
z_max = 2;
phase=phase_ex_04022015(150/2,phase_max*10*1e-7,200,200);
for n = 1:zn
    ph_xy = abs(X-100.5+1i*(Y-100.5)).*abs(xc+1i*yc)*7/100.*cos(angle(X-100.5+1i*(Y-100.5))-angle(xc+1i*yc));
    
    %t2 = fftshift(ifft2(pm2.*exp(1i*kdph*zp(n)/z_max*phase_max*pi).*exp(1i*ph_xy), up*N, up*N));
    %t2 = fftshift(ifft2(pm2.*exp(1i*kdph*zp(n)/z_max*phase_max*pi), up*N,up*N));
    %dhpsf(:,:,n) = abs(t2).^2;
    
    
    for j=1:1:1  %1 or 10
        if (n-1)*10+zc+j>210
            u2=fftshift(ifft2(mask_record(:,:,(n-1)*10+zc+j-210).*exp(1i*ph_xy).*exp(1i*phase),N*up,N*up));
        end
        if (n-1)*10+zc+j>0&&(n-1)*10+zc+j<211
            u2=fftshift(ifft2(mask_record(:,:,(n-1)*10+zc+j).*exp(1i*ph_xy).*exp(1i*phase),N*up,N*up));
        end
        if (n-1)*10+zc+j<0
            u2=fftshift(ifft2(mask_record(:,:,210+(n-1)*10+zc+j).*exp(1i*ph_xy).*exp(1i*phase),N*up,N*up));
        end
        temp=abs(u2).^2;
        temp=temp/10;
        dhpsf(:,:,n)=dhpsf(:,:,n)+temp;
        

    end
    
    
end
dhpsf = dhpsf*ri;