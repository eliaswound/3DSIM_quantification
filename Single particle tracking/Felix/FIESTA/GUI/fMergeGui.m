function fMergeGui(func,varargin)
switch func
    case 'Create'
        Create(varargin{1},varargin{2});
    case 'Update'
        Update(varargin{1});        
    case 'Draw'
        Draw(varargin{1});  
    case 'bToggleToolCursor'
        bToggleToolCursor(varargin{1});  
    case 'bToolPan'
        bToolPan(varargin{1});
    case 'bToolZoomIn'
        bToolZoomIn(varargin{1});
    case 'bToggleToolRegion'
        bToggleToolRegion(varargin{1});
    case 'bToggleToolRectRegion'
        bToggleToolRectRegion(varargin{1});
    case 'Add'
        Add(varargin{1});
    case 'Delete'
        Delete(varargin{1});
    case 'DelEntry'
        DelEntry(varargin{1});
    case 'OK'
        OK(varargin{1});
end

function Create(Mode,List)
global Molecule;
global Filament;
if strcmp(Mode,'Molecule')
    Objects=Molecule;
else
    Objects=Filament;
end

h=findobj('Tag','hMergeGui');
close(h)

hMergeGui.fig = figure('Units','normalized','DockControls','off','IntegerHandle','off','MenuBar','none','Name','Merge',...
                      'NumberTitle','off','Position',[0.05 0.05 0.65 0.9],'HandleVisibility','callback','Tag','hMergeGui',...
                      'Visible','on','Resize','off','Color',[0.9255 0.9137 0.8471],'WindowStyle','normal');                  
                  
hMergeGui=ToolBar(hMergeGui);                  

hMergeGui.aPlot = axes('Parent',hMergeGui.fig,'Units','normalized','Position',[0.45 0.55 0.5 0.425],'Tag','Plot');

hMergeGui.aTable = axes('Parent',hMergeGui.fig,'Units','normalized','Position',[0.05 0.06 0.9 0.44],'Tag','tblParams');

str=cell(length(List),1);
for i=1:length(List)
    str{i}=Objects(List(i)).Name;
end
hMergeGui.lMerge = uicontrol('Parent',hMergeGui.fig,'Units','normalized','BackgroundColor',[1 1 1],'Callback','fMergeGui(''Draw'',getappdata(0,''hMergeGui''));',...
                             'Position',[0.05 0.55 0.35 0.19],'String',str,'Style','listbox','Value',1,'Tag','lMerge');

str=cell(length(Objects),1);
for i=1:length(Objects)
    str{i}=Objects(i).Name;
end
hMergeGui.lAll = uicontrol('Parent',hMergeGui.fig,'Units','normalized','BackgroundColor',[1 1 1],...
                           'Position',[0.05 0.79 0.35 0.19],'String',str,'Style','listbox','Value',1,'Tag','lAll');                         

hMergeGui.bAdd = uicontrol('Parent',hMergeGui.fig,'Units','normalized','Callback','fMergeGui(''Add'',getappdata(0,''hMergeGui''));',...
                           'Position',[0.05 0.75 0.15 0.025],'String','Add','Tag','bAdd');

hMergeGui.bDelete = uicontrol('Parent',hMergeGui.fig,'Units','normalized','Callback','fMergeGui(''Delete'',getappdata(0,''hMergeGui''));',...
                              'Position',[0.25 0.75 0.15 0.025],'String','Delete','Tag','bDelete');
                          
hMergeGui.bDelEntry = uicontrol('Parent',hMergeGui.fig,'Units','normalized','Callback','fMergeGui(''DelEntry'',getappdata(0,''hMergeGui''));',...
                               'Position',[0.025 0.5 0.075 0.025],'String','Delete Entry','Tag','bDelEntry');

hMergeGui.bOK = uicontrol('Parent',hMergeGui.fig,'Units','normalized','Callback','fMergeGui(''OK'',getappdata(0,''hMergeGui''));',...
                          'Position',[0.6 0.025 0.15 0.025],'String','OK','Tag','bOK');

hMergeGui.bCancel = uicontrol('Parent',hMergeGui.fig,'Units','normalized','Callback','close(gcf);',...
                              'Position',[0.8 0.025 0.15 0.025],'String','Cancel','Tag','bCancel');
                          
