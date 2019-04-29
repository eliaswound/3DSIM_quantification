function fExportViewGui(func,varargin)
switch func
    case 'Create'
        Create;
    case 'UpdateMoviePanel'
        UpdateMoviePanel(varargin{1});
    case 'UpdateView'
        UpdateView(varargin{1});
    case 'FirstFrame'
        FirstFrame(varargin{1});
    case 'LastFrame'
        LastFrame(varargin{1});        
    case 'BarSize'
        BarSize(varargin{1});        
    case 'Close'
        Close(varargin{1});               
    case 'Export'
        Export(varargin{1});   
    case 'SetRes'
        SetRes(varargin{1});           
end

function Create
h=findobj('Tag','hExportViewGui');
close(h)

hMainGui=getappdata(0,'hMainGui');

PixSize=hMainGui.Values.PixSize;
xy=hMainGui.ZoomView.currentXY;
x_total=xy{1}(2)-xy{1}(1);
y_total=xy{2}(2)-xy{2}(1);

hExportViewGui.fig = figure('Units','normalized','WindowStyle','modal','DockControls','off','IntegerHandle','off','MenuBar','none','Name','Export',...
                      'NumberTitle','off','Position',[0.75 0.25 0.25 0.5],'HandleVisibility','callback','Tag','hExportViewGui',...
                      'Visible','on','Resize','off','Color',[0.9255 0.9137 0.8471]);
                  
hExportViewGui.pRange = uibuttongroup('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.81 0.9 0.175],...
                                  'Title','Range','Tag','tRange','FontSize',10,'SelectionChangeFcn',@RangeSelect);                  
                                  
hExportViewGui.rCurrentView = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.05 0.7 0.6 0.275],'Enable','on','FontSize',10,...
                                    'String','Current View (JPG)','Style','radiobutton','Tag','rCurrentView','HorizontalAlignment','left');
                                
hExportViewGui.rWholeStack = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.05 0.375 0.6 0.275],'Enable','on','FontSize',10,...
                                    'String','Whole Stack (AVI)','Style','radiobutton','Tag','rWholeStack','HorizontalAlignment','left');  
                                
hExportViewGui.rSelection = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.05 0.05 0.5 0.275],'Enable','on','FontSize',10,...
                                    'String','Selection (AVI)','Style','radiobutton','Tag','rWholeStack','HorizontalAlignment','left');  

hExportViewGui.tResolution = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.61 0.85 0.29 0.2],'Enable','on','FontSize',10,...
                                'String','Resolution','Style','text','Tag','tResolution ','HorizontalAlignment','center');                 
                            
XRes=640;
YRes=640;
if x_total/y_total<1
    XRes=(640*x_total^2/y_total^2);
end
if y_total/x_total<1
    YRes=(640*y_total^2/x_total^2);
end

hExportViewGui.eXRes = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.56 0.575 0.15 0.275],'Enable','on','FontSize',10,...
                                'String',num2str(round(XRes)),'Style','edit','Tag','eXRes','HorizontalAlignment','center','BackgroundColor','white',...
                                'Callback','fExportViewGui(''SetRes'',getappdata(0,''hExportViewGui''));','UserData',y_total^2/x_total^2);         

hExportViewGui.tX = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.73 0.575 0.05 0.275],'Enable','on','FontSize',10,...
                                'String','x','Style','text','Tag','tX','HorizontalAlignment','center');                                                                                         
                            
hExportViewGui.eYRes = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.8 0.575 0.15 0.275],'Enable','on','FontSize',10,...
                                'String',num2str(round(YRes)),'Style','edit','Tag','eYRes','HorizontalAlignment','center',...
                                'BackgroundColor','white','Callback','fExportViewGui(''SetRes'',getappdata(0,''hExportViewGui''));','UserData',x_total^2/y_total^2);        
                            
hExportViewGui.tFrames = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.61 0.35 0.29 0.2],'Enable','off','FontSize',10,...
                                'String','Frames','Style','text','Tag','tFrames','HorizontalAlignment','center');                 
                            
hExportViewGui.eFirst = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.56 0.05 0.15 0.275],'Enable','off','FontSize',10,...
                                'String','1','Style','edit','Tag','eFirst','HorizontalAlignment','center','BackgroundColor','white',...
                                'Callback','fExportViewGui(''FirstFrame'',getappdata(0,''hExportViewGui''));');         

hExportViewGui.tTo = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.73 0.05 0.05 0.275],'Enable','off','FontSize',10,...
                                'String','-','Style','text','Tag','tTo','HorizontalAlignment','center');                                                                                         
                            
hExportViewGui.eLast = uicontrol('Parent',hExportViewGui.pRange,'Units','normalized','Position',[0.8 0.05 0.15 0.275],'Enable','off','FontSize',10,...
                                'String',num2str(hMainGui.Values.MaxIdx),'Style','edit','Tag','eLast','HorizontalAlignment','center',...
                                'BackgroundColor','white','Callback','fExportViewGui(''LastFrame'',getappdata(0,''hExportViewGui''));');                         
                            
hExportViewGui.cScale = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.1 0.745 0.3 0.04],'Enable','on','FontSize',10,...
                                    'String','Scale Bar','Style','checkbox','Tag','cScale','HorizontalAlignment','left',...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');        

hExportViewGui.tPosBar = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.45 0.745 0.2 0.035],'Enable','off','FontSize',10,...
                                    'String','Position:','Style','text','Tag','tPosBar','HorizontalAlignment','left');                                      
                                
