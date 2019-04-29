function writelist10NOTRANS(aligniter,niter,file,zoom)

addpath D:\Xiaoyu\MatlabAnalysis\resource
% import 2c file
inname = [file,'.txt'];
rawlist = importdata(inname);
rawdata = rawlist.data;
rawdatafix = rawlist.data;
size0 = size(rawdata);
n0 = size0(1);
nframe = rawdata(n0,13);

% calculate rotation ans translation info
for iter=1:niter

    x2 = [];
    y2 = [];

    for i=1:nframe
        i     %display
        newdata0 = rawdatafix(rawdatafix(:,13)==i,:);
        x0 = newdata0(:,4);
        y0 = newdata0(:,5);
        
        da0 = sum(aligniter(i,1,1:iter))/180*pi;
        dx0 = sum(aligniter(i,3,1:iter))/zoom;
        dy0 = sum(aligniter(i,2,1:iter))/zoom;

        %transform                   

        x1 = x0*cos(-da0) - y0*sin(-da0)+ dx0; 
        y1 = x0*sin(-da0) + y0*cos(-da0)+ dy0;  

        x2 = [x2;x1];
        y2 = [y2;y1];

    end

    rawdata(:,4)=x2;
    rawdata(:,5)=y2;


end

    %-----------------------write----------------------
    filename = [file,'_aligned_notrans','.txt'];   
    f = fopen(filename,'wt');

    %Write the header:

        cas = ['Cas',num2str(n0)];
        header = {cas 'X' 'Y' 'Xc' 'Yc' 'Height' 'Area' 'Width' 'Phi' 'Ax' 'BG' 'I' 'Frame' 'Length' 'Link' 'Valid' 'Z' 'Zc'};
        fprintf(f,'%s\t',header{1:end-1});
        fprintf(f,'%s\n',header{end});

    %Write the data:
        for m = 1:n0
            fprintf(f,'%g\t',rawdata(m,1:end-1));
            fprintf(f,'%g\n',rawdata(m,end));
        end

    fclose(f);
   


