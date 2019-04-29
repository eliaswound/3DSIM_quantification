function fMenuStatistics(func,varargin)
switch func
    case 'MolToFil'
        MolToFil(varargin{1});     
    case 'MSD'
        MSD(varargin{1});
end

function MolToFil(hMainGui)
global Molecule;
global Filament;
set(hMainGui.fig,'pointer','watch');
workbar(0/(length(PathStats)),'Interpolating Filaments...','Progress',-1);
for i = 1:length(Filament)
    for j = 1:length(Filament(i).data)
        X=[Filament(i).data{j}.x];
        Y=[Filament(i).data{j}.y];
        P=1:length(X);
        pi=1:0.01:length(X);
        xi{i,j}=interp1(P,X,pi);
        yi{i,j}=interp1(P,Y,pi);
    end
    h = findobj('Tag','timebar');
    if isempty(h)
        return
    end
    workbar(i/(length(Filament)),'Interpolating Filaments...','Progress',-1);     
end
workbar(0/(length(PathStats)),'Calculating Molecules on Filament...','Progress',-1);
k = find([Molecule.Selected]==1);
for i=1:length(k)
    if size(xi,1)>1
        for j=1:length(Filament)
            [Dis,Side]=FilamentPath(Molecule(k(i)).Results,xi{j},yi{j},0);
            s(j)=mean(abs(Side));
        end
        [m,k] = min(s);
        [Dis,Side]=FilamentPath(Molecule(k(i)).Results,xi{k,:},yi{k,1},1);
    else
        [Dis,Side]=FilamentPath(Molecule(k(i)).Results,xi{1,1},yi{1,1},1);        
    end
    Molecule(k(i)).Path(:,1)=PathX;
    Molecule(k(i)).Path(:,2)=PathY;
    Molecule(k(i)).NewResults(:,1:4)=Molecule(k(i)).Results(:,1:4);
    Molecule(k(i)).NewResults(:,5)=Dis;
    Molecule(k(i)).NewResults(:,6)=Side;    
    Molecule(k(i)).NewResults(:,7)=Molecule(k(i)).Results(:,7);
    h = findobj('Tag','timebar');
    if isempty(h)
        return
    end
    workbar(i/(length(k)),'Calculating Molecules on Filament...','Progress',-1);     
end
set(hMainGui.fig,'pointer','arrow');
    
function [Dis,Side]=FilamentPath(Results,xi,yi,GetDis)
Dis=[];
for i=1:size(Results,1)
    [m,k]=min(sqrt( (Results(i,3)-xi).^2+ (Results(i,4)-yi).^2));
    Side(i)=m*sum(sign(cross([xi(k(1))-xi(1) yi(k(1))-yi(1) 0],[Results(i,3)-xi(k(1)) Results(i,4)-yi(k(1)) 0]))); %#ok<AGROW>
    if Side==0
        Side=m;
    end
end
if GetDis==1
    Dis=DisStart-DisStart(1);    
end

function [sd,tau] = CalcSD(Results,sd,tau,Mode)
%get frame numbers, time, X/Y position
F=Results(:,1);
T=Results(:,2);
X=Results(:,3);
Y=Results(:,4);    
if strcmp(Mode,'1D')
    %project path on linear function
    [param1,resnorm1]=PathFitLinear(X,Y); %#ok<NASGU>
    [PathX,PathY,Dis,Side]=LinearPath(X,Y,param1); %#ok<NASGU>
end
%calculate square displacment and time difference with interpolated data
min_frame=min(F);
max_frame=max(F);
for k=1:fix(log2(max_frame-min_frame))
    if length(sd)<k
        %create cell for sd and tau if not existing
        sd{k}=[];
        tau{k}=[];
    end
    n=1;
    while F(n)+2^(k-1)<max_frame
        %check if datapoint was tracked 
        num_frame = find(F(n)+2^(k-1) == F, 1);
        if ~isempty(num_frame)
           %calculate square displacment
            if strcmp(Mode,'1D')
                sd{k}=[sd{k} ((Dis(num_frame)-Dis(n))/1000)^2];
            else
                sd{k}=[sd{k} ((X(num_frame)-X(n))/1000)^2 + ((Y(num_frame)-Y(n))/1000)^2];
            end
            %calculate time difference
            tau{k}=[tau{k} T(num_frame)-T(n)];                
            n=num_frame;
        else
            n=n+1;
        end
    end
end

function [sd,tau] = CalcSD_old(Results,sd,tau,Mode)
%get frame numbers, time, X/Y position
F=Results(:,1);
T=Results(:,2);
X=Results(:,3);
Y=Results(:,4);    
%linear interpolation for missing frames
fi=min(F):max(F);
ti=interp1(F,T,fi);
if strcmp(Mode,'1D')
    %project path on linear function
    [param1,resnorm1]=PathFitLinear(X,Y); %#ok<NASGU>
    [PathX,PathY,Dis,Side]=LinearPath(X,Y,param1); %#ok<NASGU>
    xi=interp1(F,Dis,fi);