hExportViewGui.mPosBar = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.65 0.75 0.3 0.04],'Enable','off','FontSize',10,...
                                    'String',{'top left','top right','bottom left','bottom right'},'Value',4,'Style','popupmenu','Tag','mPosBar',...
                                    'BackgroundColor','white','Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');                
                                
hExportViewGui.tBarSize = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.2 0.69 0.15 0.04],'Enable','off','FontSize',10,...
                                    'String','Size:','Style','text','Tag','tBarSize');     

BarSize=x_total*0.2*PixSize/1000;

if BarSize>5
   BarSize=round(BarSize/5)*5;
elseif BarSize>0.5
   BarSize=ceil(BarSize);
else
   BarSize=ceil(BarSize*10)/10;
end

hExportViewGui.eBarSize = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.36 0.69 0.14 0.04],'Enable','off','FontSize',10,...
                                'String',num2str(BarSize),'Style','edit','Tag','eBarSize','BackgroundColor','white',...
                                'Callback','fExportViewGui(''BarSize'',getappdata(0,''hExportViewGui''));');        

hExportViewGui.tUm = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.51 0.69 0.1 0.04],'Enable','off','FontSize',10,...
                                    'String','µm','Style','text','Tag','tUm','HorizontalAlignment','left');      

hExportViewGui.cTime = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.1 0.635 0.3 0.04],'Enable','off','FontSize',10,...
                                    'String','Time Stamp','Style','checkbox','Tag','cTime','HorizontalAlignment','left',...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');        
                                
hExportViewGui.tPosTime = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.45 0.635 0.2 0.035],'Enable','off','FontSize',10,...
                                    'String','Position:','Style','text','Tag','tPosBar','HorizontalAlignment','left');                                      
                                
hExportViewGui.mPosTime = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.65 0.64 0.3 0.04],'Enable','off','FontSize',10,...
                                    'String',{'top left','top right','bottom left','bottom right'},'Value',3,'Style','popupmenu','Tag','mPosBar',...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));','BackgroundColor','white');                                        
                                
hExportViewGui.cShowVisible = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.1 0.56 0.8 0.04],'Enable','on','FontSize',10,...
                                    'String','Show Visible Tracks','Style','checkbox','Tag','cShowVisible','HorizontalAlignment','left','Value',1,...
                                     'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');        

hExportViewGui.cMolMarker = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.1 0.51 0.8 0.04],'Enable','on','FontSize',10,...
                                    'String','Show all Molecules ( + marker)','Style','checkbox','Tag','cMolMarker','HorizontalAlignment','left',...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');        
                                
hExportViewGui.cFilMarker = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.1 0.46 0.8 0.04],'Enable','on','FontSize',10,...
                                    'String','Show all Filaments ( x marker)','Style','checkbox','Tag','cFilMarker','HorizontalAlignment','left',...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');        
                                
hExportViewGui.cWholeFil = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.2 0.41 0.7 0.04],'Enable','off','FontSize',10,...
                                    'String','Show Filament Positions','Style','checkbox','Tag','cWholeFil','HorizontalAlignment','left',...
                                    'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');
                                
hExportViewGui.cAddArrow = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.1 0.35 0.8 0.04],'Enable','on','FontSize',10,...
                                 'String','Add Arrow for Selected Tracks','Style','checkbox','Tag','cAddArrow ','HorizontalAlignment','left',...
                                 'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');        
                                
hExportViewGui.cAddName = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.2 0.3 0.7 0.04],'Enable','off','FontSize',10,...
                                'String','Add Name for Selected Tracks','Style','checkbox','Tag','cAddName','HorizontalAlignment','left',...
                                'Callback','fExportViewGui(''UpdateView'',getappdata(0,''hExportViewGui''));');        
                       
hExportViewGui.pMovie = uipanel('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.08 0.9 0.21],...
                            'Title','Movie','Tag','tMovie','FontSize',10);          
  
hExportViewGui.tCompression = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.05 0.755 0.3 0.2],'Enable','off','FontSize',10,...
                                    'String','Compression:','Style','text','Tag','tPosBar','HorizontalAlignment','left');                                      
                                
hExportViewGui.mCompression = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.375 0.76 0.4 0.25],'Enable','off','FontSize',10,...
                                    'String',{'None','Indeo1','Indeo5','Cinepak','MSVC','RLE'},'Value',1,'Style','popupmenu','Tag','mPosBar',...
                                    'BackgroundColor','white','Callback','fExportViewGui(''UpdateMoviePanel'',getappdata(0,''hExportViewGui''));');         
                                
hExportViewGui.bMore= uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.8 0.73 0.175 0.28],'Enable','off','FontSize',10,...
                              'String','more','Style','pushbutton','Tag','bMore');   
                                
hExportViewGui.tFPS = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.05 0.38 0.2 0.22],'Enable','off','FontSize',10,...
                                    'String','frames/s:','Style','text','Tag','tFPS','HorizontalAlignment','left');                                 

hExportViewGui.eFPS = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.275 0.4 0.15 0.22],'Enable','off','FontSize',10,...
                                    'String','15','Style','edit','Tag','eFPS','BackgroundColor','white');                                  
                                
hExportViewGui.tKFPS = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.5 0.38 0.275 0.22],'Enable','off','FontSize',10,...
                                    'String','keyframes/s:','Style','text','Tag','tFPS','HorizontalAlignment','left'); 
                                
hExportViewGui.eKFPS = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.8 0.4 0.15 0.22],'Enable','off','FontSize',10,...
                                    'String','2','Style','edit','Tag','eKFPS','BackgroundColor','white');           
                                
