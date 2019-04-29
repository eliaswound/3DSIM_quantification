function fDataGui(func,varargin)
switch (func)
    case 'Create'
        Create(varargin{1},varargin{2});
    case 'Draw'
        Draw(varargin{1},varargin{2});
    case 'PlotXY'
        PlotXY(varargin{1});
    case 'PlotDisTime'
        PlotDisTime(varargin{1});
    case 'PlotIntLen'
        PlotIntLen(varargin{1});
    case 'PlotVelTim'
        PlotVelTim(varargin{1});
    case 'Delete'
        Delete(varargin{1});
    case 'Switch'
        Switch(varargin{1});        
    case 'Split'
        Split(varargin{1});          
    case 'Select'
        Select(varargin{1});          
    case 'Drift'
        Drift(varargin{1});
    case 'XAxisList'
        XAxisList(varargin{1});        
    case 'CheckYAxis2'
        CheckYAxis2(varargin{1});              
    case 'bToggleToolCursor'
        bToggleToolCursor(varargin{1});  
    case 'bToolPan'
        bToolPan(varargin{1});
    case 'bToolZoomIn'
        bToolZoomIn(varargin{1});
    case 'Export'
        Export(varargin{1});
end

function hDataGui = Create(Type,idx)
global Molecule;
global Filament;
hDataGui=getappdata(0,'hDataGui');
hDataGui.idx=idx;
hDataGui.Type=Type;
if strcmp(Type,'Molecule')==1
    Object=Molecule(idx);
else
    Object=Filament(idx);
end
h=findobj('Tag','hDataGui');

[lXaxis,lYaxis]=CreatePlotList(Object,Type);

if isempty(h)
    hDataGui.fig = figure('Units','normalized','DockControls','off','IntegerHandle','off','MenuBar','none','Name',Object.Name,...
                          'NumberTitle','off','Position',[0.05 0.05 0.65 0.9],'HandleVisibility','callback','Tag','hDataGui',...
                          'Visible','on','Resize','off','Color',[0.9255 0.9137 0.8471],'WindowStyle','normal');

    hDataGui=ToolBar(hDataGui);         

    hDataGui.pPlotPanel = uipanel('Parent',hDataGui.fig,'Position',[0.35 0.55 0.6 0.4],'Tag','PlotPanel','BackgroundColor','white');
    
    hDataGui.aPlot = axes('Parent',hDataGui.pPlotPanel,'OuterPosition',[0 0 1 1],'Tag','Plot','NextPlot','add','TickDir','out','Layer','top',...
                          'XLimMode','manual','YLimMode','manual');
    hDataGui.aPlot2 = axes('Parent',hDataGui.pPlotPanel,'OuterPosition',[0 0 1 1],'Tag','Plot2','NextPlot','add','TickDir','out','Layer','top',...
                          'XLimMode','manual','YLimMode','manual');
    
    hDataGui.aTable = axes('Parent',hDataGui.fig,'Position',[0.05 0.05 0.9 0.45],'Tag','tblParams');

    hDataGui.tName = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'FontWeight','bold',...
                              'HorizontalAlignment','left','Position',[0.05 0.95 0.2 0.02],...
                              'String',Object.Name,'Style','text','Tag','tName');

    hDataGui.tFile = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',8,'FontAngle','italic',...
                              'HorizontalAlignment','left','Position',[0.05 0.905 0.2 0.04],...
                              'String',Object.File,'Style','text','Tag','tFile');

    hDataGui.tIndex = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','left',...
                                'Position',[0.05 0.885 0.05 0.02],'String','Index:','Style','text','Tag','tIndex');

    hDataGui.tIndexValue = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','right',...
                                'Position',[0.1 0.885 0.02 0.02],'String',num2str(idx),'Style','text','Tag','tIndexValue');                        

    hDataGui.cDrift = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''Drift'',getappdata(0,''hDataGui''));',...
                                'Position',[0.05 0.86 0.2 0.02],'String','Correct for Drift','Style','radiobutton','Tag','cDrift','Value',Object.Drift);

    hDataGui.gColor = uibuttongroup('Title','Color','Tag','bColor','Units','normalized','Position',[0.05 0.75 0.25 0.1]);

    hDataGui.rBlue = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.05 0.7 0.4 0.2],...
                               'String','Blue','Style','radiobutton','Tag','rBlue','UserData',[0 0 1]);

    hDataGui.rGreen = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.05 0.4 0.4 0.2],...
                                'String','Green','Style','radiobutton','Tag','rGreen','UserData',[0 1 0]);

    hDataGui.rRed = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.05 0.1 0.4 0.2],...
                              'String','Red','Style','radiobutton','Tag','rRed','UserData',[1 0 0]);

    hDataGui.rPink = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.55 0.7 0.4 0.2],...
                               'String','Pink','Style','radiobutton','Tag','rPink','UserData',[1 0.5 0.5]);

    hhDataGui.rOrange = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.55 0.4 0.4 0.2],...
                                  'String','Orange','Style','radiobutton','Tag','rOrange','UserData',[1 0.5 0]);

    hDataGui.rYellow = uicontrol('Parent',hDataGui.gColor,'Units','normalized','Position',[0.55 0.1 0.4 0.2],...
                                 'String','Yellow','Style','radiobutton','Tag','rYellow','UserData',[1 1 0]);

    set(hDataGui.gColor,'SelectionChangeFcn',@selcbk);

    set(hDataGui.gColor,'SelectedObject',findobj('UserData',Object.Color,'Parent',hDataGui.gColor));

    hDataGui.pPlot = uipanel('Parent',hDataGui.fig,'Title','Plot','Tag','gPlot','Position',[0.05 0.55 0.25 0.2]);

    hDataGui.tXaxis = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Style','text','FontSize',10,'Position',[0.05 0.8 0.33 0.15],...
                                'HorizontalAlignment','left','String','X Axis:','Tag','lXaxis');

    hDataGui.lXaxis = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fDataGui(''XAxisList'',getappdata(0,''hDataGui''));',...
                                'Style','popupmenu','FontSize',10,'Position',[0.4 0.8 0.55 0.18],'String',lXaxis.list,'Tag','lXaxis','UserData',lXaxis,'BackgroundColor','white');

    hDataGui.tYaxis = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Style','text','FontSize',10,'Position',[0.05 0.6 0.33 0.15],...
                                'HorizontalAlignment','left','String','Y Axis (left):','Tag','lYaxis');

    hDataGui.lYaxis = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fDataGui(''Draw'',getappdata(0,''hDataGui''),0);',...
                                'Style','popupmenu','FontSize',10,'Position',[0.4 0.6 0.55 0.18],'String',lYaxis(1).list,'Tag','lYaxis','UserData',lYaxis,'BackgroundColor','white');                        

    hDataGui.cYaxis2 = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fDataGui(''CheckYAxis2'',getappdata(0,''hDataGui''));',...
                                'Position',[0.05 0.46 0.9 0.12],'String','Add second plot','Style','radiobutton','Tag','cYaxis2','Value',0,'Enable','off');

    hDataGui.tYaxis2 = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Style','text','FontSize',10,'Position',[0.05 0.26 0.33 0.15],...
                                'HorizontalAlignment','left','String','Y Axis (right):','Tag','lYaxis','Enable','off');

    hDataGui.lYaxis2 = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fDataGui(''Draw'',getappdata(0,''hDataGui''),0);',...
                                'Style','popupmenu','FontSize',10,'Position',[0.4 0.26 0.55 0.18],'String',lYaxis(1).list,'Tag','lYaxis2','UserData',lYaxis,'Enable','off','BackgroundColor','white');                        

    hDataGui.bExport = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Callback','fDataGui(''Export'',getappdata(0,''hDataGui''));',...
                                 'FontSize',10,'Position',[0.05 0.1 0.9 0.14],'String','Export','Tag','bExport','UserData','Export');

    hDataGui.tPrint = uicontrol('Parent',hDataGui.pPlot,'Units','normalized','Style','text',...
                                'FontSize',8,'Position',[0.05 0.02 0.9 0.07],'String','(for printing use export to PDF)','Tag','tPrint');
    
    
    hDataGui.bSelectAll = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''Select'',getappdata(0,''hDataGui''));',...
                             'Position',[0.015 0.505 0.05 0.025],'String','Select all','Tag','bSelectAll','UserData',1);                    
                         
    hDataGui.bClear = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''Select'',getappdata(0,''hDataGui''));',...
                             'Position',[0.075 0.505 0.1 0.025],'String','Clear selection','Tag','bClear','UserData',0);                         
    
    hDataGui.bDelete = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''Delete'',getappdata(0,''hDataGui''));',...
                             'Position',[0.35 0.515 0.18 0.025],'String','Delete','Tag','bDelete');
                         
    hDataGui.bSplit = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''Split'',getappdata(0,''hDataGui''));',...
                             'Position',[0.56 0.515 0.18 0.025],'String','Create new track','Tag','bSplit');
   
    hDataGui.bSwitch = uicontrol('Parent',hDataGui.fig,'Units','normalized','Callback','fDataGui(''Switch'',getappdata(0,''hDataGui''));',...
                                'Position',[0.77 0.515 0.18 0.025],'String','Switch MT orientation','Tag','bDelete');
                            
    hDataGui.tFrame = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','left',...
                             'Position',[0.85 0.96 0.05 0.02],'String','Frame:','Style','text','Tag','tFrame');

    hDataGui.tFrameValue = uicontrol('Parent',hDataGui.fig,'Units','normalized','FontSize',10,'HorizontalAlignment','right',...
                                  'Position',[0.9 0.96 0.05 0.02],'String','','Style','text','Tag','tFrameValue');

    set(hDataGui.fig, 'WindowButtonMotionFcn', @Update);
    set(hDataGui.fig, 'WindowButtonUpFcn',@ButtonUp);
    set(hDataGui.fig, 'WindowButtonDownFcn',@ButtonDown);
    set(hDataGui.fig, 'CloseRequestFcn',@Close);