hMergeGui.tWarning = uicontrol('Parent',hMergeGui.fig,'Units','normalized','FontSize',10,'FontWeight','bold','ForegroundColor',[1 0 0],...
                               'Position',[0.1 0.5 0.3 0.02],'String','Warning: Overlaying frames detected !!!','Style','text','Tag','tWarning','Visible','off');
            
hMergeGui.tFrame = uicontrol('Parent',hMergeGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','left',...
                         'Position',[0.85 0.98 0.05 0.02],'String','Frame:','Style','text','Tag','tFrame');

hMergeGui.tFrameValue = uicontrol('Parent',hMergeGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','right',...
                              'Position',[0.9 0.98 0.05 0.02],'String','','Style','text','Tag','tFrameValue');

set(hMergeGui.fig, 'WindowButtonMotionFcn', @UpdateCursor);
set(hMergeGui.fig, 'WindowButtonDownFcn',@ButtonDown);
set(hMergeGui.fig, 'WindowButtonUpFcn',@ButtonUp);

hMergeGui.downPos = struct('x',0,'y',0);
hMergeGui.List=List;
hMergeGui.Mode=Mode;
setappdata(0,'hMergeGui',hMergeGui);
setappdata(hMergeGui.fig,'Objects',Objects);
UpdateData(hMergeGui);
UpdateTable(hMergeGui);


function UpdateData(hMergeGui)
Objects=getappdata(hMergeGui.fig,'Objects');
List=hMergeGui.List;
str=cell(length(List),1);
for i=1:length(List)
    str{i}=Objects(List(i)).Name;
end    
set(hMergeGui.lMerge,'String',str);
Data=[];
for i=1:length(List)
    nData=size(Data,1);
    nAdd=size(Objects(List(i)).Results,1);
    Data(nData+1:nData+nAdd,1)=List(i);
    Data(nData+1:nData+nAdd,2:5)=Objects(List(i)).Results(:,1:4);
end
Data=sortrows(Data,2);
nData=size(Data,1);
for i=1:nData
    k=find(Data(i,2)==Data(:,2));
    if length(k)>1
        Data(i,7)=1;
    else
        Data(i,7)=0;
    end
end
setappdata(hMergeGui.fig,'Data',Data);

function UpdateTable(hMergeGui)
Data=getappdata(hMergeGui.fig,'Data');
Objects=getappdata(hMergeGui.fig,'Objects');
k=findobj(hMergeGui.fig,'Style','checkbox');
delete(k);
cell_data = num2cell(Data(:,1:5));
nData=size(Data,1);
for i=1:nData
    cell_data(i,1)=cellstr(Objects(Data(i,1)).Name);
end
columninfo.titles={    'Name', 'Frame',    'Time',  'XPosition',  'YPosition'};
columninfo.formats = {'%s', '%04.0f',  '%06.2f',     '%08.2f',     '%08.2f',};
columninfo.weight =      [ 1, 1, 1.3, 1.3, 1.3];
columninfo.multipliers = [ 1, 1, 1, 1, 1];
columninfo.isEditable =  [ 0, 0, 0, 0, 0];
columninfo.isNumeric =   [ 0  1, 1, 1, 1];
columninfo.withCheck = true; % optional to put checkboxes along left side
columninfo.chkLabel = ''; % optional col header for checkboxes
rowHeight = 20;
gFont.size=10;
gFont.name='MS Sans Serif';
mltable(hMergeGui.fig, hMergeGui.aTable, 'CreateTable', columninfo, rowHeight, cell_data, gFont);
k=find(Data(:,6)==1);
if ~isempty(k)
    for i=1:length(k)   
        mltable(hMergeGui.fig, hMergeGui.aTable, 'SetCheck', columninfo, rowHeight, cell_data, gFont,k(i),Data(k(i),6));
    end
end
k=find(Data(:,7)==1,1);
if ~isempty(k)
    set(hMergeGui.tWarning,'Visible','on');
    set(hMergeGui.bOK,'Enable','off');
else
    set(hMergeGui.tWarning,'Visible','off');    
    set(hMergeGui.bOK,'Enable','on');    
end


setappdata(hMergeGui.fig,'Data',Data);
Draw(hMergeGui);
setappdata(0,'hMergeGui',hMergeGui);

