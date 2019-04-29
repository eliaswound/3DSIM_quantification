function fMenuContext(func,varargin)
switch func
    case 'DeleteRegion'
        DeleteRegion(varargin{1});        
    case 'DeleteMeasure'
        DeleteMeasure(varargin{1});          
    case 'OpenTrack'
        OpenTrack(varargin{1});  
    case 'MarkTrack'
        MarkTrack;        
    case 'SelectTrack'
        SelectTrack(varargin{1});     
    case 'SelectList'
        SelectList(varargin{1});             
    case 'VisibleList'
        VisibleList(varargin{1});                     
    case 'SetCurrentTrack'
        SetCurrentTrack(varargin{1},varargin{2});                     
    case 'AddTo'
        AddTo(varargin{1});
    case 'DeleteObject'
        DeleteObject(varargin{1});        
    case 'DeleteQueue'
        DeleteQueue(varargin{1});           
    case 'DeleteOffset'
        DeleteOffset(varargin{1});           
    case 'DeleteOffsetMatch'
        DeleteOffsetMatch(varargin{1});             
end     

function SelectList(hMainGui)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
Mode=get(gcbo,'UserData');
for n=1:length(Molecule)
    if Molecule(n).Selected==0||Molecule(n).Selected==1
        v=[];
        if strcmp(Mode,'All')||strcmp(Mode,'Molecule')
            v=1;
        elseif strcmp(Mode,'Filament')
            v=0;
        end
        Molecule=fShared('SelectOne',Molecule,KymoTrackMol,n,v);
    end
end
for n=1:length(Filament)
    if Filament(n).Selected==0||Filament(n).Selected==1
        v=[];
        if strcmp(Mode,'All')||strcmp(Mode,'Filament')
            v=1;
        elseif strcmp(Mode,'Molecule')
            v=0;
        end
        Filament=fShared('SelectOne',Filament,KymoTrackFil,n,v);
    end
end
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
fShow('Image');

function VisibleList(hMainGui)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
Mode=get(gcbo,'UserData');
for n=1:length(Molecule)
    if Molecule(n).Selected>-1
        if strcmp(Mode,'All')
            Molecule=fShared('VisibleOne',Molecule,KymoTrackMol,hMainGui.RightPanel.pData.MolList,n,1,hMainGui.RightPanel.pData.sMolList);
        else
            if Molecule(n).Selected==1
                Molecule=fShared('VisibleOne',Molecule,KymoTrackMol,hMainGui.RightPanel.pData.MolList,n,[],hMainGui.RightPanel.pData.sMolList);            
            end
        end
    end
end
for n=1:length(Filament)
    if Filament(n).Selected>-1
        if strcmp(Mode,'All')
            Filament=fShared('VisibleOne',Filament,KymoTrackFil,hMainGui.RightPanel.pData.FilList,n,1,hMainGui.RightPanel.pData.sFilList);
        else
            if Filament(n).Selected==1
                Filament=fShared('VisibleOne',Filament,KymoTrackFil,hMainGui.RightPanel.pData.FilList,n,[],hMainGui.RightPanel.pData.sFilList);
            end
        end
    end
end
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
fShow('Image');

function DeleteQueue(hMainGui)
global Queue;
Mode=get(gcbo,'UserData');
if ~isempty(Queue)
    if strcmp(Mode,'All')==1
        Queue=[];
    else
        Selected=[Queue.Selected];
        Queue(Selected==1)=[];
    end
    fRightPanel('UpdateQueue',hMainGui.RightPanel.pQueue.LocList,Queue,hMainGui.RightPanel.pQueue.sLocList,'Local');
end

function [Object,OtherObject]=CurrentTrack(Object,OtherObject,n)
Selected=[Object.Selected];
k=find(Selected==2,1);
if ~isempty(k)
    Object(k).Selected=0;
    if k~=n
        Object(n).Selected=2; 
        set(Object(n).pTrackSelectB,'Visible','off');
        set(Object(n).pTrackSelectW,'Visible','off');                
    end
else
    Object(n).Selected=2;
    set(Object(n).pTrackSelectB,'Visible','off');
    set(Object(n).pTrackSelectW,'Visible','off');                