else
    figure(hDataGui.fig);
    set(hDataGui.fig,'Name',Object.Name,'WindowStyle','normal');
    set(hDataGui.tName,'String',Object.Name);
    set(hDataGui.tFile,'String',Object.File);
    set(hDataGui.tIndexValue,'String',num2str(idx));
    set(hDataGui.cDrift,'Value',Object.Drift);
    set(hDataGui.gColor,'SelectedObject',findobj('UserData',Object.Color,'Parent',hDataGui.gColor));

    x=get(hDataGui.lXaxis,'Value');
    if x>length(lXaxis.list)
        set(hDataGui.lXaxis,'Value',length(lXaxis.list));            
    end
    set(hDataGui.lXaxis,'String',lXaxis.list,'UserData',lXaxis);    
    set(hDataGui.lYaxis,'UserData',lYaxis);    
    set(hDataGui.lYaxis2,'UserData',lYaxis);        
    if x==length(lXaxis.list)
        CreateHistograms(hDataGui);
    end
end
hDataGui.CursorDownPos = [0 0];

k=findobj(hDataGui.fig,'Style','checkbox');
delete(k);

cell_data = num2cell(Object.Results(:,1:8));

hDataGui.columninfo.titles={    'Frame',    'Time',  'XPosition',  'YPosition',  'Distance',  'FWHM/Length', 'Intensity', '(\Delta R)'};
hDataGui.columninfo.formats = {'%04.0f',  '%06.2f',     '%08.2f',     '%08.2f',  '%08.2f',    '%08.2f',        '%05.0f', '%05.2f'};
hDataGui.columninfo.weight =      [ 1, 1, 1.3, 1.3, 1.3, 1.3, 1.3, 1.3];
hDataGui.columninfo.multipliers = [ 1, 1, 1, 1, 1, 1, 1, 1];
hDataGui.columninfo.isEditable =  [ 0, 0, 0, 0, 0, 0, 0, 0];
hDataGui.columninfo.isNumeric =   [ 1  1, 1, 1, 1, 1, 1, 1];
hDataGui.columninfo.withCheck = true; % optional to put checkboxes along left side
hDataGui.columninfo.chkLabel = ''; % optional col header for checkboxes

rowHeight = 20;
gFont.size=10;
gFont.name='MS Sans Serif';
 
mltable(hDataGui.fig, hDataGui.aTable, 'CreateTable', hDataGui.columninfo, rowHeight, cell_data, gFont);
info = get(hDataGui.aTable, 'userdata');
Check = info.isChecked;

setappdata(0,'hDataGui',hDataGui);
setappdata(hDataGui.fig,'Object',Object);
setappdata(hDataGui.fig,'Check',Check);
XAxisList(hDataGui);

function selcbk(hObject,eventdata) %#ok<INUSD>
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
hDataGui=getappdata(0,'hDataGui');
hMainGui=getappdata(0,'hMainGui');
color=get(get(hDataGui.gColor,'SelectedObject'),'UserData');
Object=getappdata(hDataGui.fig,'Object');
Object.Color=color;
setappdata(hDataGui.fig,'Object',Object);
if strcmp(hDataGui.Type,'Molecule')
    Molecule(hDataGui.idx)=Object;
    try
        set(Molecule(hDataGui.idx).pTrack,'Color',color);
        k=findobj('Parent',hMainGui.MidPanel.aView,'-and','UserData',Molecule(hDataGui.idx).Name);
        set(k,'Color',color);           
        k=find([KymoTrackMol.Index]==hDataGui.idx);
        if ~isempty(k)
            set(KymoTrackMol(k).plot,'Color',color);   
        end
    catch
    end
else
    Filament(hDataGui.idx)=Object;
    try
        set(Filament(hDataGui.idx).pTrack,'Color',color);
        k=findobj('Parent',hMainGui.MidPanel.aView,'-and','UserData',Microtuble(hDataGui.idx).Name);
        set(k,'Color',color);           
        k=find([KymoTrackFil.Index]==hDataGui.idx);
        if ~isempty(k)
            set(KymoTrackFil(k).plot,'Color',color);            
        end
    catch
    end
end

function Export(hDataGui)
fExportDataGui('Create',hDataGui.Type,hDataGui.idx);

function Draw(hDataGui,ax)
%get object data
Object=getappdata(hDataGui.fig,'Object');
%save current view
xy=get(hDataGui.aPlot,{'xlim','ylim'});
xy2=get(hDataGui.aPlot2,{'xlim','ylim'});

%get plot colums
x=get(hDataGui.lXaxis,'Value');
XList=get(hDataGui.lXaxis,'UserData');
XPlot=XList.data{x};

y=get(hDataGui.lYaxis,'Value');
YList=get(hDataGui.lYaxis,'UserData');
if ~isempty(XPlot)
    YPlot=YList(x).data{y};
else
    XPlot=YList(x).data{y}(:,1);
    YPlot=YList(x).data{y}(:,2);
    XList.list{x}=YList(x).list{y};
    XList.units{x}=YList(x).units{y};
    YList(x).list{y}='number of data points';    
    YList(x).units{y}='';
end

delete(hDataGui.aPlot2);                  
hDataGui.aPlot2 = axes('Parent',hDataGui.pPlotPanel,'OuterPosition',[0 0 1 1],'NextPlot','add','TickDir','out',...
                      'XLimMode','manual','YLimMode','manual');     
                  
