%% focal shift and spherical aberration correction
% focal shift
% (1-0.28)*d+(d>1500?0.05*(d-1500):0) from Bo Hunag, Insight 3
% input d
% d is the distance to the coverslip
if d >1500
   d_focusshiftcorrected=(1-0.28)*d+(d-1500)*0.05;
else
   d_focusshiftcorrected=(1-0.28)*d; 
end

% spherical aberration
% z*0.72*(z<0?(d<1600?0.9:(d<2300?0.95:1)):(1+0.7*d/1000)) from Bo
% Huang,Insight 3

if z<0
    switch d
        case d<1600
        z_sphericalabberationcorrected=z*0.72*0.9;
        case d>=1600&d<2300
        z_sphericalabberationcorrected=z*0.72*0.95;
        case d>=2300
        z_sphericalabberationcorrected=z*0.72*1;
    end 
else
        z_sphericalabberationcorrected=z*0.72*(1+0.7*d/1000); 
end