end
Selected=[OtherObject.Selected];
k=find(Selected==2,1);
if ~isempty(k)
    OtherObject(k).Selected=0;
end

function SetCurrentTrack(hMainGui,Mode)
global Molecule;
global Filament;
n=[];
if strcmp(Mode,'Set')
    TrackInfo=get(findobj('Tag','TrackInfo'),'UserData');
    if isempty(TrackInfo)
        TrackInfo=get(gco,'UserData');
        set(gco,'UserData',[]);
    end
    if ~isempty(TrackInfo)
        n=TrackInfo.List(1);
        Mode=TrackInfo.Mode;
    end
else
    n=find([Molecule.Selected]==2,1);
    Mode='Molecule';
    if isempty(n)
        n=find([Filament.Selected]==2,1);        
        Mode='Filament';
    end
end
if ~isempty(n)
    if strcmp(Mode,'Molecule')
        [Molecule,Filament]=CurrentTrack(Molecule,Filament,n);
    else
        [Filament,Molecule]=CurrentTrack(Filament,Molecule,n);
    end
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
end

function OpenTrack(hMainGui)
TrackInfo=get(findobj('Tag','TrackInfo'),'UserData');
if ~isempty(TrackInfo)
    n=TrackInfo.List(1);
    fMainGui('OpenObject',hMainGui,TrackInfo.Mode,n)
end

function Object=SetColor(Object,KymoObject,color,n)
Object(n).Color=color;
set(Object(n).pTrack,'Color',color);
k=find([KymoObject.Index]==n);
if ~isempty(k)
    set(KymoObject(k).plot,'Color',color);            
end

function MarkTrack
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
TrackInfo=get(findobj('Tag','TrackInfo'),'UserData');
if ~isempty(TrackInfo)
    n=TrackInfo.List(1);
    color=get(gcbo,'UserData');
    if strcmp(TrackInfo.Mode,'Molecule')
        Molecule=SetColor(Molecule,KymoTrackMol,color,n);
    else
        Filament=SetColor(Filament,KymoTrackFil,color,n);
    end
end
fShow('Image');

function SelectTrack(hMainGui)
TrackInfo=get(findobj('Tag','TrackInfo'),'UserData');
if ~isempty(TrackInfo)
    n=TrackInfo.List(1);
    fMainGui('SelectObject',hMainGui,TrackInfo.Mode,n,get(gcbo,'UserData'));
end

function DeleteRegion(hMainGui)
if strcmp(get(gcbo,'UserData'),'one')==1
    sRegion=get(gco,'UserData');
    nRegion=sRegion;
else
    sRegion=1;
    nRegion=length(hMainGui.Region);
end
for i=nRegion:-1:sRegion
    hMainGui.Region(i)=[];
    try
        delete(hMainGui.Plots.Region(i));
        hMainGui.Plots.Region(i)=[];
    catch
    end
end
for i=sRegion:length(hMainGui.Region)
    hMainGui.Region(i).color=hMainGui.RegionColor(mod(i-1,24)+1,:);
    set(hMainGui.Plots.Region(i),'Color',hMainGui.Region(i).color,'Linestyle','--','UserData',i,'UIContextMenu',hMainGui.Menu.ctRegion);
end
setappdata(0,'hMainGui',hMainGui);
fLeftPanel('RegUpdateList',hMainGui);


function DeleteMeasure(hMainGui)
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
if strcmp(get(gcbo,'UserData'),'one')==1
    sMeasure=get(gco,'UserData');
    if sMeasure>0
        nMeasure=sMeasure;
        set(hMainGui.RightPanel.pTools.lMeasureTable,'Value',sMeasure,'UserData',sMeasure-1)
    else
        nMeasure=length(hMainGui.Measure);
        sMeasure=length(hMainGui.Measure)+1;
    end
else
    sMeasure=1;
    nMeasure=length(hMainGui.Measure);
end
for i=nMeasure:-1:sMeasure
    hMainGui.Measure(i)=[];
    delete(hMainGui.Plots.Measure(i));
    hMainGui.Plots.Measure(i)=[];