delete(hDataGui.aPlot);
hDataGui.aPlot = axes('Parent',hDataGui.pPlotPanel,'OuterPosition',[0 0 1 1],'NextPlot','add','TickDir','out',...
                      'XLimMode','manual','YLimMode','manual'); 
                  
setappdata(0,'hDataGui',hDataGui);                 
hold on     
xscale=1;
yscale=1;
yscale2=1;
if strcmp(XList.units{x},'[nm]') && max(XPlot)-min(XPlot)>5000
    xscale=1000;
    XList.units{x}='[µm]';
    if strcmp(YList(x).units{y},'[nm]')
        yscale=1000;
        YList(x).units{y}='[µm]';
    end
end
if strcmp(YList(x).units{y},'[nm]') && max(YPlot)-min(YPlot)>5000
    yscale=1000;
    YList(x).units{y}='[µm]';
    if strcmp(XList.units{x},'[nm]')
        xscale=1000;
        XList.units{x}='[µm]';    
    end
end
if x<length(XList.data)
    FilXY = [];
    if x==1
        if ~isempty(Object.data)
            if length(Object.data{1})>1
                FilXY=cell(1,4);
                for i=1:length(Object.data)
                    n=length(Object.data{i});                    
                    line(([Object.data{i}.x]-min(XPlot))/xscale,([Object.data{i}.y]-min(YPlot))/yscale,'Color','red','LineStyle','-','Marker','none');
                    VecX(i,:)=[Object.data{i}(ceil(n/4)).x Object.data{i}(fix(3*n/4)).x]-min(XPlot);
                    VecY(i,:)=[Object.data{i}(ceil(n/4)).y Object.data{i}(fix(3*n/4)).y]-min(YPlot);                    
                    VecU(i,:)=[Object.data{i}(ceil(n/4)+1).x Object.data{i}(fix(3*n/4)+1).x]-min(XPlot);
                    VecV(i,:)=[Object.data{i}(ceil(n/4)+1).y Object.data{i}(fix(3*n/4)+1).y]-min(YPlot);
                    FilXY{1} = min([([Object.data{i}.x]-min(XPlot)) FilXY{1}]);
                    FilXY{2} = max([([Object.data{i}.x]-min(XPlot)) FilXY{2}]);                    
                    FilXY{3} = min([([Object.data{i}.y]-min(YPlot)) FilXY{3}]);
                    FilXY{4} = max([([Object.data{i}.y]-min(YPlot)) FilXY{4}]);                    
                end
                Length=mean(Object.ResultsCenter(:,6));                
                VecX=mean(VecX);
                VecY=mean(VecY);                
                VecU=mean(VecU);
                VecV=mean(VecV);                            
                U=(VecU-VecX)./sqrt((VecU-VecX).^2+(VecV-VecY).^2);
                V=(VecV-VecY)./sqrt((VecU-VecX).^2+(VecV-VecY).^2);                
                fill([VecX(1)+Length/20*U(1) VecX(1)+Length/40*V(1) VecX(1)-Length/40*V(1)]/xscale,[VecY(1)+Length/20*V(1) VecY(1)-Length/40*U(1) VecY(1)+Length/40*U(1)]/yscale,'r','EdgeColor','none');
                fill([VecX(2)+Length/20*U(2) VecX(2)+Length/40*V(2) VecX(2)-Length/40*V(2)]/xscale,[VecY(2)+Length/20*V(2) VecY(2)-Length/40*U(2) VecY(2)+Length/40*U(2)]/yscale,'r','EdgeColor','none');                
            end
        end
        XPlot=XPlot-min(XPlot);
        YPlot=YPlot-min(YPlot);        
    end

    %get checked table entries
    Check=getappdata(hDataGui.fig,'Check');
    k=find(Check==1);

    if strcmp(get(hDataGui.cYaxis2,'Enable'),'on') && get(hDataGui.cYaxis2,'Value')

        y2=get(hDataGui.lYaxis2,'Value');
        YList2=get(hDataGui.lYaxis2,'UserData');    
        YPlot2=YList2(x).data{y2};

        if strcmp(YList2(x).units{y2},'[nm]') && max(YPlot2)-min(YPlot2)>5000
            yscale2=1000;
            YList2(x).units{y2}='[µm]';
        end
        delete(hDataGui.aPlot2);
        [AX,hDataGui.DataPlot,hDataGui.DataPlot2]=plotyy(hDataGui.aPlot,XPlot/xscale,YPlot/yscale,XPlot/xscale,YPlot2/yscale2,'plot');
        hDataGui.aPlot=AX(1);
        hDataGui.aPlot2=AX(2); 

        if k>0
            set(hDataGui.fig,'CurrentAxes',hDataGui.aPlot);
            line(XPlot(k)/xscale,YPlot(k)/yscale,'Color','red','LineStyle','none','Marker','o');
            set(hDataGui.fig,'CurrentAxes',hDataGui.aPlot2);
            line(XPlot(k)/xscale,YPlot2(k)/yscale2,'Color','red','LineStyle','none','Marker','o');        
        end

        set(hDataGui.aPlot,'TickDir','out','YTickMode','auto');
        set(hDataGui.aPlot2,'TickDir','out','YTickMode','auto');

        SetLabels(hDataGui,Object,XList,YList,YList2,x,y,y2);
        if length(XPlot)>1
            SetAxis(hDataGui.aPlot,XPlot/xscale,YPlot/yscale,x);
            SetAxis(hDataGui.aPlot2,XPlot/xscale,YPlot2/yscale2,x);
        else
            axis auto;
        end
        set(hDataGui.DataPlot,'Marker','*');
        set(hDataGui.DataPlot2,'Marker','*');
    else
        set(hDataGui.aPlot2,'Visible','off');        
        hDataGui.DataPlot=plot(hDataGui.aPlot,XPlot/xscale,YPlot/yscale,'Color','blue','LineStyle','-','Marker','*');
        if k>0
            set(hDataGui.fig,'CurrentAxes',hDataGui.aPlot);
            line(XPlot(k)/xscale,YPlot(k)/yscale,'Color','red','LineStyle','none','Marker','o');
        end
        if ~isempty(FilXY)
            XPlot=[FilXY{1} FilXY{2}];
            YPlot=[FilXY{3} FilXY{4}];
        end                
        if length(XPlot)>1
            SetAxis(hDataGui.aPlot,XPlot/xscale,YPlot/yscale,x);
        else
            axis auto;
        end
        SetLabels(hDataGui,Object,XList,YList,[],x,y,[]);
    end
else
    hDataGui.DataPlot=bar(hDataGui.aPlot,XPlot/xscale,YPlot/yscale,'BarWidth',1,'EdgeColor','black','FaceColor','blue','LineWidth',1);
    SetAxis(hDataGui.aPlot,XPlot/xscale,YPlot/yscale,NaN);
%    set(hDataGui.aPlot,'XTick',XPlot/xscale);        
    set(hDataGui.aPlot2,'Visible','off');    
    SetLabels(hDataGui,Object,XList,YList,[],x,y,[]);
end
hold off;

if xy{1}(2)~=1&&xy{2}(2)~=1
    if ax==-1
        set(hDataGui.aPlot,{'xlim','ylim'},xy);
        if strcmp(get(hDataGui.aPlot2,'Visible'),'on')
            set(hDataGui.aPlot2,{'xlim','ylim'},xy2);        
        end
     end
end
setappdata(0,'hDataGui',hDataGui);

