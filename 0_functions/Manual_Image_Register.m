% manual_image_register
% Step1: read the unregistered image 
[FileName_unregister,PathName_unregister]=uigetfile('*.tiff','Please select the file you want to register');
cd(PathName_unregister);
unregistered=imread(FileName_unregister);
figure; imshow(autocontrast(unregistered));

% Step2: read the reference image 
[FileName_reference,PathName_reference]=uigetfile('*.tiff','Please select the file you want to use as reference');
reference=imread(FileName_reference);
figure; imshow(autocontrast(reference));


% Step3: Manually select the point pairs for registeration

cpselect(autocontrast(unregistered), autocontrast(reference));

% Step4: Generate the form file 
%tform=cp2tform(input_points, base_points, 'projective');
tform=cp2tform(movingPoints, fixedPoints, 'projective');

% Step5: Apply the tform to unregistered image

info=imfinfo(FileName_unregister);
% registered=imtransform(unregistered,tform,...
% 'XData',[1 info.Width], 'YData',[1 info.Height]);
 
 registered=imwarp(unregistered,tform);


% Step6: save the registered image
imwrite(registered,[FileName_unregister(1:end-5) '_registered.tiff'],'Compression','none')