function Draw(hMergeGui)
Data=getappdata(hMergeGui.fig,'Data');
if get(hMergeGui.lMerge,'Value')>length(hMergeGui.List);
    set(hMergeGui.lMerge,'Value',length(hMergeGui.List));
end
axes(hMergeGui.aPlot)
xy=get(hMergeGui.aPlot,{'xlim','ylim'});
plot(Data(:,4),Data(:,5),'b-*')
if xy{1}(2)~=1
    xlim(xy{1});
    ylim(xy{2});
end
for i=1:size(Data,1)
    if hMergeGui.List(get(hMergeGui.lMerge,'Value'))==Data(i,1)
        hold on
        plot(Data(i,4),Data(i,5),'c*');
        hold off
    end
end
info = get(hMergeGui.aTable, 'userdata');
Check = info.isChecked;
k=find(Data(:,7)==1);
if k>0
    hold on
    plot(Data(k,4),Data(k,5),'ro')
    hold off
end
k=find(Check==1);
if k>0
    hold on
    plot(Data(k,4),Data(k,5),'go')
    hold off
end
axis ij

function Add(hMergeGui)
idx=get(hMergeGui.lAll,'Value');
k=find(idx==hMergeGui.List,1);
if isempty(k)
    hMergeGui.List=sort([hMergeGui.List idx]);
end
setappdata(0,'hMergeGui',hMergeGui);
UpdateData(hMergeGui);
UpdateTable(hMergeGui);

function Delete(hMergeGui)
idx=get(hMergeGui.lMerge,'Value');
hMergeGui.List(idx)=[];
if get(hMergeGui.lMerge,'Value')>length(hMergeGui.List)
    set(hMergeGui.lMerge,'Value',length(hMergeGui.List));
end
setappdata(0,'hMergeGui',hMergeGui);
UpdateData(hMergeGui);
UpdateTable(hMergeGui);

function DelEntry(hMergeGui)
Data=getappdata(hMergeGui.fig,'Data');
info = get(hMergeGui.aTable, 'userdata');
Check = info.isChecked;
Data(:,6)=Check;
Data(Check==1,:)=[];
nData=size(Data,1);
for i=1:nData
    k=find(Data(i,2)==Data(:,2));
    if length(k)>1
        Data(i,7)=1;
    else
        Data(i,7)=0;
    end
end
setappdata(hMergeGui.fig,'Data',Data);
UpdateTable(hMergeGui);

function OK(hMergeGui)
global Config;
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
hMainGui=getappdata(0,'hMainGui');
Data=getappdata(hMergeGui.fig,'Data');
Objects=getappdata(hMergeGui.fig,'Objects');
List=hMergeGui.List;
nData=size(Data,1);
nList=length(List);
Results=zeros(nData,size(Objects(Data(1,1)).Results,2));
ResultsStart=zeros(nData,8);
ResultsCenter=zeros(nData,8);
ResultsEnd=zeros(nData,8);
Orientation=zeros(1,nData);
data=cell(1,nData);
for i=1:nData
    k=find(Objects(Data(i,1)).Results(:,1)==Data(i,2),1);
    Results(i,:)=Objects(Data(i,1)).Results(k,:);
    Results(i,5)=norm([Results(i,3)-Results(1,3) Results(i,4)-Results(1,4)]);
    if strcmp(hMergeGui.Mode,'Filament')==1
        ResultsCenter(i,1:8)=Objects(Data(i,1)).ResultsCenter(k,1:8);
        ResultsCenter(i,5)=norm([ResultsCenter(i,3)-ResultsCenter(1,3) ResultsCenter(i,4)-ResultsCenter(1,4)]);
        ResultsStart(i,1:8)=Objects(Data(i,1)).ResultsStart(k,1:8);
        ResultsStart(i,5)=norm([ResultsStart(i,3)-ResultsStart(1,3) ResultsStart(i,4)-ResultsStart(1,4)]);            
        ResultsEnd(i,1:8)=Objects(Data(i,1)).ResultsEnd(k,1:8);    
        ResultsEnd(i,5)=norm([ResultsEnd(i,3)-ResultsEnd(1,3) ResultsEnd(i,4)-ResultsEnd(1,4)]);
        Orientation(i)=Objects(Data(i,1)).Orientation(k);
        if i>1
            d=sqrt( (ResultsStart(i,3)-ResultsStart(i-1,3))^2 +...
                    (ResultsStart(i,4)-ResultsStart(i-1,4))^2);
            if d>Results(i,6)/2
               Objects(Data(i,1)).data{k}=Objects(Data(i,1)).data{k}(length(Objects(Data(i,1)).data{k}):-1:1);
               Orientation(i)=mod(Orientation(i)+pi,2*pi);
               ResultsStart(i,1:8)=Objects(Data(i,1)).ResultsEnd(k,1:8);
               ResultsStart(i,5)=norm([ResultsStart(i,3)-ResultsStart(1,3) ResultsStart(i,4)-ResultsStart(1,4)]);            
               ResultsEnd(i,1:8)=Objects(Data(i,1)).ResultsStart(k,1:8);    
               ResultsEnd(i,5)=norm([ResultsEnd(i,3)-ResultsEnd(1,3) ResultsEnd(i,4)-ResultsEnd(1,4)]);
            end
        end
    end
    data{i}=Objects(Data(i,1)).data{k};
