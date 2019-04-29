clear;close all;clc;

folder_name=uigetdir('Please select the folder that contains all file generated for SIM/Deconvolution/WideField');
cd(folder_name);
files_tiff = dir([folder_name '\*.ome.tiff']);
files_rawdata = dir([folder_name '\*_rawdata.mat']);

% threshold
red_threshold=1000;
green_threshold=1000;
all_SIM=[];
all_deconv=[];
all_widef=[];

for i=1:length(files_tiff)
    display('cell')
    display(num2str(i));
    display(files_tiff(i).name);
    display(files_tiff(i).name)
    display('in progress')
    % tiff file
     info = imfinfo(files_tiff(i).name);
     num_images = numel(info);
     for k = 1:num_images
         SpecificFrameImage=imread(files_tiff(i).name, k, 'Info', info);
         movie_raw(:,:,k)=SpecificFrameImage;
     end
   % seperate channels
     red_raw_SIM=movie_raw(:,:,1:1:end/6);
     red_raw_decon=movie_raw(:,:,(end/6+1):1:end/3);
     red_raw_widef=movie_raw(:,:,(end/3+1):1:end/2);
     green_raw_SIM=movie_raw(:,:,(end/2+1):1:2*end/3);
     green_raw_decon=movie_raw(:,:,(2*end/3+1):1:5*end/6);
     green_raw_widef=movie_raw(:,:,(5*end/6+1):1:end);
     
     
