% PCDdiagnosis_meanintensity_projection_imagesc
   
% For the green channel 
   green_raw_mean=mean(green_raw,3); 
   figure
   imagesc(green_raw_mean)
   colorbar
   imcontrast   
% For the red channel
   red_raw_mean=mean(red_raw,3); 
   figure
   imagesc(red_raw_mean)
   colorbar
   imcontrast   