end
if strcmp(hMergeGui.Mode,'Filament')==1&&strcmp(Config.RefPoint,'center')==1
    Objects(List(1)).Results=Results;
end
if strcmp(hMergeGui.Mode,'Filament')==1&&strcmp(Config.RefPoint,'start')==1
    Objects(List(1)).Results=ResultsStart;
end
if strcmp(hMergeGui.Mode,'Filament')==1&&strcmp(Config.RefPoint,'end')==1
    Objects(List(1)).Results=ResultsEnd;
end
if strcmp(hMergeGui.Mode,'Molecule')
    Objects(List(1)).Results=Results;
    KymoTrackObj=KymoTrackMol;
elseif strcmp(hMergeGui.Mode,'Filament')
    Objects(List(1)).ResultsStart=ResultsStart;
    Objects(List(1)).ResultsCenter=ResultsCenter;
    Objects(List(1)).ResultsEnd=ResultsEnd;    
    Objects(List(1)).Orientation=Orientation;    
    KymoTrackObj=KymoTrackFil;    
end
Objects(List(1)).data=data;
kList=[];
KymoTrack=[];
for n=1:nList
    k=find(List(n)==[KymoTrackObj.Index]);
    if ~isempty(k)
        KymoTrack=[KymoTrack; KymoTrackObj(k).Track];
        kList=[kList k];
        delete(KymoTrackObj(k).plot);
        delete(KymoTrackObj(k).plotSelectB);
        delete(KymoTrackObj(k).plotSelectW);
    end
end
if ~isempty(kList)
    nTrack=kList(1);
    idx=KymoTrackObj(nTrack).Index;
    KymoTrack=sortrows(KymoTrack,1);
    set(0,'CurrentFigure',hMainGui.fig);
    set(hMainGui.fig,'CurrentAxes',hMainGui.RightPanel.pTools.aKymoGraph);
    KymoTrackObj(nTrack).plot=line(KymoTrack(:,2),KymoTrack(:,1),'Color',Objects(idx).Color,'Visible','off');
    KymoTrackObj(nTrack).plotSelectB=line(KymoTrack(:,2),KymoTrack(:,1),'Color','black','Visible','off','LineStyle','-.');        
    KymoTrackObj(nTrack).plotSelectW=line(KymoTrack(:,2),KymoTrack(:,1),'Color','white','Visible','off','LineStyle',':');
    if Objects(idx).Visible
        set(KymoTrackObj(nTrack).plot,'Visible','on');
    end
    if Objects(idx).Selected
        set(KymoTrackObj(nTrack).plotSelectB,'Visible','on');
        set(KymoTrackObj(nTrack).plotSelectW,'Visible','on');            
    end
    KymoTrackObj(nTrack).Track=KymoTrack;
    KymoTrackObj(kList(2:length(kList)))=[];
end
for n=1:length(KymoTrackObj)
    cIndex=sum(List(2:nList)<KymoTrackObj(n).Index);
    KymoTrackObj(n).Index=KymoTrackObj(n).Index-cIndex;
