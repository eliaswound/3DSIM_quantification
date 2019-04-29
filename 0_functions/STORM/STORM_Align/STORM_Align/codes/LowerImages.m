function [Ifinal] = LowerImages(I,n)
% lower then contrast of images.  set values bigger than n * mean to
% n*mean
imagesize = size(I);
s = imagesize(1);

Ifinal=I;
NumberOfNonZeros = length(find(I(:)));
Isum = sum(sum(I));
Imean = Isum/NumberOfNonZeros;

for a=1:s
    for b=1:s
        if I(a,b)>(Imean*n)
            Ifinal(a,b)=Imean*n;
        end
    end   
end

    