hExportViewGui.tQuality = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.05 0.05 0.2 0.22],'Enable','off','FontSize',10,...
                                    'String','Quality:','Style','text','Tag','tQuality','HorizontalAlignment','left'); 
    
hExportViewGui.sQuality = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.275 0.05 0.5 0.22],'Enable','off',...
                                'min',1,'max',100,'Value',75,'SliderStep',[0.01 0.1],'Style','slider','Tag','sQuality'); 
                                
hExportViewGui.eQuality = uicontrol('Parent',hExportViewGui.pMovie,'Units','normalized','Position',[0.8 0.05 0.15 0.22],'Enable','off','FontSize',10,...
                                    'String','75','Style','edit','Tag','eQuality ','BackgroundColor','white');                                    
                              
hExportViewGui.bOK = uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.05 0.015 0.4 0.05],'Enable','on','FontSize',10,...
                                    'String','OK','Style','pushbutton','Tag','bOK','Callback','fExportViewGui(''Export'',getappdata(0,''hExportViewGui''));');

hExportViewGui.bCancel= uicontrol('Parent',hExportViewGui.fig,'Units','normalized','Position',[0.55 0.015 0.4 0.05],'Enable','on','FontSize',10,...
                              'String','Cancel','Style','pushbutton','Tag','bCancel','Callback','fExportViewGui(''Close'',getappdata(0,''hExportViewGui''));');                

set(hExportViewGui.fig,'CloseRequestFcn',@CloseExportGui);

hExportViewGui.Bar=rectangle('Parent',hMainGui.MidPanel.aView,'Position',CalcBar(hExportViewGui,hMainGui),'EdgeColor','none','FaceColor','white','Visible','off');

hExportViewGui.BarLabel=text('Parent',hMainGui.MidPanel.aView,'Position',CalcBarLabel(hExportViewGui,hMainGui),'HorizontalAlignment','center','Color','white',...
                         'String',sprintf('%g µm',BarSize),'Visible','off','FontUnits','normalized','FontSize',0.03,'FontWeight','bold');
                     
hExportViewGui.TimeStamp=text('Parent',hMainGui.MidPanel.aView,'Position',CalcTimeStamp(hExportViewGui,hMainGui),'HorizontalAlignment','center','Color','white',...
                         'String',sprintf('%4.0f s',0),'Visible','off','FontUnits','normalized','FontSize',0.04,'FontWeight','bold');

hBackup=hMainGui;
hShow.cMolMarker=get(hMainGui.RightPanel.pData.cShowAllMol,'Value');
hShow.cFilMarker=get(hMainGui.RightPanel.pData.cShowAllFil,'Value');
hShow.cWholeFil=get(hMainGui.RightPanel.pData.cShowWholeFil,'Value');
set(hExportViewGui.cMolMarker,'Value',hShow.cMolMarker);
set(hExportViewGui.cFilMarker,'Value',hShow.cFilMarker);
set(hExportViewGui.cWholeFil,'Value',hShow.cWholeFil);
hExportViewGui.Arrows=[];
hExportViewGui.Names=[];
hExportViewGui.ResFactor=1;
if hShow.cFilMarker
    set(hExportViewGui.cWholeFil,'Enable','on');
end
setappdata(0,'hExportViewGui',hExportViewGui);
setappdata(hExportViewGui.fig,'hBackup',hBackup);
setappdata(hExportViewGui.fig,'hShow',hShow);
UpdateView(hExportViewGui);

function Close(hExportViewGui)
close(hExportViewGui.fig);

function CloseExportGui(hObject,evnt) %#ok<INUSD>
hExportViewGui=getappdata(0,'hExportViewGui');
hBackup=getappdata(hExportViewGui.fig,'hBackup');
hMainGui=getappdata(0,'hMainGui');
hShow=getappdata(hExportViewGui.fig,'hShow');
set(hMainGui.RightPanel.pData.cShowAllMol,'Value',hShow.cMolMarker);
set(hMainGui.RightPanel.pData.cShowAllFil,'Value',hShow.cFilMarker);
set(hMainGui.RightPanel.pData.cShowWholeFil,'Value',hShow.cWholeFil);
set(hMainGui.MidPanel.aView,'Units','normalized','Position',[0 0 1 1]);
hMainGui=hBackup;
delete(hExportViewGui.fig);
delete(hExportViewGui.Bar);
delete(hExportViewGui.BarLabel);
delete(hExportViewGui.TimeStamp);
delete(hExportViewGui.Arrows);
delete(hExportViewGui.Names);
setappdata(0,'hMainGui',hMainGui);
fShow('Image');
fShow('Tracks');
                      
function RangeSelect(hObject,evnt)      %#ok<INUSD>
hExportViewGui=getappdata(0,'hExportViewGui');
hMainGui=getappdata(0,'hMainGui');
enable='off';
if get(hExportViewGui.rSelection,'Value')
    enable='on';
end
set(hExportViewGui.tFrames,'Enable',enable);
set(hExportViewGui.eFirst,'Enable',enable);
set(hExportViewGui.tTo,'Enable',enable);
set(hExportViewGui.eLast,'Enable',enable);
if get(hExportViewGui.rCurrentView,'Value')
    set(get(hExportViewGui.pMovie,'Children'),'Enable','off');
    set(get(hExportViewGui.pMovie,'Children'),'Enable','off');
    set(get(hExportViewGui.pMovie,'Children'),'Enable','off');
    hBackup=getappdata(hExportViewGui.fig,'hBackup');
    hMainGui.Values.FrameIdx=hBackup.Values.FrameIdx;
    enable='off';