end
for i=sMeasure:length(hMainGui.Measure)
    delete(hMainGui.Plots.Measure(i));
    hold on
    color=mod(i-1,8)+1;
    hMainGui.Plots.Measure(i)=plot(hMainGui.Measure(i).X,hMainGui.Measure(i).Y,'Color',get(hMainGui.LeftPanel.pRegions.cRegion(color),...
                                 'ForegroundColor'),'LineStyle',':','UserData',i,'UIContextMenu',hMainGui.Menu.ctMeasure);
    hold off
end
setappdata(0,'hMainGui',hMainGui);
fRightPanel('UpdateMeasure',hMainGui);

function DeleteObject(hMainGui)
global Objects;
Mode=get(gcbo,'UserData');
n=get(gco,'UserData');
if strcmp(Mode,'Molecule')
    k=find(double([Objects{hMainGui.Values.FrameIdx}.length])==0);
else
    k=find(double([Objects{hMainGui.Values.FrameIdx}.length])~=0);    
end
Objects{hMainGui.Values.FrameIdx}(k(n))=[];
fShow('Marker',hMainGui,hMainGui.Values.FrameIdx);  

function DeleteOffset(hMainGui)
OffsetMap = getappdata(hMainGui.fig,'OffsetMap');
n=get(gco,'UserData');
if isreal(n)
    if ~isempty(OffsetMap.Match)
        k = ismember(OffsetMap.Match(:,1:2),OffsetMap.RedXY(n,:));
        if max(k(:,1))==1
            OffsetMap.Match(k(:,1),:)=[];
        end
    end
    OffsetMap.RedXY(n,:)=[];
else
    n=imag(n);
    if ~isempty(OffsetMap.Match)
        k = ismember(OffsetMap.Match(:,3:4),OffsetMap.GreenXY(n,:));
        if max(k(:,1))==1
            OffsetMap.Match(k(:,1),:)=[];
        end
    end
    OffsetMap.GreenXY(n,:)=[];  
end
setappdata(hMainGui.fig,'OffsetMap',OffsetMap);
if strcmp(get(hMainGui.Menu.mShowOffsetMap,'Checked'),'on')
    fShow('OffsetMap',hMainGui);    
end
fShared('UpdateMenu',hMainGui);

function DeleteOffsetMatch(hMainGui)
OffsetMap = getappdata(hMainGui.fig,'OffsetMap');
n=get(gco,'UserData');
if ~isempty(OffsetMap.RedXY) && ~isempty(OffsetMap.GreenXY) && ~isempty(OffsetMap.Match)
    k = ismember(OffsetMap.RedXY,OffsetMap.Match(n,1:2));
    if max(k(:,1))==1
        OffsetMap.RedXY(k(:,1),:)=[];
    end
    k = ismember(OffsetMap.GreenXY,OffsetMap.Match(n,3:4));
    if max(k(:,1))==1
        OffsetMap.GreenXY(k(:,1),:)=[];
    end
    OffsetMap.Match(n,:)=[];
end
setappdata(hMainGui.fig,'OffsetMap',OffsetMap);
if strcmp(get(hMainGui.Menu.mShowOffsetMap,'Checked'),'on')
    fShow('OffsetMap',hMainGui);    
end
fShared('UpdateMenu',hMainGui);

function AddTo(hMainGui)
global Config;
global Objects;
global Molecule;
global Filament;
Mode=get(gcbo,'UserData');
n=get(gco,'UserData');
if strcmp(Mode{1},'Molecule')
    Object=Molecule;
    k=find(double([Objects{hMainGui.Values.FrameIdx}.length])==0);
else
    Object=Filament;
    k=find(double([Objects{hMainGui.Values.FrameIdx}.length])~=0);    
end
nObj=length(Object);
kObj=[];
kData=[];
if strcmp(Mode{2},'New')==1
    Object(nObj+1).Selected=0;
    Object(nObj+1).Visible=1;
    Object(nObj+1).Name=sprintf('%s %d',Mode{1},nObj+1); 
    Object(nObj+1).Directory=Config.Directory;
    Object(nObj+1).File=Config.StackName;
    Object(nObj+1).Color=[0 0 1];
    Object(nObj+1).Drift=0;
    kObj=nObj+1;
    kData=1;
