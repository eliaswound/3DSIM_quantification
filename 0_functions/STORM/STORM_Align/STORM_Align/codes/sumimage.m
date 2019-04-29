function [sumim]= sumimage(s,n_frame,images)
sumim = zeros(s,s);
for index = 1:n_frame
    sumim = sumim + images(:,:,index);
end