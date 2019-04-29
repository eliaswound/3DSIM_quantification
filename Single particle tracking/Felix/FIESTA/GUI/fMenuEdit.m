function fMenuEdit(func,varargin)
switch func
    case 'Find'
        Find(varargin{1});
    case 'FindNext'
        FindNext(varargin{1});     
    case 'FindMoving'
        FindMoving(varargin{1});
    case 'Normalize'
        Normalize(varargin{1});        
    case 'Filter'
        Filter;   
    case 'ManualTracking'
        ManualTracking(varargin{1});
end

function Find(hMainGui)
global Molecule;
global Filament;
hMainGui.Search.String=char(inputdlg({'Find what:'},'Find',1,{''}));
hMainGui.Search.Mol=[];
hMainGui.Search.Fil=[];
nMol=length(Molecule);
nFil=length(Filament);
nSearchMol=1;
for i=1:nMol
    k=strfind(Molecule(i).Name,hMainGui.Search.String);
    if k>0
        hMainGui.Search.Mol(nSearchMol)=i;
        nSearchMol=nSearchMol+1;
    end
end
nSearchFil=1;
for i=1:nFil
    k=strfind(Filament(i).Name,hMainGui.Search.String);
    if k>0
        hMainGui.Search.Fil(nSearchFil)=i;
        nSearchFil=nSearchFil+1;
    end
end
hMainGui.Search.MolP=0;
hMainGui.Search.FilP=0;
if nSearchMol>1
    p=nMol-6-hMainGui.Search.Mol(1);
    if p<1
        p=1;
    end
    fMainGui('SelectObject',hMainGui,'Molecule',hMainGui.Search.Mol(1),'normal');
    getappdata(0,'hMainGui');
    set(hMainGui.RightPanel.pData.sMolList,'Value',p)
    fRightPanel('DataPanel',hMainGui);
    fRightPanel('DataMoleculesPanel',hMainGui);
    hMainGui.Search.MolP=1;
else
    if nSearchFil>1
        p=nFil-6-hMainGui.Search.Fil(1);
        if p<1
            p=1;
        end
        fMainGui('SelectObject',hMainGui,'Filament',hMainGui.Search.Fil(1),'normal');     
        getappdata(0,'hMainGui');        
        set(hMainGui.RightPanel.pData.sFilList,'Value',p)
        fRightPanel('DataPanel',hMainGui);
        fRightPanel('DataFilamentsPanel',hMainGui);
        hMainGui.Search.FilP=1;
    end
end
if nSearchMol+nSearchFil>3
    set(hMainGui.Menu.mFindNext,'Enable','on');
else    
    set(hMainGui.Menu.mFindNext,'Enable','off');
end
setappdata(0,'hMainGui',hMainGui);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);

function FindNext(hMainGui)
global Molecule;
global Filament;
nMol=length(Molecule);
nFil=length(Filament);
nSearchMol=length(hMainGui.Search.Mol);
nSearchFil=length(hMainGui.Search.Fil);
if nSearchMol>hMainGui.Search.MolP
    p=nMol-6-hMainGui.Search.Mol(hMainGui.Search.MolP+1);
    if p<1
        p=1;
    end
    fMainGui('SelectObject',hMainGui,'Molecule',hMainGui.Search.Mol(hMainGui.Search.MolP+1),'normal');
    getappdata(0,'hMainGui');
    set(hMainGui.RightPanel.pData.sMolList,'Value',p)
    fRightPanel('DataPanel',hMainGui);
    fRightPanel('DataMoleculesPanel',hMainGui);    
    hMainGui.Search.MolP=hMainGui.Search.MolP+1;
else
    if nSearchFil>hMainGui.Search.FilP
        p=nFil-6-hMainGui.Search.Fil(hMainGui.Search.FilP+1);
        if p<1
            p=1;
        end
        fMainGui('SelectObject',hMainGui,'Filament',hMainGui.Search.Fil(hMainGui.Search.FilP+1),'normal');     
        getappdata(0,'hMainGui');            
        set(hMainGui.RightPanel.pData.sFilList,'Value',p)
        fRightPanel('DataPanel',hMainGui);
        fRightPanel('DataFilamentsPanel',hMainGui);        
        hMainGui.Search.FilP=hMainGui.Search.FilP+1;
    end
end
if hMainGui.Search.MolP+hMainGui.Search.FilP==nSearchMol+nSearchFil
    set(hMainGui.Menu.mFindNext,'Enable','off');
end
setappdata(0,'hMainGui',hMainGui);
%fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
%fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);

function FindMoving(hMainGui)
global Molecule;
global KymoTrackMol;
global Filament;
mode=get(gcbo,'UserData');
if strcmp(mode,'moving') 
    Dis = str2double(inputdlg({'Enter minmum distance in nm:'},'Minimum, Distance',1,{'100'}));
else
    Dis = str2double(inputdlg({'Enter maxium distance in nm:'},'Maximum Distance',1,{'100'}));
