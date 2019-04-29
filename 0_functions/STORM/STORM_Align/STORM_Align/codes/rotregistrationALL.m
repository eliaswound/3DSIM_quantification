

function [aligniter,iterIm,s,n_frame,allIm] = rotregistrationALL(images,usfac,angrange,angstep,n_iteration)

imagesize = size(images);
n_frame = imagesize(3);
s = imagesize(1);
sumim = zeros(s,s); 
phase = [];
CCall = [];
aligniter = [];

% superimpose all images
for index = 1:n_frame
    sumim = sumim + images(:,:,index);
end

% align images for n_iterations iterations
for iter = 1:n_iteration
    
        fprintf('--------iteration %d --------\n',iter);
        
        % align image k, the reference is all the other images
        for k=1:n_frame;
            
            fprintf('image %d\n',k);
            im2 = images(:,:,k);
            im1 = sumim-images(:,:,k);
            ft1 = fft2(im1);
            ft2 = fft2(im2);

            [Greg,row_shift,col_shift,Angle] = rotregistration(ft1,ft2,usfac,angrange,angstep);
                    
            alignk = [Angle row_shift col_shift];   %angle row_shift col_shift 
       
            %phase(:,:,k) = diffphase;
            %CCall = [CCall maxall];
            A = abs(ifft2(Greg));
            images(:,:,k)= A;
            allIm(:,:,k,iter)=A;
            aligniter(k,:,iter)= alignk;
            %figure, imshow(A/50);

        end
       
        [sumim]= sumimage(s,n_frame,images);
        iterIm(:,:,iter)=sumim;
      
end
 
return

    