function SetAxis(a,X,Y,idx)
set(a,'Units','pixel');
pos=get(a,'Position');
set(a,'Units','normalized');
xy{1}=[fix(min(X)) ceil(max(X))];
xy{2}=[fix(min(Y)) ceil(max(Y))];
if all(~isnan(xy{1}))&&all(~isnan(xy{2}))
    if idx==1
        lx=max(X)-min(X);
        ly=max(Y)-min(Y);
        if ly>lx
            xy{1}(2)=min(X)+lx/2+ly/2;
            xy{1}(1)=min(X)+lx/2-ly/2;
        else
            xy{2}(2)=min(Y)+ly/2+lx/2;            
            xy{2}(1)=min(Y)+ly/2-lx/2;
        end
        lx=xy{1}(2)-xy{1}(1);
        xy{1}(1)=xy{1}(1)-lx*(pos(3)/pos(4)-1)/2;
        xy{1}(2)=xy{1}(2)+lx*(pos(3)/pos(4)-1)/2;
        set(a,{'xlim','ylim'},xy,'YDir','reverse');
    else
        set(a,{'xlim','ylim'},xy,'YDir','normal');
        if isnan(idx)
            XTick=get(a,'XTick');
            s=length(XTick);
            xy{1}(1)=2*XTick(1)-XTick(2); 
            xy{1}(2)=2*XTick(s)-XTick(s-1); 
            xy{2}(1)=0;
        end
        YTick=get(a,'YTick');
        s=length(YTick);
        if YTick(1)~=0
            xy{2}(1)=2*YTick(1)-YTick(2); 
        end            
        xy{2}(2)=2*YTick(s)-YTick(s-1); 
        set(a,{'xlim','ylim'},xy,'YDir','normal');
    end
end

function SetLabels(hDataGui,Object,XList,YList,YList2,x,y,y2)
title(hDataGui.aPlot,[Object.Name ' - ' Object.File],'Interpreter','none','FontWeight','bold');
xlabel(hDataGui.aPlot,[XList(1).list{x} '  ' XList.units{x}]);
ylabel(hDataGui.aPlot,[YList(x).list{y} '  ' YList(x).units{y}]);
if ~isempty(y2)
    ylabel(hDataGui.aPlot2,[YList2(x).list{y2} '  ' YList2(x).units{y2}]);
end