else
    if get(hExportViewGui.rSelection,'Value')
        hMainGui.Values.FrameIdx=str2double(get(hExportViewGui.eFirst,'String'));
    else
        hMainGui.Values.FrameIdx=1;
    end
    UpdateMoviePanel(hExportViewGui);
    enable='on';
end
set(hExportViewGui.cTime,'Enable',enable);
setappdata(0,'hMainGui',hMainGui);
fShow('Image');
UpdateView(hExportViewGui);

function FirstFrame(hExportViewGui)      %#ok<INUSD>
hMainGui=getappdata(0,'hMainGui');
idx=str2double(get(hExportViewGui.eFirst,'String'));
if ~isnan(idx)
    if idx>0&&idx<=hMainGui.Values.MaxIdx
        hMainGui.Values.FrameIdx=str2double(get(hExportViewGui.eFirst,'String'));
        setappdata(0,'hMainGui',hMainGui);
        fShow('Image');
        UpdateView(hExportViewGui);
    else
        set(hExportViewGui.eFirst,'String',1);
    end
else
    set(hExportViewGui.eFirst,'String',1);
end

function LastFrame(hExportViewGui)      %#ok<INUSD>
hMainGui=getappdata(0,'hMainGui');
idx=str2double(get(hExportViewGui.eLast,'String'));
if ~isnan(idx)
    if idx<=0||idx>hMainGui.Values.MaxIdx
        set(hExportViewGui.eLast,'String',hMainGui.Values.MaxIdx);
    end
else
    set(hExportViewGui.eLast,'String',hMainGui.Values.MaxIdx);
end

function SetRes(hExportViewGui)      %#ok<INUSD>
XRes=str2double(get(hExportViewGui.eXRes,'String'));
XFactor=get(hExportViewGui.eXRes,'UserData');
YRes=str2double(get(hExportViewGui.eYRes,'String'));
YFactor=get(hExportViewGui.eYRes,'UserData');
if gcbo==hExportViewGui.eXRes
    if ~isnan(XRes)
        if XRes<1
            set(hExportViewGui.eXRes,'String',num2str(round(YRes*YFactor)));
        end
    else
        set(hExportViewGui.eXRes,'String',num2str(round(YRes*YFactor)));
    end
    XRes=str2double(get(hExportViewGui.eXRes,'String'));
    set(hExportViewGui.eYRes,'String',num2str(round(XRes*XFactor)));
else
    if ~isnan(YRes)
        if YRes<1
            set(hExportViewGui.eYRes,'String',num2str(round(XRes*XFactor)));
        end
    else
        set(hExportViewGui.eYRes,'String',num2str(round(XRes*XFactor)));
    end
    YRes=str2double(get(hExportViewGui.eYRes,'String'));
    set(hExportViewGui.eXRes,'String',num2str(round(YRes*YFactor)));    
end
        
function UpdateMoviePanel(hExportViewGui)
index=get(gcbo,'Value');
if index==1
    set(get(hExportViewGui.pMovie,'Children'),'Enable','off');
end
set(hExportViewGui.tCompression,'Enable','on');
set(hExportViewGui.mCompression,'Enable','on');
set(hExportViewGui.bMore,'Enable','on');
set(hExportViewGui.tFPS,'Enable','on');
set(hExportViewGui.eFPS,'Enable','on');

function ShowVisible(Object,Visible)
pTrack=[Object.pTrack];
pTrackSelectW=[Object.pTrackSelectW];
pTrackSelectB=[Object.pTrackSelectB];
set(pTrack(Visible==1),'Visible','on');
set(pTrack(Visible==0),'Visible','off');
set(pTrackSelectW,'Visible','off');
set(pTrackSelectB,'Visible','off');

function UpdateView(hExportViewGui)
global Molecule;
global Filament;
global Objects;
global StackInfo;
hMainGui=getappdata(0,'hMainGui');
set(hExportViewGui.cAddArrow,'Enable','off');    
if ~isempty(Molecule)
    if max([Molecule.Visible])==1
        set(hExportViewGui.cShowVisible,'Enable','on');    
    end
     if max([Molecule.Selected])==1
        set(hExportViewGui.cAddArrow,'Enable','on');             
     end
end
if ~isempty(Filament)
    if max([Filament.Visible])==1
        set(hExportViewGui.cShowVisible,'Enable','on');    
    end
     if max([Filament.Selected])==1
        set(hExportViewGui.cAddArrow,'Enable','on');                      
     end
end
if isempty(Molecule)&&isempty(Filament)
    set(hExportViewGui.cShowVisible,'Enable','off','Value',0);        
end
if isempty(Objects)
    set(hExportViewGui.cMolMarker,'Enable','off','Value',0);    
    set(hExportViewGui.cFilMarker,'Enable','off','Value',0);    
else
    set(hMainGui.RightPanel.pData.cShowAllMol,'Value',get(hExportViewGui.cMolMarker,'Value'));
    set(hMainGui.RightPanel.pData.cShowAllFil,'Value',get(hExportViewGui.cFilMarker,'Value'));
end
if get(hExportViewGui.cFilMarker,'Value')
    set(hExportViewGui.cWholeFil,'Enable','on');
    set(hMainGui.RightPanel.pData.cShowWholeFil,'Value',get(hExportViewGui.cWholeFil,'Value'));
else
    set(hExportViewGui.cWholeFil,'Enable','off');    