%      red_raw_SIM=movie_raw(:,:,1:6:end);
%      red_raw_decon=movie_raw(:,:,2:6:end);
%      red_raw_widef=movie_raw(:,:,3:6:end);
%      green_raw_SIM=movie_raw(:,:,4:6:end);
%      green_raw_decon=movie_raw(:,:,5:6:end);
%      green_raw_widef=movie_raw(:,:,6:6:end);
    
    clear movie_raw info num_images k SpeficiFrameImage
   % rawdata file
      
    data=importdata(files_rawdata(i).name);
             
    % initialize parameters
    SIM_red_pixel_sum=0;
    SIM_red_intensity_sum=0;
    SIM_green_pixel_sum=0;
    SIM_green_intensity_sum=0;
    SIM_pixeloverlap_sum=0;
    SIM_redoverlapintensity_sum=0;
    SIM_greenoverlapintensity_sum=0;
    cell_volume_SIM=0;
    
    Decon_red_pixel_sum=0;
    Decon_red_intensity_sum=0;
    Decon_green_pixel_sum=0;
    Decon_green_intensity_sum=0;
    Decon_pixeloverlap_sum=0;
    Decon_redoverlapintensity_sum=0;
    Decon_greenoverlapintensity_sum=0;
    cell_volume_deconv=0;
    
    Widef_red_pixel_sum=0;
    Widef_red_intensity_sum=0;
    Widef_green_pixel_sum=0;
    Widef_green_intensity_sum=0;
    Widef_pixeloverlap_sum=0;
    Widef_redoverlapintensity_sum=0;
    Widef_greenoverlapintensity_sum=0;
    cell_volume_widef=0;
    
    for j=1:data.num_images/2
        %frame_all=[frame_all;i];
        %red_temp=data.red_raw(:,:,i);
        %green_temp=data.green_raw(:,:,i);
        
        red_SIM_temp= red_raw_SIM(:,:,j);
        green_SIM_temp=green_raw_SIM(:,:,j);
        
        red_deconv_temp= red_raw_decon(:,:,j);
        green_deconv_temp=green_raw_decon(:,:,j);
        
        red_widef_temp= red_raw_widef(:,:,j);
        green_widef_temp=green_raw_widef(:,:,j);
        
    
        
        % Identify the pixel ID in the red-temp with the pixel value above
        % threshold
        red_index_SIM_refer=find(red_SIM_temp(data.InboundaryIndexlist_red)>red_threshold);
        red_index_SIM=data.InboundaryIndexlist_red(red_index_SIM_refer);
        
        red_index_deconv_refer=find(red_deconv_temp(data.InboundaryIndexlist_red)>red_threshold);
        red_index_deconv=data.InboundaryIndexlist_red(red_index_deconv_refer);
        
        
        red_index_widef_refer=find(red_widef_temp(data.InboundaryIndexlist_red)>red_threshold);
        red_index_widef=data.InboundaryIndexlist_red(red_index_widef_refer);
        
       
        % Refresh the parameters of the red parts
        SIM_red_pixel_temp=length(red_index_SIM);
        SIM_red_pixel_sum=SIM_red_pixel_sum+SIM_red_pixel_temp;
        SIM_red_intensity_temp=sum(red_SIM_temp(red_index_SIM));
        SIM_red_intensity_sum=SIM_red_intensity_sum+SIM_red_intensity_temp;
        
        
        Decon_red_pixel_temp=length(red_index_deconv);
        Decon_red_pixel_sum=Decon_red_pixel_sum+Decon_red_pixel_temp;
        Decon_red_intensity_temp=sum(red_deconv_temp(red_index_deconv));
        Decon_red_intensity_sum=Decon_red_intensity_sum+Decon_red_intensity_temp;
        
        
        
        Widef_red_pixel_temp=length(red_index_widef);
        Widef_red_pixel_sum=Widef_red_pixel_sum+Widef_red_pixel_temp;
        Widef_red_intensity_temp=sum(red_widef_temp(red_index_widef));
        Widef_red_intensity_sum=Widef_red_intensity_sum+Widef_red_intensity_temp;
                
        
        clear SIM_red_pixel_temp SIM_red_intensity_temp  red_index_SIM_refer
        clear Decon_red_pixel_temp Decon_red_intensity_temp   red_index_deconv_refer
        clear Widef_red_pixel_temp Widef_red_intensity_temp  red_index_widef_refer

        
        
        % Identify the pixel ID of in the green-temp with the pixel value above
        % threshold
        green_index_SIM_refer=find(green_SIM_temp(data.InboundaryIndexlist_green)>green_threshold);
        green_index_SIM=data.InboundaryIndexlist_green(green_index_SIM_refer);
        
        green_index_deconv_refer=find(green_deconv_temp(data.InboundaryIndexlist_green)>green_threshold);
        green_index_deconv=data.InboundaryIndexlist_green(green_index_deconv_refer);
        
        green_index_widef_refer=find(green_widef_temp(data.InboundaryIndexlist_green)>green_threshold);
        green_index_widef=data.InboundaryIndexlist_green(green_index_widef_refer);
        
        
        % Refresh the parameters of the green parts
        SIM_green_pixel_temp=length(green_index_SIM);
        SIM_green_pixel_sum=SIM_green_pixel_sum+SIM_green_pixel_temp;
        SIM_green_intensity_temp=sum(green_SIM_temp(green_index_SIM));
        SIM_green_intensity_sum=SIM_green_intensity_sum+SIM_green_intensity_temp;
        
        
        Decon_green_pixel_temp=length(green_index_deconv);
        Decon_green_pixel_sum=Decon_green_pixel_sum+Decon_green_pixel_temp;
        Decon_green_intensity_temp=sum(green_deconv_temp(green_index_deconv));
        Decon_green_intensity_sum=Decon_green_intensity_sum+Decon_green_intensity_temp;
        
        
        
        Widef_green_pixel_temp=length(green_index_widef);
        Widef_green_pixel_sum=Widef_green_pixel_sum+Widef_green_pixel_temp;
        Widef_green_intensity_temp=sum(green_widef_temp(green_index_widef));
        Widef_green_intensity_sum=Widef_green_intensity_sum+Widef_green_intensity_temp;
                
        
        clear SIM_green_pixel_temp SIM_green_intensity_temp  green_index_SIM_refer
        clear Decon_green_pixel_temp Decon_green_intensity_temp  green_index_deconv_refer
        clear Widef_green_pixel_temp Widef_green_intensity_temp  green_index_widef_refer
        
        
        
        
        % colocalization part calculation
        
        
        red_green_SIM_intersect=intersect(red_index_SIM, green_index_SIM);
        red_green_SIM_union=union(red_index_SIM, green_index_SIM);
        
        
        red_green_deconv_intersect=intersect(red_index_deconv, green_index_deconv);
        red_green_deconv_union=union(red_index_deconv, green_index_deconv);
        
        
        red_green_widef_intersect=intersect(red_index_widef, green_index_widef);
        red_green_widef_union=union(red_index_widef, green_index_widef);
        
        
        clear red_index_SIM red_index_deconv red_index_widef
        clear green_index_SIM green_index_deconv green_index_widef
        
        % Calculate the colocalization part     
        %    if ~isempty(length(red_green_intersect))
        
        
        SIM_pixeloverlap_temp=length(red_green_SIM_intersect);
        SIM_redoverlapintensity_temp=sum(red_SIM_temp(red_green_SIM_intersect));
        SIM_greenoverlapintensity_temp=sum(green_SIM_temp(red_green_SIM_intersect));  
        
        
        Deconv_pixeloverlap_temp=length(red_green_deconv_intersect);
        Deconv_redoverlapintensity_temp=sum(red_deconv_temp(red_green_deconv_intersect));
        Deconv_greenoverlapintensity_temp=sum(green_deconv_temp(red_green_deconv_intersect)); 
        
        Widef_pixeloverlap_temp=length(red_green_widef_intersect);
        Widef_redoverlapintensity_temp=sum(red_widef_temp(red_green_widef_intersect));
        Widef_greenoverlapintensity_temp=sum(green_widef_temp(red_green_widef_intersect)); 
        
        
        
        
        SIM_pixeloverlap_sum=SIM_pixeloverlap_sum+SIM_pixeloverlap_temp;
        SIM_redoverlapintensity_sum=SIM_redoverlapintensity_sum+SIM_redoverlapintensity_temp;
        SIM_greenoverlapintensity_sum=SIM_greenoverlapintensity_sum+SIM_greenoverlapintensity_temp;
        

        Decon_pixeloverlap_sum=Decon_pixeloverlap_sum+Deconv_pixeloverlap_temp;
        Decon_redoverlapintensity_sum=Decon_redoverlapintensity_sum+Deconv_redoverlapintensity_temp;
        Decon_greenoverlapintensity_sum=Decon_greenoverlapintensity_sum+Deconv_greenoverlapintensity_temp;
        

        
        Widef_pixeloverlap_sum=Widef_pixeloverlap_sum+Widef_pixeloverlap_temp;
        Widef_redoverlapintensity_sum=Widef_redoverlapintensity_sum+Widef_redoverlapintensity_temp;
        Widef_greenoverlapintensity_sum=Widef_greenoverlapintensity_sum+Widef_greenoverlapintensity_temp;
        

        clear SIM_redoverlapintensity_temp SIM_greenoverlapintensity_temp red_green_SIM_intersect
        clear Deconv_redoverlapintensity_temp Deconv_greenoverlapintensity_temp red_green_deconv_intersect
        clear Widef_redoverlapintensity_temp Widef_greenoverlapintensity_temp red_green_widef_intersect
        
        
        
        
       %and the volume of the cell 
        cell_volume_SIM=cell_volume_SIM+length(red_green_SIM_union);
        cell_volume_deconv=cell_volume_deconv+length(red_green_deconv_union);
        cell_volume_widef=cell_volume_widef+length(red_green_widef_union);

        clear red_green_SIM_union red_green_deconv_union red_green_widef_union 
        clear j
    
    end
    
    
    
     SIM_OverlapAreaDividedByRed=SIM_pixeloverlap_sum/SIM_red_pixel_sum;
     SIM_RedOverlapIntensityRatio=SIM_redoverlapintensity_sum/SIM_red_intensity_sum;
     SIM_GreenOverlapIntensityRatio=SIM_greenoverlapintensity_sum/SIM_green_intensity_sum;
     SIM_green_integrated_intensity_cilia=SIM_greenoverlapintensity_sum;
     SIM_green_integrated_intensity_cilia=SIM_greenoverlapintensity_sum;
    
     
     
     Decon_OverlapAreaDividedByRed=Decon_pixeloverlap_sum/Decon_red_pixel_sum;
     Decon_RedOverlapIntensityRatio=Decon_redoverlapintensity_sum/Decon_red_intensity_sum;
     Decon_GreenOverlapIntensityRatio=Decon_greenoverlapintensity_sum/Decon_green_intensity_sum;
     Decon_green_integrated_intensity_cilia=Decon_greenoverlapintensity_sum;
     Decon_green_integrated_intensity_cilia=Decon_greenoverlapintensity_sum;
     
     
     Widef_OverlapAreaDividedByRed=Widef_pixeloverlap_sum/Widef_red_pixel_sum;
     Widef_RedOverlapIntensityRatio=Widef_redoverlapintensity_sum/Widef_red_intensity_sum;
     Widef_GreenOverlapIntensityRatio=Widef_greenoverlapintensity_sum/Widef_green_intensity_sum;
     Widef_green_integrated_intensity_cilia=Widef_greenoverlapintensity_sum;
     Widef_green_integrated_intensity_cilia=Widef_greenoverlapintensity_sum;
     
    %--------------------------------------------------------------------------
    % data saving
    %--------------------------------------------------------------------------
    
   temp.SIM_DNAH11_integratedintensity=SIM_green_intensity_sum;
   temp.SIM_tubulin_integratedintensity=SIM_red_intensity_sum;
   temp.SIM_DNAH11_cilia_integratedintensity=SIM_green_integrated_intensity_cilia; 
   temp.SIM_colocalization_RedOverlapArea=SIM_OverlapAreaDividedByRed;
   temp.SIM_colocalization_RedOverlapIntIntensityRatio=SIM_RedOverlapIntensityRatio;
   temp.SIM_colocalization_GreenOverlapIntIntensityRatio=SIM_GreenOverlapIntensityRatio;
   
   temp.Decon_DNAH11_integratedintensity=Decon_green_intensity_sum;
   temp.Decon_tubulin_integratedintensity=Decon_red_intensity_sum;
   temp.Decon_DNAH11_cilia_integratedintensity=Decon_green_integrated_intensity_cilia; 
   temp.Decon_colocalization_RedOverlapArea=Decon_OverlapAreaDividedByRed;
   temp.Decon_colocalization_RedOverlapIntIntensityRatio=Decon_RedOverlapIntensityRatio;
   temp.Decon_colocalization_GreenOverlapIntIntensityRatio=Decon_GreenOverlapIntensityRatio;
   
   temp.Widef_DNAH11_integratedintensity=Widef_green_intensity_sum;
   temp.Widef_tubulin_integratedintensity=Widef_red_intensity_sum;
   temp.Widef_DNAH11_cilia_integratedintensity=Widef_green_integrated_intensity_cilia; 
   temp.Widef_colocalization_RedOverlapArea=Widef_OverlapAreaDividedByRed;
   temp.Widef_colocalization_RedOverlapIntIntensityRatio=Widef_RedOverlapIntensityRatio;
   temp.Widef_colocalization_GreenOverlapIntIntensityRatio=Widef_GreenOverlapIntensityRatio;
   
  
   t=strfind(files_rawdata(i).name, 'WT');
   if ~isempty(t)
   temp.wt=1;
   else
   temp.wt=0;
   end
   
   
   temp2_SIM=[double(cell_volume_SIM),double(temp.SIM_DNAH11_integratedintensity),...
   double(temp.SIM_tubulin_integratedintensity),...
   double(temp.SIM_DNAH11_cilia_integratedintensity),...
   double(temp.SIM_colocalization_RedOverlapArea),...
   double(temp.SIM_colocalization_RedOverlapIntIntensityRatio),...
   double(temp.SIM_colocalization_GreenOverlapIntIntensityRatio),double(temp.wt),double(i)];
   

   all_SIM=[all_SIM;temp2_SIM];
   
   temp2_deconv=[double(cell_volume_deconv),double(temp.Decon_DNAH11_integratedintensity),...
   double(temp.Decon_tubulin_integratedintensity),...
   double(temp.Decon_DNAH11_cilia_integratedintensity),...
   double(temp.Decon_colocalization_RedOverlapArea),...
   double(temp.Decon_colocalization_RedOverlapIntIntensityRatio),...
   double(temp.Decon_colocalization_GreenOverlapIntIntensityRatio),double(temp.wt),double(i)];
   
   all_deconv=[all_deconv;temp2_deconv];
   
   
   temp2_widef=[double(cell_volume_widef),double(temp.Widef_DNAH11_integratedintensity),...
   double(temp.Widef_tubulin_integratedintensity),...
   double(temp.Widef_DNAH11_cilia_integratedintensity),...
   double(temp.Widef_colocalization_RedOverlapArea),...
   double(temp.Widef_colocalization_RedOverlapIntIntensityRatio),...
   double(temp.Widef_colocalization_GreenOverlapIntIntensityRatio),double(temp.wt),double(i)];
   

   all_widef=[all_widef;temp2_widef];
     
   display('finished')
   clear data  
end
  display('finished')
  
    
    