function ButtonDown(hObject, eventdata) %#ok<INUSD>
hDataGui=getappdata(0,'hDataGui');
set(hDataGui.fig,'CurrentAxes',hDataGui.aPlot);  
xy=get(hDataGui.aPlot,{'xlim','ylim'});
cp=get(hDataGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
if all(cp>=[xy{1}(1) xy{2}(1)]) && all(cp<=[xy{1}(2) xy{2}(2)])  && ~strcmp(get(hDataGui.DataPlot,'Type'),'hggroup')
    if all(hDataGui.CursorDownPos==0)
       if strcmp(get(hDataGui.ToolCursor,'State'),'on')
            hDataGui.SelectRegion.X=cp(1);
            hDataGui.SelectRegion.Y=cp(2);
            hDataGui.SelectRegion.plot=line(cp(1),cp(2),'Color','black','LineStyle',':','Tag','pSelectRegion');                   
            hDataGui.CursorDownPos=cp;                   
       end
    end
end
setappdata(0,'hDataGui',hDataGui);

function ButtonUp(hObject, eventdata) %#ok<INUSD>
hDataGui=getappdata(0,'hDataGui');
set(hDataGui.fig,'CurrentAxes',hDataGui.aPlot);  
Object=getappdata(hDataGui.fig,'Object');
Check=getappdata(hDataGui.fig,'Check');
xy=get(hDataGui.aPlot,{'xlim','ylim'});
cp=get(hDataGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
X=get(hDataGui.DataPlot,'XData');
Y=get(hDataGui.DataPlot,'YData');
if all(cp>=[xy{1}(1) xy{2}(1)]) && all(cp<=[xy{1}(2) xy{2}(2)]) && strcmp(get(hDataGui.ToolCursor,'State'),'on') && ~strcmp(get(hDataGui.DataPlot,'Type'),'hggroup')
    if all(hDataGui.CursorDownPos==cp)
        dx=((xy{1}(2)-xy{1}(1))/100);
        dy=((xy{2}(2)-xy{2}(1))/100);
        k=find( abs(X-cp(1))<dx & abs(Y-cp(2))<dy);
        [m,t]=min((X(k)-cp(1)).^2+(Y(k)-cp(2)).^2);
        Check(k(t))=abs(Check(k(t))-1);
    else
        hDataGui.SelectRegion.X=[hDataGui.SelectRegion.X hDataGui.SelectRegion.X(1)];
        hDataGui.SelectRegion.Y=[hDataGui.SelectRegion.Y hDataGui.SelectRegion.Y(1)];
        IN = inpolygon(X,Y,hDataGui.SelectRegion.X,hDataGui.SelectRegion.Y);
        Check(IN)=abs(Check(IN)-1);
        k=find(IN==1);
    end
    hDataGui.CursorDownPos(:)=0;        
    try
        delete(hDataGui.SelectRegion.plot);    
    catch
    end
    s=length(k);
    if s>0
        cell_data = num2cell(Object.Results(:,1:8));
        rowHeight = 20;
        gFont.size=10;
        gFont.name='MS Sans Serif';
        for i=1:s
            mltable(hDataGui.fig, hDataGui.aTable, 'SetCheck', hDataGui.columninfo, rowHeight, cell_data, gFont,k(i),Check(k(i)));
        end
    end
    setappdata(0,'hDataGui',hDataGui);
    setappdata(hDataGui.fig,'Check',Check);
    Draw(hDataGui,-1);
end

function Update(hObject, eventdata) %#ok<INUSD>
hDataGui=getappdata(0,'hDataGui');
set(hDataGui.fig,'CurrentAxes',hDataGui.aPlot);  
Object=getappdata(hDataGui.fig,'Object');
xy=get(hDataGui.aPlot,{'xlim','ylim'});
cp=get(hDataGui.aPlot,'currentpoint');
cp=cp(1,[1 2]);
X=get(hDataGui.DataPlot,'XData');
Y=get(hDataGui.DataPlot,'YData');
if all(cp>=[xy{1}(1) xy{2}(1)]) && all(cp<=[xy{1}(2) xy{2}(2)]) 
    dx=((xy{1}(2)-xy{1}(1))/100);
    dy=((xy{2}(2)-xy{2}(1))/100);
    if strcmp(get(hDataGui.ToolCursor,'State'),'on') && ~strcmp(get(hDataGui.DataPlot,'Type'),'hggroup')
        set(hDataGui.fig,'pointer','arrow');
        k=find( abs(X-cp(1))<dx & abs(Y-cp(2))<dy);
        [m,t]=min((X(k)-cp(1)).^2+(Y(k)-cp(2)).^2);
        set(hDataGui.tFrameValue,'String',num2str(Object.Results(k(t),1)));
        if all(hDataGui.CursorDownPos~=0)
            hDataGui.SelectRegion.X=[hDataGui.SelectRegion.X cp(1)];
            hDataGui.SelectRegion.Y=[hDataGui.SelectRegion.Y cp(2)];
            delete(hDataGui.SelectRegion.plot);
            hDataGui.SelectRegion.plot=line([hDataGui.SelectRegion.X hDataGui.SelectRegion.X(1)] ,[hDataGui.SelectRegion.Y hDataGui.SelectRegion.Y(1)],'Color','black','LineStyle',':','Tag','pSelectRegion');
        end
    else 
        set(hDataGui.tFrameValue,'String','');
    end
else
    set(hDataGui.fig,'pointer','arrow');
end
OldCheck=getappdata(hDataGui.fig,'Check');
info = get(hDataGui.aTable, 'userdata');
NewCheck = info.isChecked;
if all(size(OldCheck)==size(NewCheck))
    if ~all(OldCheck==NewCheck)
        Draw(hDataGui,0);
        setappdata(hDataGui.fig,'Check',NewCheck);
    else
        setappdata(0,'hDataGui',hDataGui);
    end
else
    Draw(hDataGui,0);
    setappdata(hDataGui.fig,'Check',NewCheck);
end

function Close(hObject,eventdata) %#ok<INUSD>
hDataGui=getappdata(0,'hDataGui');
hDataGui.idx=0;
setappdata(0,'hDataGui',hDataGui);
set(hDataGui.fig,'Visible','off','WindowStyle','normal');
fShared('ReturnFocus');
fShow('Tracks');

function Delete(hDataGui)
global Filament;
global Molecule;
hMainGui=getappdata(0,'hMainGui');
Object=getappdata(hDataGui.fig,'Object');
info = get(hDataGui.aTable, 'userdata');
Check = info.isChecked;
if sum(Check)<size(Object.Results,1)
    Object.Results(Check==1,:)=[];
    Object.Results(:,5)=sqrt((Object.Results(:,3)-Object.Results(1,3)).^2+(Object.Results(:,4)-Object.Results(1,4)).^2);
    if strcmp(hDataGui.Type,'Filament')==1
        Object.ResultsCenter(Check==1,:)=[];   
        Object.ResultsCenter(:,5)=sqrt((Object.ResultsCenter(:,3)-Object.ResultsCenter(1,3)).^2+(Object.ResultsCenter(:,4)-Object.ResultsCenter(1,4)).^2);
        Object.ResultsStart(Check==1,:)=[];
        Object.ResultsStart(:,5)=sqrt((Object.ResultsStart(:,3)-Object.ResultsStart(1,3)).^2+(Object.ResultsStart(:,4)-Object.ResultsStart(1,4)).^2);
        Object.ResultsEnd(Check==1,:)=[];
        Object.ResultsEnd(:,5)=sqrt((Object.ResultsEnd(:,3)-Object.ResultsEnd(1,3)).^2+(Object.ResultsEnd(:,4)-Object.ResultsEnd(1,4)).^2);
        Object.Orientation(Check==1)=[];
    end
    Object.data(Check==1)=[];
    Check(Check==1)=[];
    k=findobj(hDataGui.fig,'Style','checkbox');
    delete(k);
    cell_data = num2cell(Object.Results(:,1:8));
    rowHeight = 20;
    gFont.size=10;
    gFont.name='MS Sans Serif';
    mltable(hDataGui.fig, hDataGui.aTable, 'CreateTable', hDataGui.columninfo, rowHeight, cell_data, gFont);
    setappdata(hDataGui.fig,'Object',Object);
    if strcmp(hDataGui.Type,'Molecule')==1
        Molecule(hDataGui.idx)=Object;
    else
        Filament(hDataGui.idx)=Object;
    end
    [lXaxis,lYaxis]=CreatePlotList(Object,hDataGui.Type);
    set(hDataGui.lXaxis,'UserData',lXaxis);    
    set(hDataGui.lYaxis,'UserData',lYaxis);    
    set(hDataGui.lYaxis2,'UserData',lYaxis);        
    setappdata(hDataGui.fig,'Check',Check);
    Draw(hDataGui,0);
    fRightPanel('UpdateKymoTracks',hMainGui);
end

function Switch(hDataGui)
global Filament;
if strcmp(hDataGui.Type,'Filament')==1
    Object=getappdata(hDataGui.fig,'Object');
    info = get(hDataGui.aTable, 'userdata');
    Check = find([info.isChecked]==1);
    ResultsStart=Object.ResultsStart;
    ResultsEnd=Object.ResultsEnd;
    Orientation=Object.Orientation;
    data=Object.data;
    for n=Check
        data{n}=Object.data{n}(length(Object.data{n}):-1:1);
        Orientation(n)=mod(Object.Orientation(n)+pi,2*pi);
        ResultsStart(n,:)=Object.ResultsEnd(n,:);
        ResultsStart(n,5)=norm([ResultsStart(n,3)-ResultsStart(1,3) ResultsStart(n,4)-ResultsStart(1,4)]);            
        ResultsEnd(n,:)=Object.ResultsStart(n,:);    
        ResultsEnd(n,5)=norm([ResultsEnd(n,3)-ResultsEnd(1,3) ResultsEnd(n,4)-ResultsEnd(1,4)]);
    end
    if all(Object.ResultsStart==Object.Results)
        Object.Results=ResultsStart;
    elseif all(Object.ResultsEnd==Object.Results)
        Object.Results=ResultsEnd;
    end
    Object.ResultsStart=ResultsStart;
    Object.ResultsEnd=ResultsEnd;    
    Object.Orientation=Orientation;   
    Object.data=data;
    Filament(hDataGui.idx)=Object;
    [lXaxis,lYaxis]=CreatePlotList(Object,hDataGui.Type);
    set(hDataGui.lXaxis,'UserData',lXaxis);    
    set(hDataGui.lYaxis,'UserData',lYaxis);    
    set(hDataGui.lYaxis2,'UserData',lYaxis);        
    Check=getappdata(hDataGui.fig,'Check');    
    Check(:)=0;
    setappdata(hDataGui.fig,'Check',Check);
    k=findobj(hDataGui.fig,'Style','checkbox');
    delete(k);
    cell_data = num2cell(Object.Results(:,1:8));
    rowHeight = 20;
    gFont.size=10;
    gFont.name='MS Sans Serif';
    mltable(hDataGui.fig, hDataGui.aTable, 'CreateTable', hDataGui.columninfo, rowHeight, cell_data, gFont);
    setappdata(hDataGui.fig,'Object',Object);
    Draw(hDataGui,0);
end

function Split(hDataGui)
global Filament;
global Molecule;
hMainGui=getappdata(0,'hMainGui');
Object=getappdata(hDataGui.fig,'Object');
info = get(hDataGui.aTable, 'userdata');
Check = info.isChecked;
if sum(Check)<length(Check)
    Object.Results(Check==0,:)=[];
    Object.Results(:,5)=sqrt((Object.Results(:,3)-Object.Results(1,3)).^2+(Object.Results(:,4)-Object.Results(1,4)).^2);
    if strcmp(hDataGui.Type,'Filament')==1
        Object.ResultsCenter(Check==0,:)=[];   
        Object.ResultsCenter(:,5)=sqrt((Object.ResultsCenter(:,3)-Object.ResultsCenter(1,3)).^2+(Object.ResultsCenter(:,4)-Object.ResultsCenter(1,4)).^2);
        Object.ResultsStart(Check==0,:)=[];
        Object.ResultsStart(:,5)=sqrt((Object.ResultsStart(:,3)-Object.ResultsStart(1,3)).^2+(Object.ResultsStart(:,4)-Object.ResultsStart(1,4)).^2);
        Object.ResultsEnd(Check==0,:)=[];
        Object.ResultsEnd(:,5)=sqrt((Object.ResultsEnd(:,3)-Object.ResultsEnd(1,3)).^2+(Object.ResultsEnd(:,4)-Object.ResultsEnd(1,4)).^2);
        Object.Orientation(Check==0)=[];
    end
    Object.data(Check==0)=[];
    Object.Name=sprintf('New %s',Object.Name);
    if strcmp(hDataGui.Type,'Molecule')
        Molecule(length(Molecule)+1)=Object;
        fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
    elseif strcmp(hDataGui.Type,'Filament')
        Filament(length(Filament)+1)=Object;
        fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);    
    end
    Delete(hDataGui);
end

function Drift(hDataGui)
global Molecule;
global Filament;
Object=getappdata(hDataGui.fig,'Object');
hMainGui=getappdata(0,'hMainGui');
Drift=getappdata(hMainGui.fig,'Drift');
if ~isempty(Drift)
    nData=size(Object.Results,1);
    for i=1:nData
        k=find(Drift(:,1)==Object.Results(i,1));
        if length(k)==1
            if get(hDataGui.cDrift,'Value')==1
                Object.Results(i,3)=Object.Results(i,3)-Drift(k,2);
                Object.Results(i,4)=Object.Results(i,4)-Drift(k,3);
                if (size(Object.Results,2)==10)&&size(Drift,2)==5
                    Object.Results(i,9)=Object.Results(i,9)+Drift(k,4);  
                    Object.Results(i,10)=Object.Results(i,10)+Drift(k,5);  
                    Object.Results(i,8)=sqrt(Object.Results(i,9)^2+Object.Results(i,10)^2);
                end
                if isfield(Object,'ResultsCenter')
                    Object.ResultsStart(i,3)=Object.ResultsStart(i,3)-Drift(k,2);
                    Object.ResultsStart(i,4)=Object.ResultsStart(i,4)-Drift(k,3);
                    Object.ResultsCenter(i,3)=Object.ResultsCenter(i,3)-Drift(k,2);
                    Object.ResultsCenter(i,4)=Object.ResultsCenter(i,4)-Drift(k,3);
                    Object.ResultsEnd(i,3)=Object.ResultsEnd(i,3)-Drift(k,2);
                    Object.ResultsEnd(i,4)=Object.ResultsEnd(i,4)-Drift(k,3);
                end
                for j=1:length(Object.data{i})
                    Object.data{i}(j).x=Object.data{i}(j).x-Drift(k,2);
                    Object.data{i}(j).y=Object.data{i}(j).y-Drift(k,3);
                end
            else
                Object.Results(i,3)=Object.Results(i,3)+Drift(k,2);
                Object.Results(i,4)=Object.Results(i,4)+Drift(k,3);
                if size(Object.Results,2)==10&&size(Drift,2)==5
                    Object.Results(i,9)=Object.Results(i,9)-Drift(k,4);  
                    Object.Results(i,10)=Object.Results(i,10)-Drift(k,5);  
                    Object.Results(i,8)=sqrt(Object.Results(i,9)^2+Object.Results(i,10)^2);
                end
                if isfield(Object,'ResultsCenter')
                    Object.ResultsStart(i,3)=Object.ResultsStart(i,3)+Drift(k,2);
                    Object.ResultsStart(i,4)=Object.ResultsStart(i,4)+Drift(k,3);
                    Object.ResultsCenter(i,3)=Object.ResultsCenter(i,3)+Drift(k,2);
                    Object.ResultsCenter(i,4)=Object.ResultsCenter(i,4)+Drift(k,3);
                    Object.ResultsEnd(i,3)=Object.ResultsEnd(i,3)+Drift(k,2);
                    Object.ResultsEnd(i,4)=Object.ResultsEnd(i,4)+Drift(k,3);
                end                
                for j=1:length(Object.data{i})
                    Object.data{i}(j).x=Object.data{i}(j).x+Drift(k,2);
                    Object.data{i}(j).y=Object.data{i}(j).y+Drift(k,3);
                end            
            end
        end
       Object.Results(i,5)=norm([Object.Results(i,3)-Object.Results(1,3) Object.Results(i,4)-Object.Results(1,4)]);
    end
    Object.Drift=get(hDataGui.cDrift,'Value');
    if strcmp(hDataGui.Type,'Molecule')==1
        Molecule(hDataGui.idx)=Object;
    else
        Filament(hDataGui.idx)=Object;
    end
    cell_data = num2cell(Object.Results(:,1:8));
    rowHeight = 20;
    gFont.size=10;
    gFont.name='MS Sans Serif';
    mltable(hDataGui.fig, hDataGui.aTable, 'CreateTable', hDataGui.columninfo, rowHeight, cell_data, gFont);
    setappdata(hDataGui.fig,'Object',Object);
    [lXaxis,lYaxis]=CreatePlotList(Object,hDataGui.Type);
    set(hDataGui.lXaxis,'String',lXaxis.list,'UserData',lXaxis);    
    set(hDataGui.lYaxis,'UserData',lYaxis);    
    set(hDataGui.lYaxis2,'UserData',lYaxis); 
    x=get(hDataGui.lXaxis,'Value');
    if x==length(lXaxis.list)
        CreateHistograms(hDataGui);
    end
    Draw(hDataGui,0);
end

function Select(hDataGui)
Object=getappdata(hDataGui.fig,'Object');
info = get(hDataGui.aTable, 'userdata');
value=get(gcbo,'UserData');
Check = info.isChecked;
Check(:)=value;
cell_data = num2cell(Object.Results(:,1:8));
rowHeight = 20;
gFont.size=10;
gFont.name='MS Sans Serif';
for n=1:length(Check)
    mltable(hDataGui.fig, hDataGui.aTable, 'SetCheck', hDataGui.columninfo, rowHeight, cell_data, gFont,n,value);
end
setappdata(hDataGui.fig,'Check',Check);
Draw(hDataGui,-1);

function hDataGui=ToolBar(hDataGui)
hDataGui.ToolBar=uitoolbar(hDataGui.fig);  
hDataGui=ToolCursor(hDataGui);
hDataGui=ToolPan(hDataGui);
hDataGui=ToolZoomIn(hDataGui);

%/////////////////////////////////////////////////////////////////////////%
%                            Create Cursor Button in Toolbar              %
%/////////////////////////////////////////////////////////////////////////%
function hDataGui=ToolCursor(hDataGui)

CData(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,0,0,0,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,0,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN;];
CData(:,:,2)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,0,0,0,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,0,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN;];
CData(:,:,3)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,0,0,0,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,0,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN;];
hDataGui.ToolCursor=uitoggletool(hDataGui.ToolBar,'CData',CData,'TooltipString','Cursor','Separator','on','State','on','OnCallback','fDataGui(''bToggleToolCursor'',getappdata(0,''hDataGui''));');