end
setappdata(0,'hMainGui',hMainGui);
fShow('Marker',hMainGui,hMainGui.Values.FrameIdx);
if get(hExportViewGui.cShowVisible,'Value')
    ShowVisible(Molecule,[Molecule.Visible]);
    ShowVisible(Filament,[Filament.Visible]);    
else
    ShowVisible(Molecule,zeros(1,length(Molecule)));
    ShowVisible(Filament,zeros(1,length(Filament)));
    delete(findobj('Tag','pObjects','-and','Marker','.'));
    delete(findobj('Tag','pObjects','-and','Marker','o'));    
end
if get(hExportViewGui.cScale,'Value')
    set(hExportViewGui.Bar,'Position',CalcBar(hExportViewGui,hMainGui),'Visible','on');
    set(hExportViewGui.BarLabel,'Position',CalcBarLabel(hExportViewGui,hMainGui),'Visible','on');    
    uistack(hExportViewGui.Bar,'top');    
    uistack(hExportViewGui.BarLabel,'top');      
    set(hExportViewGui.tPosBar,'Enable','on');
    set(hExportViewGui.mPosBar,'Enable','on');
    set(hExportViewGui.tBarSize,'Enable','on');
    set(hExportViewGui.eBarSize,'Enable','on');    
    set(hExportViewGui.tUm,'Enable','on');    

else
    set(hExportViewGui.Bar,'Visible','off');
    set(hExportViewGui.BarLabel,'Visible','off');    
    set(hExportViewGui.tPosBar,'Enable','off');
    set(hExportViewGui.mPosBar,'Enable','off');
    set(hExportViewGui.tBarSize,'Enable','off');
    set(hExportViewGui.eBarSize,'Enable','off');        
    set(hExportViewGui.tUm,'Enable','off');      
end
if get(hExportViewGui.cTime,'Value')&&strcmp(get(hExportViewGui.cTime,'Enable'),'on')&&~get(hExportViewGui.rCurrentView,'Value')
    if get(hExportViewGui.mPosTime,'Value')==get(hExportViewGui.mPosBar,'Value')
        if get(hExportViewGui.mPosTime,'Value')==1||get(hExportViewGui.mPosTime,'Value')==3
            set(hExportViewGui.mPosTime,'Value',get(hExportViewGui.mPosTime,'Value')+1);
        else
            set(hExportViewGui.mPosTime,'Value',get(hExportViewGui.mPosTime,'Value')-1);            
        end
    end
    first=1;
    if get(hExportViewGui.rSelection,'Value')    
        first=str2double(get(hExportViewGui.eFirst,'String'));
    end
    time=(StackInfo.CreationTime(hMainGui.Values.FrameIdx)-StackInfo.CreationTime(first))/1000;
    set(hExportViewGui.TimeStamp,'Position',CalcTimeStamp(hExportViewGui,hMainGui),'Visible','on','String',sprintf('%4.0f s',time));
    uistack(hExportViewGui.TimeStamp,'top');
    set(hExportViewGui.tPosTime,'Enable','on');
    set(hExportViewGui.mPosTime,'Enable','on');    
else
    set(hExportViewGui.TimeStamp,'Visible','off');
    set(hExportViewGui.tPosTime,'Enable','off');
    set(hExportViewGui.mPosTime,'Enable','off');        
end
if get(hExportViewGui.cAddArrow,'Value')
    set(hExportViewGui.cAddName,'Enable','on');        
    AddArrow(hExportViewGui,hMainGui);
else
    set(hExportViewGui.cAddName,'Enable','off');        
    delete(hExportViewGui.Arrows);
    hExportViewGui.Arrows=[];
    delete(hExportViewGui.Names);
    hExportViewGui.Names=[];
    setappdata(0,'hExportViewGui',hExportViewGui);
end

function BarSize(hExportViewGui)
hMainGui=getappdata(0,'hMainGui');
value=str2double(get(hExportViewGui.eBarSize,'String'));
PixSize=hMainGui.Values.PixSize;
xy=hMainGui.ZoomView.currentXY;
x_total=xy{1}(2)-xy{1}(1);
if value<=0||value>x_total*0.5*PixSize/1000
    value=x_total*0.2*PixSize/1000;
    if Size>5
        value=round(value/5)*5;
    else
        value=ceil(value);
    end        
end
set(hExportViewGui.eBarSize,'String',num2str(value));
set(hExportViewGui.BarLabel,'String',sprintf('%g µm',value));
UpdateView(hExportViewGui);

function position=CalcBar(hExportViewGui,hMainGui)                               
PixSize=hMainGui.Values.PixSize;
xy=hMainGui.ZoomView.currentXY;
x_total=xy{1}(2)-xy{1}(1);
y_total=xy{2}(2)-xy{2}(1); 
width=str2double(get(hExportViewGui.eBarSize,'String'))*1000/PixSize;
height=0.02*y_total;
if get(hExportViewGui.mPosBar,'Value')==1||get(hExportViewGui.mPosBar,'Value')==3
    x=xy{1}(1)+0.05*x_total;
else
    x=xy{1}(2)-0.05*x_total-width;
end
if get(hExportViewGui.mPosBar,'Value')==1||get(hExportViewGui.mPosBar,'Value')==2
    y=xy{2}(1)+0.05*y_total;
else
    y=xy{2}(2)-0.05*y_total-height;
end          
position=[x y width height];