end
Objects(List(2:nList))=[];
if strcmp(hMergeGui.Mode,'Molecule')==1
    KymoTrackMol=KymoTrackObj;
    Molecule=Objects;
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Objects,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
else
    KymoTrackFil=KymoTrackObj;
    Filament=Objects;
    fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Objects,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
end
fShow('Image');
fShow('Tracks');
close(hMergeGui.fig);

function UpdateCursor(hObject, eventdata) %#ok<INUSD>
hMergeGui=getappdata(0,'hMergeGui');
Data=getappdata(hMergeGui.fig,'Data');
xy=get(hMergeGui.aPlot,{'xlim','ylim'});
cp=get(hMergeGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
if all(cp>=1) && all(cp<=[xy{1}(2) xy{2}(2)])
    if strcmp(get(hMergeGui.ToolCursor,'State'),'on')==1
        set(hMergeGui.fig,'pointer','arrow');
        dx=((xy{1}(2)-xy{1}(1))/100);
        dy=((xy{2}(2)-xy{2}(1))/100);
        k=find( abs(Data(:,4)-cp(1))<dx & abs(Data(:,5)-cp(2))<dy);
        [m,t]=min((Data(k,4)-cp(1)).^2+(Data(k,5)-cp(2)).^2);
        set(hMergeGui.tFrameValue,'String',num2str(Data(k(t),2)));
    else
        set(hMergeGui.tFrameValue,'String','');
    end
    if strcmp(get(hMergeGui.ToolRegion,'State'),'on')==1
        CData=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,1,1,1,1,1,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,1,1,1,1,1,1,1,1,1,1,NaN,NaN,NaN;NaN,NaN,1,1,1,NaN,NaN,1,1,NaN,NaN,1,1,1,NaN,NaN;NaN,NaN,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN,NaN;NaN,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN;NaN,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN;1,1,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,1,1;1,1,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,1,1;NaN,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN;NaN,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN;NaN,NaN,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN,NaN;NaN,NaN,1,1,1,NaN,NaN,1,1,NaN,NaN,1,1,1,NaN,NaN;NaN,NaN,NaN,1,1,1,1,1,1,1,1,1,1,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,1,1,1,1,1,1,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
        set(hMergeGui.fig,'Pointer','custom','PointerShapeCData',CData,'PointerShapeHotSpot',[8 8])
        if(hMergeGui.downPos.x>0)&&(hMergeGui.downPos.y>0)
            hMergeGui.Region.X=[hMergeGui.Region.X cp(1)];
            hMergeGui.Region.Y=[hMergeGui.Region.Y cp(2)];
            bx=[hMergeGui.Region.X hMergeGui.Region.X(1)];
            by=[hMergeGui.Region.Y hMergeGui.Region.Y(1)];
            delete(hMergeGui.plotReg);
            hold on
            hMergeGui.plotReg=plot(bx,by,'Color','black','LineStyle',':');
            hold off
        end
    end
    if strcmp(get(hMergeGui.ToolRectRegion,'State'),'on')==1
        set(hMergeGui.fig,'pointer','crosshair');
        if(hMergeGui.downPos.x>0)&&(hMergeGui.downPos.y>0)
            hMergeGui.Region.X=[hMergeGui.downPos.x cp(1) cp(1) hMergeGui.downPos.x];
            hMergeGui.Region.Y=[hMergeGui.downPos.y hMergeGui.downPos.y cp(2) cp(2)];
            bx=[hMergeGui.Region.X hMergeGui.downPos.x];
            by=[hMergeGui.Region.Y hMergeGui.downPos.y];
            delete(hMergeGui.plotReg);
            hold on
            hMergeGui.plotReg=plot(bx,by,'Color','black','LineStyle',':');
            hold off
        end
    end
else
    set(hMergeGui.fig,'pointer','arrow');
end
setappdata(0,'hMergeGui',hMergeGui);


function ButtonDown(hObject, eventdata) %#ok<INUSD>
hMergeGui=getappdata(0,'hMergeGui');
xy=get(hMergeGui.aPlot,{'xlim','ylim'});
cp=get(hMergeGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
if all(cp>=0) && all(cp<=[xy{1}(2) xy{2}(2)]);
    if (hMergeGui.downPos.x==0)&&(hMergeGui.downPos.y==0)
       if (strcmp(get(hMergeGui.ToolRegion,'State'),'on')==1)||(strcmp(get(hMergeGui.ToolRectRegion,'State'),'on')==1)
            hMergeGui.downPos.x=cp(1);
            hMergeGui.downPos.y=cp(2);
            hMergeGui.Region.X=cp(1);
            hMergeGui.Region.Y=cp(2);
            bx=hMergeGui.Region.X;
            by=hMergeGui.Region.Y;
            hold on
            hMergeGui.plotReg=plot(bx,by,'Color','black','LineStyle',':');
            hold off
        end
    end
end
setappdata(0,'hMergeGui',hMergeGui);

function ButtonUp(hObject, eventdata) %#ok<INUSD>
hMergeGui=getappdata(0,'hMergeGui');
Data=getappdata(hMergeGui.fig,'Data');
xy=get(hMergeGui.aPlot,{'xlim','ylim'});
cp=get(hMergeGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
if all(cp>=0) && all(cp<=[xy{1}(2) xy{2}(2)]);
    if strcmp(get(hMergeGui.ToolCursor,'State'),'on')==1 
        dx=((xy{1}(2)-xy{1}(1))/100);
        dy=((xy{2}(2)-xy{2}(1))/100);
        k=find( abs(Data(:,4)-cp(1))<dx & abs(Data(:,5)-cp(2))<dy);
        [m,t]=min((Data(k,4)-cp(1)).^2+(Data(k,5)-cp(2)).^2);
        Data(k(t),6)=abs(Data(k(t),6)-1);
    end
end
if ((strcmp(get(hMergeGui.ToolRegion,'State'),'on')==1)||(strcmp(get(hMergeGui.ToolRectRegion,'State'),'on')==1))&&(hMergeGui.downPos.x>0)&&(hMergeGui.downPos.y>0)
    hMergeGui.Region.X=[hMergeGui.Region.X hMergeGui.Region.X(1)];
    hMergeGui.Region.Y=[hMergeGui.Region.Y hMergeGui.Region.Y(1)];
    hMergeGui.downPos.x=0;
    hMergeGui.downPos.y=0;
    IN = inpolygon(Data(:,4),Data(:,5),hMergeGui.Region.X,hMergeGui.Region.Y);
    Data(IN,6)=abs(Data(IN,6)-1);
    delete(hMergeGui.plotReg);
end
setappdata(0,'hMergeGui',hMergeGui);
setappdata(hMergeGui.fig,'Data',Data);
UpdateTable(hMergeGui);

function hMergeGui=ToolBar(hMergeGui)
hMergeGui.ToolBar=uitoolbar(hMergeGui.fig);  
hMergeGui=ToolCursor(hMergeGui);
hMergeGui=ToolPan(hMergeGui);
hMergeGui=ToolZoomIn(hMergeGui);
hMergeGui=ToolRegion(hMergeGui);
hMergeGui=ToolRectRegion(hMergeGui);

%/////////////////////////////////////////////////////////////////////////%
%                            Create Cursor Button in Toolbar              %
%/////////////////////////////////////////////////////////////////////////%
function hMergeGui=ToolCursor(hMergeGui)

CData(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,0,0,0,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,0,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN;];
CData(:,:,2)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,0,0,0,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,0,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN;];
CData(:,:,3)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,0,0,0,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,0,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN;];
hMergeGui.ToolCursor=uitoggletool(hMergeGui.ToolBar,'CData',CData,'TooltipString','Cursor','Separator','on','State','on','OnCallback','fMergeGui(''bToggleToolCursor'',getappdata(0,''hMergeGui''));');

function bToggleToolCursor(hMergeGui)
set(hMergeGui.ToolCursor,'State','on');
set(hMergeGui.ToolPan,'State','off');
set(hMergeGui.ToolZoomIn,'State','off');
set(hMergeGui.ToolRegion,'State','off');
set(hMergeGui.ToolRectRegion,'State','off');
zoom off
pan off

%/////////////////////////////////////////////////////////////////////////%
%                            Create Zoom In Button in Toolbar             %
%/////////////////////////////////////////////////////////////////////////%
function hMergeGui=ToolPan(hMergeGui)
CData(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,0,0,NaN,0,1,1,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,0,NaN;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,0,1,0;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,1,1,0;NaN,0,0,NaN,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,1,0,1,1,1,1,1,1,1,1,1,0,NaN;NaN,0,1,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,0,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;];
CData(:,:,2)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,0,0,NaN,0,1,1,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,0,NaN;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,0,1,0;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,1,1,0;NaN,0,0,NaN,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,1,0,1,1,1,1,1,1,1,1,1,0,NaN;NaN,0,1,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,0,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;];
CData(:,:,3)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,0,0,NaN,0,1,1,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,0,NaN;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,0,1,0;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,1,1,0;NaN,0,0,NaN,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,1,0,1,1,1,1,1,1,1,1,1,0,NaN;NaN,0,1,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,0,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;];
hMergeGui.ToolPan=uitoggletool(hMergeGui.ToolBar,'CData',CData,'TooltipString','Pan','ClickedCallback','fMergeGui(''bToolPan'',getappdata(0,''hMergeGui''));');