function bToggleToolCursor(hDataGui)
set(hDataGui.ToolCursor,'State','on');
set(hDataGui.ToolPan,'State','off');
set(hDataGui.ToolZoomIn,'State','off');
zoom off
pan off

%/////////////////////////////////////////////////////////////////////////%
%                            Create Zoom In Button in Toolbar             %
%/////////////////////////////////////////////////////////////////////////%
function hDataGui=ToolPan(hDataGui)
CData(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,0,0,NaN,0,1,1,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,0,NaN;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,0,1,0;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,1,1,0;NaN,0,0,NaN,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,1,0,1,1,1,1,1,1,1,1,1,0,NaN;NaN,0,1,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,0,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;];
CData(:,:,2)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,0,0,NaN,0,1,1,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,0,NaN;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,0,1,0;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,1,1,0;NaN,0,0,NaN,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,1,0,1,1,1,1,1,1,1,1,1,0,NaN;NaN,0,1,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,0,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;];
CData(:,:,3)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,0,0,NaN,0,1,1,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,0,NaN;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,0,1,0;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,1,1,0;NaN,0,0,NaN,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,1,0,1,1,1,1,1,1,1,1,1,0,NaN;NaN,0,1,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,0,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;];
hDataGui.ToolPan=uitoggletool(hDataGui.ToolBar,'CData',CData,'TooltipString','Pan','ClickedCallback','fDataGui(''bToolPan'',getappdata(0,''hDataGui''));');

function bToolPan(hDataGui)
set(hDataGui.ToolCursor,'State','off');
set(hDataGui.ToolPan,'State','on');
set(hDataGui.ToolZoomIn,'State','off');
zoom off
pan on