function position=CalcBarLabel(hExportViewGui,hMainGui)                               
PixSize=hMainGui.Values.PixSize;
xy=hMainGui.ZoomView.currentXY;
x_total=xy{1}(2)-xy{1}(1);
y_total=xy{2}(2)-xy{2}(1); 
width=str2double(get(hExportViewGui.eBarSize,'String'))*1000/PixSize;
height=0.02*y_total;
if get(hExportViewGui.mPosBar,'Value')==1||get(hExportViewGui.mPosBar,'Value')==3
    x=xy{1}(1)+0.05*x_total+width/2;
else
    x=xy{1}(2)-0.05*x_total-width/2;
end
if get(hExportViewGui.mPosBar,'Value')==1||get(hExportViewGui.mPosBar,'Value')==2
    y=xy{2}(1)+0.075*y_total+height;
else
    y=xy{2}(2)-0.075*y_total-height;
end          
position=[x y];

function position=CalcTimeStamp(hExportViewGui,hMainGui)                               
xy=hMainGui.ZoomView.currentXY;
x_total=xy{1}(2)-xy{1}(1);
y_total=xy{2}(2)-xy{2}(1); 
if get(hExportViewGui.mPosTime,'Value')==1||get(hExportViewGui.mPosTime,'Value')==3
    x=xy{1}(1)+0.1*x_total;
else
    x=xy{1}(2)-0.1*x_total;
end
if get(hExportViewGui.mPosTime,'Value')==1||get(hExportViewGui.mPosTime,'Value')==2
    y=xy{2}(1)+0.075*y_total;
else
    y=xy{2}(2)-0.075*y_total;
end          
position=[x y];

function AddArrow(hExportViewGui,hMainGui)
global Molecule;
global Filament;
xy=get(hMainGui.MidPanel.aView,{'XLim','YLim'});
pos=get(hMainGui.MidPanel.aView,'Position');
x_total=xy{1}(2)-xy{1}(1);
y_total=xy{2}(2)-xy{2}(1);
if ~isempty(hExportViewGui.Arrows)
    delete(hExportViewGui.Arrows);
    hExportViewGui.Arrows=[];
end
MapMol=struct('Name',{},'PosX',{},'PosY',{},'OrientationX',{},'OrientationY',{});
MapFil=struct('Name',{},'PosX',{},'PosY',{},'OrientationX',{},'OrientationY',{});
if ~isempty(Molecule)
    k=find([Molecule.Selected]==1);
    if ~isempty(k)
        MapMol=CreateMap(Molecule(k),hMainGui);
    end
end
if  ~isempty(Filament)
    k=find([Filament.Selected]==1);
    if ~isempty(k)
        MapFil=CreateMap(Filament(k),hMainGui);
    end
end
Map=[MapMol MapFil];
X=[Map.PosX];
Y=[Map.PosY];
U=mean([Map.OrientationX])*ones(size(X));
V=mean([Map.OrientationY])*ones(size(Y));
O=x_total*0.005/pos(3)+y_total*0.005/pos(4);
S=x_total*0.02/pos(3)+y_total*0.02/pos(4);
X1 = X + U*(O+S);
Y1 = Y + V*(O+S);
X2 = X - U*(O+S);
Y2 = Y - V*(O+S);
for n=1:length(Map)
    if (X1(n)-xy{1}(1))<0.2*x_total || (xy{1}(2)-X1(n))<0.2*x_total || (X2(n)-xy{1}(1))<0.2*x_total || (xy{1}(2)-X2(n))<0.2*x_total
        [m,c]=min([X1(n)-xy{1}(1) xy{1}(2)-X1(n) X2(n)-xy{1}(1) xy{1}(2)-X2(n)]); 
        if c<3
            U(n)=-U(n);
            V(n)=-V(n);
        end
    elseif (Y1(n)-xy{2}(1))<0.1*y_total || (xy{2}(2)-Y1(n))<0.1*y_total || (Y2(n)-xy{2}(1))<0.1*y_total || (xy{2}(2)-Y2(n))<0.1*y_total
        [m,c]=min([Y1(n)-xy{2}(1) xy{2}(2)-Y1(n) Y2(n)-xy{2}(1) xy{2}(2)-Y2(n)]); 
        if c<3
            U(n)=-U(n);
            V(n)=-V(n);
        end
    else
        t=1:length(Map);
        t(n)=[];
        m1=min(sqrt( (X(t)-X1(n)).^2 + (Y(t)-Y1(n)).^2));
        m2=min(sqrt( (X(t)-X2(n)).^2 + (Y(t)-Y2(n)).^2));
        if m2>m1
            U(n)=-U(n);
            V(n)=-V(n);
        end
    end
    
end
hExportViewGui.Arrows=PlotArrows(hMainGui.MidPanel.aView,X,Y,U,V,O,S);
if ~isempty(hExportViewGui.Names)
    delete(hExportViewGui.Names);
    hExportViewGui.Names=[];
end
if get(hExportViewGui.cAddName,'Value')
    hExportViewGui.Names=PlotNames(hMainGui.MidPanel.aView,Map,X,Y,U,V,O,S);
end
setappdata(0,'hExportViewGui',hExportViewGui);
    
