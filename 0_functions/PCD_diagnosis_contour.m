function [level,bw,bw2,B,L,max_I,fig1,fig2,fig3,fig4,object_largest2]=PCD_diagnosis_contour(image,level)
% calculate the size of the nucleous
    [m,n] = size(image);
    image_normalize=image/max(max(single(image)));
    scrsz = get(0,'ScreenSize');
    fig1=figure(1);%1; 
    clf;imagesc(image_normalize); axis equal;colorbar;
    bw=im2bw(image_normalize,level);
    truesize(fig1,[scrsz(3)/4,scrsz(4)/4])
    fig2=figure(2);%2
    imshow(bw);
    bw2=imfill(bw,'holes');
    [B,L] = bwboundaries(bw2);
    truesize(fig2,[scrsz(3)/4,scrsz(4)/4])
    fig3=figure(3);%3
    imshow(bw2);
    figure(1),hold on
    boundary_size=[];
    for k=1:length(B)
        temp=B{k,1};
        boundary_size(k,1)=length(temp);
        clear temp
    end
    [max_C,max_I]=max(boundary_size);
    boundary_largest=B{max_I};
    plot(boundary_largest(:,2),...
               boundary_largest(:,1),'r','LineWidth',2);
           
    s=regionprops(bw2,'PixelIdxList');       
    
    for k=1:length(s)
        temp=s(k,1).PixelIdxList;
        s_size(k,1)=length(temp);
        clear temp
    end  
    [max_C2,max_I2]=max(s_size);
    index=s(max_I2,1).PixelIdxList;
    object_largest=zeros(m,n);
    object_largest(index)=1;
    object_largest2=logical(object_largest);
    truesize(fig3,[scrsz(3)/4,scrsz(4)/4])
    fig4=figure(4); % 4,
    imshow(object_largest2);
    truesize(fig4,[scrsz(3)/4,scrsz(4)/4])
end