%/////////////////////////////////////////////////////////////////////////%
%                            Create Zoom In Button in Toolbar             %
%/////////////////////////////////////////////////////////////////////////%
function hDataGui=ToolZoomIn(hDataGui)
CData(:,:,1)=[NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,0,0,0.8,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN;NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN;NaN,0,NaN,NaN,NaN,0,0,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN;0,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN;0,NaN,NaN,0,0,0,0,0,0,NaN,NaN,0,NaN,NaN,NaN,NaN;0,NaN,NaN,0,0,0,0,0,0,NaN,NaN,0,NaN,NaN,NaN,NaN;0,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN;NaN,0,NaN,NaN,NaN,0,0,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN;NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,0,0,NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,0,0,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
CData(:,:,2)=[1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1;1,1,0,0,0.8,1,1,1,0,0,1,1,1,1,1,1;1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1;1,0,1,1,1,0,0,1,1,1,0,1,1,1,1,1;0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1;0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1;0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1;0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1;1,0,1,1,1,0,0,1,1,1,0,1,1,1,1,1;1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1;1,1,0,0,1,1,1,1,0,0,0,0,1,1,1,1;1,1,1,1,0,0,0,0,1,1,0,0,0,1,1,1;1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1;1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1;1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1;1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;];
CData(:,:,3)=[1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1;1,1,0,0,0.8,1,1,1,0,0,1,1,1,1,1,1;1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1;1,0,1,1,1,0,0,1,1,1,0,1,1,1,1,1;0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1;0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1;0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1;0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1;1,0,1,1,1,0,0,1,1,1,0,1,1,1,1,1;1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1;1,1,0,0,1,1,1,1,0,0,0.502,0.502,1,1,1,1;1,1,1,1,0,0,0,0,1,1,0.502,0.502,0.502,1,1,1;1,1,1,1,1,1,1,1,1,1,1,0.502,0.502,0.502,1,1;1,1,1,1,1,1,1,1,1,1,1,1,0.502,0.502,0.502,1;1,1,1,1,1,1,1,1,1,1,1,1,1,0.502,0.502,1;1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;];
hDataGui.ToolZoomIn=uitoggletool(hDataGui.ToolBar,'CData',CData,'TooltipString','Zoom','ClickedCallback','fDataGui(''bToolZoomIn'',getappdata(0,''hDataGui''));');

function bToolZoomIn(hDataGui)
set(hDataGui.ToolCursor,'State','off');
set(hDataGui.ToolPan,'State','off');
set(hDataGui.ToolZoomIn,'State','on');
zoom on
pan off

function [lXaxis,lYaxis]=CreatePlotList(Object,Type)
vel=CalcVelocity(Object);
%create list for X-Axis
n=4;
lXaxis.list{1}='X Position';
lXaxis.data{1}=Object.Results(:,3);
lXaxis.units{1}='[nm]';
lXaxis.list{2}='Time';
lXaxis.data{2}=Object.Results(:,2);
lXaxis.units{2}='[s]';
lXaxis.list{3}='Distance (Origin)';
lXaxis.data{3}=Object.Results(:,5);
lXaxis.units{3}='[nm]';
if isfield(Object,'NewResults')
    if ~isempty(Object.NewResults)
        lXaxis.list{n}='Distance (Path)';
        lXaxis.data{n}=Object.NewResults(:,5);
        lXaxis.units{n}='[nm]';
        n=n+1;
    end
end
lXaxis.list{n}='Histogram';
lXaxis.data{n}=[];

%create Y-Axis list for xy-plot
lYaxis(1).list{1}='Y Position';
lYaxis(1).data{1}=Object.Results(:,4);
lYaxis(1).units{1}='[nm]';

%create Y-Axis list for time plot
n=2;
lYaxis(2).list{1}='Distance (Origin)';
lYaxis(2).data{1}=Object.Results(:,5);
lYaxis(2).units{1}='[nm]';
if isfield(Object,'NewResults')
    if ~isempty(Object.NewResults)
        lYaxis(2).list{n}='Distance (Path)';
        lYaxis(2).data{n}=Object.NewResults(:,5);
        lYaxis(2).units{n}='[nm]';
        n=n+1;
    end
end
lYaxis(2).list{n}='Velocity';
lYaxis(2).data{n}=vel;
lYaxis(2).units{n}='[nm/s]';
n=n+1;
if strcmp(Type,'Molecule')==1
    lYaxis(2).list{n}='Amplitude';
    lYaxis(2).data{n}=Object.Results(:,7);
    lYaxis(2).units{n}='[ABU]';
    lYaxis(2).list{n+1}='Width (FWHM)';
    lYaxis(2).data{n+1}=Object.Results(:,6);
    lYaxis(2).units{n+1}='[nm]';    
    lYaxis(2).list{n+2}='Intensity (Volume)';
    lYaxis(2).data{n+2}=2*pi*Object.Results(:,6).^2.*Object.Results(:,7);       
    lYaxis(2).units{n+2}='[ABU]';        
    n=n+3;
else
    lYaxis(2).list{n}='Amplitude (mean)';
    lYaxis(2).data{n}=Object.Results(:,7);
    lYaxis(2).units{n}='[ABU]';        
    lYaxis(2).list{n+1}='Length';
    lYaxis(2).data{n+1}=Object.Results(:,6);       
    lYaxis(2).units{n+1}='[nm]';            
    n=n+2;
end

if isfield(Object,'NewResults')
    if ~isempty(Object.NewResults)
        lYaxis(2).list{n}='Sideways (Path)';
        lYaxis(2).data{n}=Object.NewResults(:,6);      
        lYaxis(2).units{n}='[nm]';    
        n=n+1;
    end
end

lYaxis(2).list{n}='X Position';
lYaxis(2).data{n}=Object.Results(:,3);
lYaxis(2).units{n}='[nm]';
lYaxis(2).list{n+1}='Y Position';
lYaxis(2).data{n+1}=Object.Results(:,4);   
lYaxis(2).units{n+1}='[nm]';
n=n+2;
if strcmp(Type,'Molecule')==1
    lYaxis(2).list{n}='radial error';
    lYaxis(2).data{n}=Object.Results(:,8);        
    lYaxis(2).units{n}='[nm]'; 
    n=n+1;
    if size(Object.Results,2)>11
        lYaxis(2).list{n}='Radius inner ring';
        lYaxis(2).data{n}=Object.Results(:,9);   
        lYaxis(2).units{n}='[nm]';        
        lYaxis(2).list{n+1}='Amplitude inner ring';
        lYaxis(2).data{n+1}=Object.Results(:,10);      
        lYaxis(2).units{n+1}='[ABU]';              
        lYaxis(2).list{n+2}='Width (FWHM) inner ring';    
        lYaxis(2).data{n+2}=Object.Results(:,11);      
        lYaxis(2).units{n+2}='[nm]';              
        lYaxis(2).list{n+3}='Radius outer ring';
        lYaxis(2).data{n+3}=Object.Results(:,12);      
        lYaxis(2).units{n+3}='[nm]';              
        lYaxis(2).list{n+4}='Amplitude outer ring';
        lYaxis(2).data{n+4}=Object.Results(:,13);      
        lYaxis(2).units{n+4}='[ABU]';                      
        lYaxis(2).list{n+5}='Width (FWHM) outer ring';        
        lYaxis(2).data{n+5}=Object.Results(:,14);     
        lYaxis(2).units{n+5}='[nm]';              
    else
        if size(Object.Results,2)>8
            lYaxis(2).list{n}='Radius ring';
            lYaxis(2).data{n}=Object.Results(:,9);      
            lYaxis(2).units{n}='[nm]';                    
            lYaxis(2).list{n+1}='Amplitude ring';
            lYaxis(2).data{n+1}=Object.Results(:,10);                
            lYaxis(2).units{n+1}='[ABU]';                    
            lYaxis(2).list{n+2}='Width (FWHM) ring';   
            lYaxis(2).data{n+2}=Object.Results(:,11);                
            lYaxis(2).units{n+2}='[nm]';                    
        end
    end
end

%create Y-Axis list for distance plot
lYaxis(3)=lYaxis(2);
lYaxis(3).list(1)=[];
lYaxis(3).data(1)=[];
lYaxis(3).units(1)=[];
n=4;
if isfield(Object,'NewResults')
    if ~isempty(Object.NewResults)
        lYaxis(3).list(1)=[];
        lYaxis(3).data(1)=[];
        lYaxis(3).units(1)=[];
        lYaxis(4)=lYaxis(3);
        n=5;
    end
end

%create list for histograms
lYaxis(n).list{1}='Velocity';
lYaxis(n).units{1}='[nm/s]';
lYaxis(n).data{1}=[];

lYaxis(n).list{2}='Pairwise-Distance';
lYaxis(n).units{2}='[nm]';
lYaxis(n).data{2}=[];
k=3;
if isfield(Object,'NewResults')
    if ~isempty(Object.NewResults)
        lYaxis(n).list{k}='Pairwise-Distance (Path)';
        lYaxis(n).data{k}=[];
        lYaxis(n).units{k}='[nm]';
        k=k+1;
    end
end

lYaxis(n).list{k}='Amplitude';
lYaxis(n).units{k}='[ABU]';
lYaxis(n).data{k}=[];
if strcmp(Type,'Molecule')==1
    lYaxis(n).list{k+1}='Intensity (Volume)';
    lYaxis(n).units{k+1}='[ABU]';
    lYaxis(n).data{k+1}=[];
else
    lYaxis(n).list{k+1}='Length';
    lYaxis(n).units{k+1}='[nm]';
    lYaxis(n).data{k+1}=[];
end

function CreateHistograms(hDataGui)
Object=getappdata(hDataGui.fig,'Object');
lYaxis=get(hDataGui.lYaxis,'UserData');
vel=CalcVelocity(Object);
n=length(lYaxis);
barchoice=[1 2 4 5 10 20 25 50 100 200 250 500 1000 2000 5000 10000 50000 10^5 10^6 10^7 10^8];

total=(max(vel)-min(vel))/15;
[m,t]=min(abs(total-barchoice));
barwidth=barchoice(t(1));
x=fix(min(vel)/barwidth)*barwidth-barwidth:barwidth:ceil(max(vel)/barwidth)*barwidth+barwidth;
num = hist(vel,x);
lYaxis(n).data{1}=[x' num']; 

XPos=Object.Results(:,3);
YPos=Object.Results(:,4);
pairwise=zeros(length(XPos));
for i=1:length(XPos)
    pairwise(:,i)=sqrt((XPos-XPos(i)).^2 + (YPos-YPos(i)).^2);
end
p=tril(pairwise,-1);
pairwise=p(p>1);
x=round(min(pairwise)-10):1:round(max(pairwise)+10);
num = hist(pairwise,x);
lYaxis(n).data{2}=[x' num']; 
k=3;
if isfield(Object,'NewResults')
    if ~isempty(Object.NewResults)
        Dis=Object.NewResults(:,5);
        pairwise=zeros(length(Dis));
        for i=1:length(Dis)
            pairwise(:,i)=Dis-Dis(i);
        end
        p=tril(pairwise,-1);
        pairwise=p(p>1);
        x=round(min(pairwise)-10):1:round(max(pairwise)+10);
        num = hist(pairwise,x);
        lYaxis(n).data{k}=[x' num']; 
    end
end

Amp=Object.Results(:,7);
total=(max(Amp)-min(Amp))/15;
[m,t]=min(abs(total-barchoice));
barwidth=barchoice(t(1));
x=fix(min(Amp)/barwidth)*barwidth-barwidth:barwidth:ceil(max(Amp)/barwidth)*barwidth+barwidth;
num = hist(Amp,x);
lYaxis(n).data{k}=[x' num'];

if strcmp(hDataGui.Type,'Molecule')==1
    Int=2*pi*Object.Results(:,6).^2.*Object.Results(:,7);
    total=(max(Int)-min(Int))/15;
    [m,t]=min(abs(total-barchoice));
    barwidth=barchoice(t(1));
    x=fix(min(Int)/barwidth)*barwidth-barwidth:barwidth:ceil(max(Int)/barwidth)*barwidth+barwidth;
    num = hist(Int,x);
    lYaxis(n).data{k+1}=[x' num'];
else
    Len=Object.Results(:,6);
    total=(max(Len)-min(Len))/15;
    [m,t]=min(abs(total-barchoice));
    barwidth=barchoice(t(1));
    x=fix(min(Len)/barwidth)*barwidth-barwidth:barwidth:ceil(max(Len)/barwidth)*barwidth+barwidth;
    num = hist(Len,x);
    lYaxis(n).data{k+1}=[x' num'];
end
set(hDataGui.lYaxis,'UserData',lYaxis);


function XAxisList(hDataGui)
x=get(hDataGui.lXaxis,'Value');
y=get(hDataGui.lYaxis,'Value');
y2=get(hDataGui.lYaxis2,'Value');
s=get(hDataGui.lXaxis,'UserData');
a=get(hDataGui.lYaxis,'UserData');
enable='off';
enable2='off';
if x>1 && x<length(s.list)
    enable='on';
    if get(hDataGui.cYaxis2,'Value')==1
        enable2='on';
    end
end
if length(a(x).list)<y
    set(hDataGui.lYaxis,'Value',1);
end
if length(a(x).list)<y2
    set(hDataGui.lYaxis2,'Value',1);
end    
set(hDataGui.lYaxis,'String',a(x).list);
set(hDataGui.lYaxis2,'String',a(x).list);
set(hDataGui.cYaxis2,'Enable',enable);
set(hDataGui.tYaxis2,'Enable',enable2);
set(hDataGui.lYaxis2,'Enable',enable2);
if x==length(s.list) && isempty(a(x).data{1});
    CreateHistograms(hDataGui);
end
Draw(hDataGui,0);

function CheckYAxis2(hDataGui)
c=get(hDataGui.cYaxis2,'Value');
enable='off';
if c==1
    enable='on';
end
set(hDataGui.tYaxis2,'Enable',enable);
set(hDataGui.lYaxis2,'Enable',enable);
Draw(hDataGui,0);

function vel=CalcVelocity(Object)
nData=size(Object.Results,1);
if nData>1
    vel=zeros(nData,1);
    vel(1)=sqrt( (Object.Results(1,3)-(Object.Results(2,3)))^2 +...
                 (Object.Results(1,4)-(Object.Results(2,4)))^2)/...
                 (Object.Results(2,2)-(Object.Results(1,2)));
    vel(nData)=sqrt((Object.Results(nData,3)-(Object.Results(nData-1,3)))^2 +...
                    (Object.Results(nData,4)-(Object.Results(nData-1,4)))^2)/...
                    (Object.Results(nData,2)-(Object.Results(nData-1,2)));
    for i=2:nData-1
       vel(i)=(sqrt( (Object.Results(i,3)-(Object.Results(i-1,3)))^2 +...
                     (Object.Results(i,4)-(Object.Results(i-1,4)))^2)+...
               sqrt( (Object.Results(i+1,3)-(Object.Results(i,3)))^2 +...
                     (Object.Results(i+1,4)-(Object.Results(i,4)))^2))/...                    
                     (Object.Results(i+1,2)-(Object.Results(i-1,2)));
    end
else
    vel=0;
end