function Map=CreateMap(Object,hMainGui)
PixSize=hMainGui.Values.PixSize;
Map=struct('Name',{},'PosX',{},'PosY',{},'OrientationX',{},'OrientationY',{});
t=1;
for n=1:length(Object)
    if hMainGui.Values.FrameIdx<0
        k=ceil(size(Object(n).Results,1)/2);
    else
        k=find(Object(n).Results(:,1)==hMainGui.Values.FrameIdx);
    end
    if ~isempty(k)
        Map(t).Name=Object(n).Name;
        Map(t).PosX=Object(n).Results(k,3)/PixSize;
        Map(t).PosY=Object(n).Results(k,4)/PixSize;
        if size(Object(n).Results,1)>1000
            first=k-50;
            last=k+50;
            if first<1
                first=1;
                last=51;
            end
            if last>size(Object(n).Results,1);
                first=size(Object(n).Results,1)-50;
                last=size(Object(n).Results,1);
            end
        end
        if hMainGui.Values.FrameIdx<0 || size(Object(n).Results,1)<1001
            first=1;
            last=size(Object(n).Results,1);
        end
        p=1;
        v=[];
        for m=first:last
            if m~=k
                v(p,:)=(m-k)*[(Object(n).Results(m,4)-Object(n).Results(k,4)) -(Object(n).Results(m,3)-Object(n).Results(k,3))];
                p=p+1;
            end
        end
        U=mean(v(:,1));
        V=mean(v(:,2));
        Map(t).OrientationX=U/norm([U V]);
        Map(t).OrientationY=V/norm([U V]);
        
        t=t+1;
    end
end
   
function h = PlotArrows(parent,xi,yi,u,v,o,s)
h=[];
xf = xi + u*(o+s);
yf = yi + v*(o+s);
xi = xi + u*o;
yi = yi + v*o;
[xf,yf]=axes2figure(xf,yf,parent);
[xi,yi]=axes2figure(xi,yi,parent);
for n=1:length(xi)
    h(n) = annotation('arrow',[xf(n) xi(n)],[yf(n) yi(n)],'Color','white','LineWidth',3,'HeadWidth',18,'HeadLength',14);
end

function h = PlotNames(parent,Map,xi,yi,u,v,o,s)
h=[];
xf = xi + u*(o+s);
yf = yi + v*(o+s);
for n=1:length(Map)
    if v(n)<-0.4
        vert='bottom';
    elseif v(n)>0.4
        vert='top';
    else
        vert='middle';
    end
    if u(n)<-0.4
        horz='right';
    elseif u(n)>0.4
        horz='left';
        if v(n)>=-0.4&&v(n)<=0.4
            xf(n)=xf(n)+0.1*o;
        end
    else
        horz='center';
    end
    h(n) = text(xf(n),yf(n),Map(n).Name,'Parent',parent','VerticalAlignment',vert,'HorizontalAlignment',horz,'Color','white',...
                                        'FontUnits','normalized','FontSize',0.02,'FontWeight','bold');
end

function [xfigure, yfigure]=axes2figure(xaxes,yaxes,h_axes)
% get axes properties
funit=get(get(h_axes,'Parent'),'Units');
% get axes properties
aunit=get(h_axes,'Units');
darm=get(h_axes,'DataAspectRatioMode');
pbarm=get(h_axes,'PlotBoxAspectRatioMode');
pbar=get(h_axes,'PlotBoxAspectRatio');

xd=get(h_axes,'XDir');
yd=get(h_axes,'YDir');

% set the right units for h_axes
set(h_axes,'Units',funit);
axesoffsets = get(h_axes,'Position');
paneloffsets = get(get(h_axes,'Parent'),'Position');
axesoffsets = [paneloffsets(1)+axesoffsets(1)*paneloffsets(3) paneloffsets(2)+axesoffsets(2)*paneloffsets(4) axesoffsets(3)*paneloffsets(3) axesoffsets(4)*paneloffsets(4)];

x_axislimits = get(h_axes, 'xlim');     %get axes extremeties.
y_axislimits = get(h_axes, 'ylim');     %get axes extremeties.
x_axislength = x_axislimits(2) - x_axislimits(1); %get axes length
y_axislength = y_axislimits(2) - y_axislimits(1); %get axes length

% mananged the aspect ratio problems
set(h_axes,'units','centimeters');
asc=get(h_axes,'Position');
rasc=asc(4)/asc(3);
rpb=pbar(2)/pbar(1);
if rasc<rpb
    xwb=axesoffsets(3)/rpb*rasc;
    xab=axesoffsets(1)+axesoffsets(3)/2-xwb/2;
    yab=axesoffsets(2);
    ywb=axesoffsets(4);
elseif rasc==rpb
    xab=axesoffsets(1);
    yab=axesoffsets(2);
    xwb=axesoffsets(3);
    ywb=axesoffsets(4);
else
    ywb=axesoffsets(4)*rpb/rasc;
    yab=axesoffsets(2)+axesoffsets(4)/2-ywb/2;
    xab=axesoffsets(1);
    xwb=axesoffsets(3);
end

if strcmp(darm,'auto') & strcmp(pbarm,'auto')
    xab=axesoffsets(1);
    yab=axesoffsets(2);
    xwb=axesoffsets(3);
    ywb=axesoffsets(4);
end

% compute coordinate taking in account for axes directions
if strcmp(xd , 'normal')==1
    xfigure = xab+xwb*(xaxes-x_axislimits(1))/x_axislength;
else
    xfigure = xab+xwb*(x_axislimits(2)-xaxes)/x_axislength;
end
if strcmp(funit,'normalized');
    xfigure(xfigure>1)=1;
    xfigure(xfigure<0)=0;
end

if strcmp(yd , 'normal')==1
    yfigure = yab+ywb*(yaxes-y_axislimits(1))/y_axislength;
else
    yfigure = yab+ywb*(y_axislimits(2)-yaxes)/y_axislength;
end
if strcmp(funit,'normalized');
    yfigure(yfigure>1)=1;
    yfigure(yfigure<0)=0;