end
nMol=length(Molecule);
nFil=length(Filament);
nDisMol=zeros(nMol,1);
for i=1:nMol
    nDataMol(i)=size(Molecule(i).Results,1);
    nDisMol(i)=norm([Molecule(i).Results(nDataMol(i),3)-Molecule(i).Results(1,3) Molecule(i).Results(nDataMol(i),4)-Molecule(i).Results(1,4)]);
end
nDisFil=zeros(nMol,1);
for i=1:nFil
    nDataFil(i)=size(Filament(i).Results,1);
    nDisFil(i)=norm([Filament(i).Results(nDataFil(i),3)-Filament(i).Results(1,3) Filament(i).Results(nDataFil(i),4)-Filament(i).Results(1,4)]);
end
for i=1:nMol
    if strcmp(mode,'moving')
        if nDisMol(i)>Dis&&nDataMol(i)>0.4*max(nDataMol)
            Molecule(i).Check=1;
        else
            Molecule(i).Check=0;
        end
    else
        if nDisMol(i)<Dis&&nDataMol(i)==max(nDataMol)
            Molecule=fShared('SelectOne',Molecule,KymoTrackMol,i,1);
        else
            Molecule=fShared('SelectOne',Molecule,KymoTrackMol,i,0);
        end
    end
end
for i=1:nFil
    if strcmp('mode','moving')
        if nDisFil(i)>Dis&&nDataFil(i)>0.4*max(nDataFil)
            Filament(i).Check=1;
        else
            Filament(i).Check=0;
        end
    else
        if nDisFil(i)<Dis&&nDataFil(i)>0.9*max(nDataFil)
            Filament(i).Check=1;
        else
            Filament(i).Check=0;
        end
    end
end            
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
setappdata(0,'hMainGui',hMainGui);
fShow('Image');

function Normalize(hMainGui)
global Stack;
button =  questdlg('Which reference should be used?','Normalize','min','mean','cancel','min'); 
maxStack=hMainGui.Values.PixMax;
minStack=min(hMainGui.Values.MeanStack);
if strcmp(button,'cancel')==0
    StartTime=clock;
    for i=1:length(Stack)
        I=double(Stack{i});
        if strcmp(button,'min')==1
            minNorm=min(min(I));
        elseif strcmp(button,'mean')==1
            minNorm=mean2(I);
        end
        maxNorm=max(max(I));
        I=I-minNorm;
        I=I/(maxNorm-minNorm);
        I=I+abs(min(min(I)));
        I=I*(maxStack-minStack)+minStack;
        Stack{i}=uint16(round(I));
        timeleft=etime(clock,StartTime)/(i)*(length(Stack)-i);
        s=sprintf('Normalizing Stack - Frame:  %d/%d',i,length(Stack));
        workbar(i/length(Stack),s,'Progress',timeleft) 
    end
end
fShow('Image');

function Filter
global Stack;
w =  round(str2double(inputdlg('Size of box:','Filter'))); 
lambda=1;
if get(gcbo,'UserData')>0
    B=(sum(exp(-((-w:w).^2/(4*lambda^2)))))^2;
end
StartTime=clock;
x=size(Stack{1},2);
y=size(Stack{1},1);
for n=1:length(Stack)
    I=double(Stack{n});
    Temp=zeros(2*w+1+y,2*w+1+x);
    Temp(w+1:w+y,w+1:w+x)=I;
    for i=1:w
        Temp(:,i)=Temp(:,1+w);
        Temp(:,w+i+x)=Temp(:,x+w);
    end
    for i=1:w
        Temp(i,:)=Temp(1+w,:);
        Temp(w+y+i,:)=Temp(y+w,:);     
    end
    t=get(gcbo,'UserData');
    A=zeros(2*w+1+y,2*w+1+x);
    for j=1:y
        for i=1:x
            if t==0
                A(j+w,i+w)=1/(2*w+1)^2*sum(sum(Temp(j:j+2*w,i:i+2*w)));
            else
                k=exp( -( (-w:w).^2/(2*lambda^2)));
                K0=(1/B)*(sum(exp(-((-w:w).^2/(4*lambda^2)))))^2-B/(2*w+1)^2;
                K=(1/K0)*((1/B)*k'*k-1/(2*w+1)^2);
                A(j+w,i+w)=1/(B)*sum(sum(Temp(j:j+2*w,i:i+2*w).*K));
            end
        end
    end
    T=A(w+1:w+y,w+1:w+x);
    T=T-min(min(T));
    I=round(I-T);
    Stack{n}=uint16(I-min(min(I)));
    timeleft=etime(clock,StartTime)/(n)*(length(Stack)-n);
    s=sprintf('Filtering Stack - Frame:  %d/%d',n,length(Stack));
    workbar(n/length(Stack),s,'Progress',timeleft) 
end
fShow('Image');

function ManualTracking(hMainGui)
global Stack;
global StackInfo;
global Config;
fManualTrack(Stack,StackInfo,Config,0,[]);