function bToolPan(hMergeGui)
set(hMergeGui.ToolCursor,'State','off');
set(hMergeGui.ToolPan,'State','on');
set(hMergeGui.ToolZoomIn,'State','off');
set(hMergeGui.ToolRegion,'State','off');
set(hMergeGui.ToolRectRegion,'State','off');
zoom off
pan on

%/////////////////////////////////////////////////////////////////////////%
%                            Create Zoom In Button in Toolbar             %
%/////////////////////////////////////////////////////////////////////////%
function hMergeGui=ToolZoomIn(hMergeGui)
CData(:,:,1)=[NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,0,0,0.8,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN;NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN;NaN,0,NaN,NaN,NaN,0,0,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN;0,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN;0,NaN,NaN,0,0,0,0,0,0,NaN,NaN,0,NaN,NaN,NaN,NaN;0,NaN,NaN,0,0,0,0,0,0,NaN,NaN,0,NaN,NaN,NaN,NaN;0,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN;NaN,0,NaN,NaN,NaN,0,0,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN;NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,0,0,NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,0,0,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
CData(:,:,2)=[1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1;1,1,0,0,0.8,1,1,1,0,0,1,1,1,1,1,1;1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1;1,0,1,1,1,0,0,1,1,1,0,1,1,1,1,1;0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1;0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1;0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1;0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1;1,0,1,1,1,0,0,1,1,1,0,1,1,1,1,1;1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1;1,1,0,0,1,1,1,1,0,0,0,0,1,1,1,1;1,1,1,1,0,0,0,0,1,1,0,0,0,1,1,1;1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1;1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1;1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1;1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;];
CData(:,:,3)=[1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1;1,1,0,0,0.8,1,1,1,0,0,1,1,1,1,1,1;1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1;1,0,1,1,1,0,0,1,1,1,0,1,1,1,1,1;0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1;0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1;0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1;0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1;1,0,1,1,1,0,0,1,1,1,0,1,1,1,1,1;1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1;1,1,0,0,1,1,1,1,0,0,0.502,0.502,1,1,1,1;1,1,1,1,0,0,0,0,1,1,0.502,0.502,0.502,1,1,1;1,1,1,1,1,1,1,1,1,1,1,0.502,0.502,0.502,1,1;1,1,1,1,1,1,1,1,1,1,1,1,0.502,0.502,0.502,1;1,1,1,1,1,1,1,1,1,1,1,1,1,0.502,0.502,1;1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;];
hMergeGui.ToolZoomIn=uitoggletool(hMergeGui.ToolBar,'CData',CData,'TooltipString','Zoom','ClickedCallback','fMergeGui(''bToolZoomIn'',getappdata(0,''hMergeGui''));');

function bToolZoomIn(hMergeGui)
set(hMergeGui.ToolCursor,'State','off');
set(hMergeGui.ToolPan,'State','off');
set(hMergeGui.ToolZoomIn,'State','on');
set(hMergeGui.ToolRegion,'State','off');
set(hMergeGui.ToolRectRegion,'State','off');
zoom on
pan off

%/////////////////////////////////////////////////////////////////////////%
%                            Create Molcule Button in Toolbar             %
%/////////////////////////////////////////////////////////////////////////%
function hMergeGui=ToolRegion(hMergeGui)
CData(:,:,1)=[0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0,0,0,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0,0,0,0,0,0,0,0,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0,0,0,0.92549,0.92549,0,0,0.92549,0.92549,0,0,0,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549;0.92549,0,0,0,0,0,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0,0,0,0,0.92549;0.92549,0,0,0,0,0,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0,0,0,0,0.92549;0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0,0,0,0.92549,0.92549,0,0,0.92549,0.92549,0,0,0,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0,0,0,0,0,0,0,0,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0,0,0,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;];
CData(:,:,2)=[0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0,0,0,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0,0,0,0,0,0,0,0,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0,0,0,0.91373,0.91373,0,0,0.91373,0.91373,0,0,0,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373;0.91373,0,0,0,0,0,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0,0,0,0,0.91373;0.91373,0,0,0,0,0,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0,0,0,0,0.91373;0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0,0,0,0.91373,0.91373,0,0,0.91373,0.91373,0,0,0,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0,0,0,0,0,0,0,0,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0,0,0,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;];
CData(:,:,3)=[0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0,0,0,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0,0,0,0,0,0,0,0,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0,0,0,0.84706,0.84706,0,0,0.84706,0.84706,0,0,0,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706;0.84706,0,0,0,0,0,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0,0,0,0,0.84706;0.84706,0,0,0,0,0,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0,0,0,0,0.84706;0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0,0,0,0.84706,0.84706,0,0,0.84706,0.84706,0,0,0,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0,0,0,0,0,0,0,0,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0,0,0,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;];
hMergeGui.ToolRegion=uitoggletool(hMergeGui.ToolBar,'CData',CData,'TooltipString','Region','OnCallback','fMergeGui(''bToggleToolRegion'',getappdata(0,''hMergeGui''));');

function bToggleToolRegion(hMergeGui)
set(hMergeGui.ToolCursor,'State','off');
set(hMergeGui.ToolPan,'State','off');
set(hMergeGui.ToolZoomIn,'State','off');
set(hMergeGui.ToolRegion,'State','on');
set(hMergeGui.ToolRectRegion,'State','off');
zoom off
pan off

%/////////////////////////////////////////////////////////////////////////%
%                            Create Object Button in Toolbar              %
%/////////////////////////////////////////////////////////////////////////%
function hMergeGui=ToolRectRegion(hMergeGui)
CData(:,:,1)=[0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0,0.92549,0,0,0.92549,0,0,0.92549,0,0,0.92549,0,0,0.92549,0,0,0.92549,0,0.92549;0.92549,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0.92549;0.92549,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0.92549;0.92549,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0.92549;0.92549,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0,0.92549;0.92549,0,0.92549,0,0,0.92549,0,0,0.92549,0,0,0.92549,0,0,0.92549,0,0,0.92549,0,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549,0.92549;];
CData(:,:,2)=[0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0,0.91373,0,0,0.91373,0,0,0.91373,0,0,0.91373,0,0,0.91373,0,0,0.91373,0,0.91373;0.91373,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0.91373;0.91373,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0.91373;0.91373,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0.91373;0.91373,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0,0.91373;0.91373,0,0.91373,0,0,0.91373,0,0,0.91373,0,0,0.91373,0,0,0.91373,0,0,0.91373,0,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373,0.91373;];
CData(:,:,3)=[0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0,0.84706,0,0,0.84706,0,0,0.84706,0,0,0.84706,0,0,0.84706,0,0,0.84706,0,0.84706;0.84706,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0.84706;0.84706,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0.84706;0.84706,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0.84706;0.84706,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0,0.84706;0.84706,0,0.84706,0,0,0.84706,0,0,0.84706,0,0,0.84706,0,0,0.84706,0,0,0.84706,0,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706,0.84706;];
hMergeGui.ToolRectRegion=uitoggletool(hMergeGui.ToolBar,'CData',CData,'TooltipString','Rectangle Region','OnCallback','fMergeGui(''bToggleToolRectRegion'',getappdata(0,''hMergeGui''));');

function bToggleToolRectRegion(hMergeGui)
set(hMergeGui.ToolCursor,'State','off');
set(hMergeGui.ToolPan,'State','off');
set(hMergeGui.ToolZoomIn,'State','off');
set(hMergeGui.ToolRegion,'State','off');
set(hMergeGui.ToolRectRegion,'State','on');
zoom off
pan off