else
    if nObj==0
         errordlg(sprintf('No %s present',Mode{1}),'FIESTA Error','modal');
    else
        idx=find([Object.Selected]==2,1);
        if isempty(idx)
            errordlg(sprintf('No Current %s Track',Mode{1}),'FIESTA Error','modal');
        else
            if ~isempty(find(Object(idx).Results(:,1)==hMainGui.Values.FrameIdx, 1))
                button = questdlg('Frame already exists in current track - Overwrite ?','Warning','OK','Cancel','OK');
                if strcmp(button,'OK')
                    kData=find(Object(idx).Results(:,1)==hMainGui.Values.FrameIdx,1);
                else 
                    return;
                end
            end
            kObj=idx;
        end
    end
end
if ~isempty(kObj)
    if strcmp(Mode{1},'Molecule')
        Molecule=AddDataMol(Object,Objects,kObj,kData,hMainGui.Values.FrameIdx,k(n));
        nData=size(Molecule(kObj).Results,1);
        for i=1:nData
            Molecule(kObj).Results(i,5)=norm([Molecule(kObj).Results(i,3)-Molecule(kObj).Results(1,3) Molecule(kObj).Results(i,4)-Molecule(kObj).Results(1,4)]);
        end
    else
        Filament=AddDataFil(Object,Objects,kObj,kData,hMainGui.Values.FrameIdx,k(n));
        nData=size(Filament(kObj).ResultsCenter,1);
        for i=1:nData
            Filament(kObj).ResultsCenter(i,5)=norm([Filament(kObj).ResultsCenter(i,3)-Filament(kObj).ResultsCenter(1,3) Filament(kObj).ResultsCenter(i,4)-Filament(kObj).ResultsCenter(1,4)]);
            Filament(kObj).ResultsStart(i,5)=norm([Filament(kObj).ResultsStart(i,3)-Filament(kObj).ResultsStart(1,3) Filament(kObj).ResultsStart(i,4)-Filament(kObj).ResultsStart(1,4)]);
            Filament(kObj).ResultsEnd(i,5)=norm([Filament(kObj).ResultsEnd(i,3)-Filament(kObj).ResultsEnd(1,3) Filament(kObj).ResultsEnd(i,4)-Filament(kObj).ResultsEnd(1,4)]);
        end
        if strcmp(Config.RefPoint,'center')==1
            Filament(kObj).Results=Filament(kObj).ResultsCenter;
        elseif strcmp(Config.RefPoint,'start')==1
            Filament(kObj).Results=Filament(kObj).ResultsStart;
        else
            Filament(kObj).Results=Filament(kObj).ResultsEnd;
        end
    end
end
fShow('Image');  
fShow('Tracks');
if strcmp(Mode{1},'Molecule')&&strcmp(Mode{2},'New')
    [Molecule,Filament]=CurrentTrack(Molecule,Filament,kObj);
elseif strcmp(Mode{1},'Filament')&&strcmp(Mode{2},'New')
    [Filament,Molecule]=CurrentTrack(Filament,Molecule,kObj);
end
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fShared('UpdateMenu',hMainGui);

function Molecule=AddDataMol(Molecule,Objects,nMol,nData,idx,k)
if ~isempty(Molecule(nMol).Results) && isempty(nData)
    f=find(idx<Molecule(nMol).Results(:,1),1,'first');
    if ~isempty(f)
        n=size(Molecule(nMol).Results,1);
        nData=f;
        Molecule(nMol).Results(f+1:n+1,:)=Molecule(nMol).Results(f:n,:);
        Molecule(nMol).data(f+1:n+1)=Molecule(nMol).data(f:n);
    else
        nData=size(Molecule(nMol).Results,1)+1;
    end
end
Molecule(nMol).Results(nData,1)=idx;
Molecule(nMol).Results(nData,2)=Objects{idx}(k).time;
Molecule(nMol).Results(nData,3)=Objects{idx}(k).center_x;
Molecule(nMol).Results(nData,4)=Objects{idx}(k).center_y;
Molecule(nMol).Results(nData,5)=0;
if length(double(Objects{idx}(k).width))==1
    Molecule(nMol).Results(nData,6)=double(Objects{idx}(k).width);
else
    Molecule(nMol).Results(nData,6)=mean(double(Objects{idx}(k).width(1:2)));
end
Molecule(nMol).Results(nData,7)=Objects{idx}(k).height(1);
try
    Molecule(nMol).Results(nData,8)=sqrt((Objects{idx}(k).center_x.error)^2+...
                                   (Objects{idx}(k).center_y.error)^2);