else
    %use X/Y for 2D displacement
    xi=interp1(F,X,fi);
    yi=interp1(F,Y,fi);        
end
%calculate square displacment and time difference with interpolated data
for k=1:fix(log2(length(fi)))
    if length(sd)<k
        %create cell for sd and tau if not existing
        sd{k}=[];
        tau{k}=[];
    end
    for n=1:2^(k-1):length(xi)-2^(k-1)
        %calculate square displacment
        if strcmp(Mode,'1D')
            sd{k}=[sd{k} ((xi(n+2^(k-1))-xi(n))/1000)^2];
        else
            sd{k}=[sd{k} ((xi(n+2^(k-1))-xi(n))/1000)^2 + ((yi(n+2^(k-1))-yi(n))/1000)^2];
        end
        %calculate time difference
        tau{k}=[tau{k} ti(n+2^(k-1))-ti(n)];                
    end
end

function MSD(hMainGui)
global Molecule
global Filament
%check whether to use 1D or 2D mean square displacement
if isempty(Molecule) && isempty(Filament)
    return;
end
Selected = [ [Molecule.Selected]; [Filament.Selected]];
if max(Selected)==0
    errordlg('No Track selected!','FIESTA Error','modal');
    return;
end
Mode = questdlg({'Do you want to calculate the','mean square displacement for all','selected tracks in one dimension or two?'},'FIESTA Mean Square Displacement','1D','2D','Cancel','1D');
if ~strcmp(Mode,'Cancel')
    %define variable for square displacment and time difference
    sd=[];
    tau=[];
    if ~isempty(Molecule)
        %for every selected molecule
        for n = find([Molecule.Selected]==1)
            %calculate square displacement
            [sd,tau] = CalcSD(Molecule(n).Results,sd,tau,Mode);
        end
    end
    if ~isempty(Filament)
        %for every selected molecule
        for n = find([Filament.Selected]==1)
            %calculate square displacement
            [sd,tau] = CalcSD(Filament(n).Results,sd,tau,Mode);
        end
    end
    for m=1:length(sd)
        TimeVsMSD(m,1)=mean(tau{m});
        TimeVsMSD(m,2)=mean(sd{m});
        TimeVsMSD(m,3)=std(sd{m})/sqrt(length(sd{m}));
        TimeVsMSD(m,4)=length(sd{m});
    end
    [FileName, PathName, FilterIndex] = uiputfile({'*.mat','MAT-file (*.mat)';'*.txt','TXT-File (*.txt)'},'Save FIESTA Mean Square Displacement',fShared('GetSaveDir'));
    file = [PathName FileName];
    if FilterIndex==1
        fShared('SetSaveDir',PathName);
        if isempty(findstr('.mat',file))
            file = [file '.mat'];
        end
        save(file,'TimeVsMSD');
    elseif FilterIndex==2
        fShared('SetSaveDir',PathName);
        if isempty(findstr('.txt',file))
            file = [file '.txt'];
        end
        f = fopen(file,'w');
        fprintf(f,'Time[s]\tMSD[µm²]\tError(mean)\tN\n');
        for j=1:size(TimeVsMSD,1)
            fprintf(f,'%f\t%f\t%f\t%f\n',TimeVsMSD(j,1),TimeVsMSD(j,2),TimeVsMSD(j,3),TimeVsMSD(j,4));
        end
        fclose(f);
    end
end

function [param,resnorm]=PathFitLinear(X,Y)
param0(1)=X(1)+(X(length(X))-X(1))/2;
param0(2)=Y(1)+(Y(length(Y))-Y(1))/2;
param0(3)=atan( (X(length(X))-X(1))/(Y(length(Y))-Y(1)));
options = optimset('Display','off','MaxFunEvals',400,'MaxIter',300,'TolFun',1e-3,'TolX',1e-3,'LargeScale','on');
try
    [param,resnorm,residual,exitflag,output]= lsqnonlin(@LinearModel,param0,[],[],options,X,Y); %#ok<NASGU>
catch
    param=param0;
    resnorm=1e100;
end

function [PathX,PathY,Dis,Side]=LinearPath(X,Y,param)
Proj=(X-param(1))*sin(param(3)) + (Y-param(2))*cos(param(3));
Dis=Proj-Proj(1); %#ok<AGROW>
v=[X-(sin(param(3))*Proj+param(1)) Y-(cos(param(3))*Proj+param(2)) zeros(length(Proj),1)];
u=[(sin(param(3))*Proj+param(1))-(sin(param(3))*(min(Proj)-1)+param(1)) (cos(param(3))*Proj+param(2))-(cos(param(3))*(min(Proj)-1)+param(2)) zeros(length(Proj),1)];
Side=sqrt( v(:,1).^2 + v(:,2).^2 ).*sum(sign(cross(v,u)),2);
Side(isnan(Side))=0;
if Dis(1)>mean(Dis)
    Dis=Dis*-1;
    Side=Side*-1;
end
Dis=Dis-Dis(1);
PathX=(sin(param(3))*sort(Proj)+param(1));
PathY=(cos(param(3))*sort(Proj)+param(2));