end
set(h_axes,'Units',aunit); % put axes units back to original state

function Export(hExportViewGui)
hMainGui=getappdata(0,'hMainGui');
XRes=str2double(get(hExportViewGui.eXRes,'String'));            
YRes=str2double(get(hExportViewGui.eYRes,'String'));            
R=max([XRes YRes]);
if get(hExportViewGui.rCurrentView,'Value')
    [FileName,PathName,FilterIndex] = uiputfile({'*.jpg','JPEG-File (*.jpg)';'*.tif','TIFF-File (*.tif)'},'Export Image',fShared('GetSaveDir'));
    if FileName~=0
        fShared('SetSaveDir',PathName);
        set(hMainGui.MidPanel.aView,'Units','pixels');
        res=get(hMainGui.MidPanel.aView,'Position');
        res=[res(1) res(2) R R];                
        setappdata(0,'hMainGui',hMainGui);
        set(hMainGui.MidPanel.aView,'Position',res);
        set(hMainGui.MidPanel.aView,'Units','normalized');
        fShow('Image');
        UpdateView(hExportViewGui);
        hExportViewGui=getappdata(0,'hExportViewGui');
        Resolution(hMainGui,hExportViewGui,'adjust');
        F=getframe(hMainGui.MidPanel.aView);
        Resolution(hMainGui,hExportViewGui,'reset');   
        I=frame2im(F);
        file = [PathName FileName];
        if isempty(findstr('.jpg',FileName))&&FilterIndex==1
            file = [file '.jpg'];
        elseif isempty(findstr('.tif',FileName))&&FilterIndex==2
            file = [file '.tif'];
        end
        imwrite(I,file);
        close(hExportViewGui.fig);
    end
else
    [FileName,PathName] = uiputfile({'*.avi','AVI-File (*.avi)'},'Export Movie',fShared('GetSaveDir'));
    if FileName~=0
        fShared('SetSaveDir',PathName);
        file = [PathName FileName];
        if isempty(findstr('.avi',FileName))
            file = [file '.avi'];
        end
        if get(hExportViewGui.rWholeStack,'Value')
            first=1;
            last=hMainGui.Values.MaxIdx;
        else
            first=str2double(get(hExportViewGui.eFirst,'String'));
            last=str2double(get(hExportViewGui.eLast,'String'));            
        end
        fps=str2double(get(hExportViewGui.eFPS,'String'));            
        if ~isnan(first)&&~isnan(last)&&~isnan(fps)
            if fps>15
                step=round(fps/15);
                fps=round(fps/step);
            else
                step=1;
            end
            p=1;
            for n=first:step:last
                hMainGui.Values.FrameIdx=n;
                set(hMainGui.MidPanel.aView,'Units','pixels');
                res=get(hMainGui.MidPanel.aView,'Position');
                res=[res(1) res(2) R R];                
                setappdata(0,'hMainGui',hMainGui);
                set(hMainGui.MidPanel.aView,'Position',res);
                set(hMainGui.MidPanel.aView,'Units','normalized');
                fShow('Image');
                UpdateView(hExportViewGui);
                hExportViewGui=getappdata(0,'hExportViewGui');
                Resolution(hMainGui,hExportViewGui,'adjust');
                F(p)=getframe(hMainGui.MidPanel.aView);
                Resolution(hMainGui,hExportViewGui,'reset');                
                p=p+1;
            end
            compression=get(hExportViewGui.mCompression,'String');
            movie2avi(F,file,'fps',fps,'compression',compression{get(hExportViewGui.mCompression,'Value')});
            close(hExportViewGui.fig);            
        end
    end
end

function Resolution(hMainGui,hExportViewGui,Mode)
pos=get(hMainGui.MidPanel.aView,'Position');
if strcmp(Mode,'adjust')
    LineFactor=1+1/pos(3)*0.5+1/pos(4)*0.5;
    MarkerFactor=1+1/pos(3)*0.05+1/pos(4)*0.05;
    FontFactor=1+1/pos(3)*0.05+1/pos(4)*0.05;
else
    LineFactor=1/(1+1/pos(3)*0.5+1/pos(4)*0.5);
    MarkerFactor=1/(1+1/pos(3)*0.05+1/pos(4)*0.05);
    FontFactor=1/(1+1/pos(3)*0.05+1/pos(4)*0.05);
end
obj=findobj('Parent',hMainGui.MidPanel.aView,'-and','Tag','pTracks');
LineWidth=get(obj,'LineWidth');
if iscell(LineWidth)
    set(obj,{'LineWidth'},num2cell(cell2mat(LineWidth)*LineFactor));
else
    set(obj,'LineWidth',LineWidth*LineFactor);
end
obj=findobj('Parent',hMainGui.MidPanel.aView,'-and','Tag','pObjects');
MarkerSize=get(obj,'MarkerSize');
LineWidth=get(obj,'LineWidth');
if iscell(LineWidth)
    set(obj,{'LineWidth'},num2cell(cell2mat(LineWidth)*LineFactor),{'MarkerSize'},num2cell(cell2mat(MarkerSize)*MarkerFactor));
else
    set(obj,'LineWidth',LineWidth*LineFactor,'MarkerSize',MarkerSize*MarkerFactor);    
end
FontSize=get(hExportViewGui.Names,'FontSize');
if iscell(FontSize)
    set(hExportViewGui.Names,{'FontSize'},num2cell(cell2mat(FontSize)*FontFactor));
else
    set(hExportViewGui.Names,'FontSize',FontSize*FontFactor);
end