catch
    Molecule(i).Results(j,8)=0;
end                               
Molecule(nMol).data{nData}=Objects{idx}(k).data;

function Filament=AddDataFil(Filament,Objects,nFil,nData,idx,k)
if ~isempty(Filament(nFil).Results) && isempty(nData)
    f=find(idx<Filament(nFil).Results(:,1),1);
    if ~isempty(f)
        n=size(Filament(nFil).Results,1);
        nData=f;
        Filament(nFil).ResultsStart(f+1:n+1,:)=Filament(nFil).ResultsStart(f:n,:);
        Filament(nFil).ResultsCenter(f+1:n+1,:)=Filament(nFil).ResultsCenter(f:n,:);
        Filament(nFil).ResultsEnd(f+1:n+1,:)=Filament(nFil).ResultsEnd(f:n,:);
        Filament(nFil).Orientation(f+1:n+1)=Filament(nFil).Orientation(f:n);        
        Filament(nFil).data(f+1:n+1)=Filament(nFil).data(f:n);        
    else
        nData = size(Filament(nFil).Results,1) + 1;
    end
end
Filament(nFil).ResultsCenter(nData,1)=idx;
Filament(nFil).ResultsCenter(nData,2)=Objects{idx}(k).time;
Filament(nFil).ResultsCenter(nData,3)=Objects{idx}(k).center_x;
Filament(nFil).ResultsCenter(nData,4)=Objects{idx}(k).center_y;
Filament(nFil).ResultsCenter(nData,5)=0;
Filament(nFil).ResultsCenter(nData,6)=Objects{idx}(k).length;
Filament(nFil).ResultsCenter(nData,7)=Objects{idx}(k).height;
Filament(nFil).ResultsCenter(nData,8)=1;
Filament(nFil).data{nData}=Objects{idx}(k).data;
Filament(nFil).Orientation(nData)=mod(double(Objects{idx}(k).orientation),2*pi);
if nData>1
    if abs(Filament(nFil).Orientation(nData)-Filament(nFil).Orientation(nData-1))>pi/2
       Filament(nFil).data{nData}=Filament(nFil).data{nData}(length(Filament(nFil).data{nData}):-1:1);
       Filament(nFil).Orientation(nData)=mod(Filament(nFil).Orientation(nData)+pi,2*pi);
    end
elseif nData==1&&length(Filament(nFil).Orientation)>1
    if abs(Filament(nFil).Orientation(nData)-Filament(nFil).Orientation(nData+1))>pi/2
       Filament(nFil).data{nData}=Filament(nFil).data{nData}(length(Filament(nFil).data{nData}):-1:1);
       Filament(nFil).Orientation(nData)=mod(Filament(nFil).Orientation(nData)+pi,2*pi);
    end
end

Filament(nFil).ResultsStart(nData,1)=idx;
Filament(nFil).ResultsStart(nData,2)=Objects{idx}(k).time;
Filament(nFil).ResultsStart(nData,3)=Filament(nFil).data{nData}(1).x;
Filament(nFil).ResultsStart(nData,4)=Filament(nFil).data{nData}(1).y;
Filament(nFil).ResultsStart(nData,5)=0;
Filament(nFil).ResultsStart(nData,6)=Objects{idx}(k).length;
Filament(nFil).ResultsStart(nData,7)=Filament(nFil).data{nData}(1).h;
Filament(nFil).ResultsStart(nData,8)=1;
  
END=length(Filament(nFil).data{nData});
Filament(nFil).ResultsEnd(nData,1)=idx;
Filament(nFil).ResultsEnd(nData,2)=Objects{idx}(k).time;
Filament(nFil).ResultsEnd(nData,3)=Filament(nFil).data{nData}(END).x;
Filament(nFil).ResultsEnd(nData,4)=Filament(nFil).data{nData}(END).y;
Filament(nFil).ResultsEnd(nData,5)=0;
Filament(nFil).ResultsEnd(nData,6)=Objects{idx}(k).length;
Filament(nFil).ResultsEnd(nData,7)=Filament(nFil).data{nData}(END).h;
Filament(nFil).ResultsEnd(nData,8)=1;
