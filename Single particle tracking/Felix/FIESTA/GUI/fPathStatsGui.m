function fPathStatsGui(func,varargin)
switch func
    case 'Create'
        Create;
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
    case 'Drift'
        Drift(varargin{1});  
    case 'Load'
        Load(varargin{1});  
    case 'Save'
        Save(varargin{1});          
    case 'Apply'
        Apply(varargin{1});                  
end

function Create
global Molecule;
global Filament;

h=findobj('Tag','hPathsStatsGui');
close(h)

button =  questdlg('How should FIESTA find the path?','Path Statistics','Fit','Average','Load','Fit');
if ~strcmp(button,'Load')
    if isempty(Molecule) && isempty(Filament)
        return;
    end
end
if strcmp(button,'Average')
    AverageDis = round(str2double(inputdlg('Average Distance in nm:','Path Statistics')));
end

str='';

PathStats=[];
if ~strcmp(button,'Load')
    Selected = [ [Molecule.Selected] [Filament.Selected]];
    if max(Selected)==0
        errordlg('No Track selected!','FIESTA Error','modal');
        return;
    end
    p=1;
    for i=1:length(Molecule)
        if Molecule(i).Selected==1
            str{p}=Molecule(i).Name;  %#ok<AGROW>
            PathStats(p).Name=Molecule(i).Name; %#ok<AGROW>
            PathStats(p).Directory=Molecule(i).Directory; %#ok<AGROW>
            PathStats(p).File=Molecule(i).File; %#ok<AGROW>                
            PathStats(p).Drift=Molecule(i).Drift; %#ok<AGROW>
            PathStats(p).Results=Molecule(i).Results; %#ok<AGROW>
            PathStats(p).Check=zeros(size(PathStats(p).Results,1),1); %#ok<AGROW>
            PathStats(p).NewResults=[]; %#ok<AGROW>
            PathStats(p).Path=[]; %#ok<AGROW>
            PathStats(p).Index=i; %#ok<AGROW>            
            p=p+1;        
        end
    end
    for i=1:length(Filament)
        if Filament(i).Selected==1
            str{p}=Filament(i).Name; %#ok<AGROW>
            PathStats(p).Name=Filament(i).Name; %#ok<AGROW>
            PathStats(p).Directory=Filament(i).Directory; %#ok<AGROW>
            PathStats(p).File=Filament(i).File; %#ok<AGROW>        
            PathStats(p).Drift=Filament(i).Drift; %#ok<AGROW>
            PathStats(p).Results=Filament(i).Results;         %#ok<AGROW>
            PathStats(p).Check=zeros(size(PathStats(p).Results,1),1); %#ok<AGROW>
            PathStats(p).NewResults=[];         %#ok<AGROW>
            PathStats(p).Path=[];         %#ok<AGROW>
            PathStats(p).Index=i*1i;
            p=p+1;
        end
    end
end

hPathsStatsGui.fig = figure('Units','normalized','DockControls','off','IntegerHandle','off','MenuBar','none','Name','Path Statistics',...
                      'NumberTitle','off','Position',[0.05 0.05 0.65 0.9],'HandleVisibility','callback','Tag','hPathsStatsGui',...
                      'Visible','on','Resize','off','Color',[0.9255 0.9137 0.8471],'WindowStyle','normal');
                  
hPathsStatsGui=ToolBar(hPathsStatsGui);                  

hPathsStatsGui.tCalcPath = uicontrol('Parent',hPathsStatsGui.fig,'Units','normalized','Position',[0.45 0.75 0.5 0.1],'FontSize',12,'FontWeight','bold',...
                        'String','Calculating Path','Style','text','Tag','tCalcPath','HorizontalAlignment','center');
                    
hPathsStatsGui.aPlotXY = axes('Parent',hPathsStatsGui.fig,'Units','normalized','Position',[0.45 0.625 0.5 0.35],'Tag','aPlotXY','Visible','off');
                    
hPathsStatsGui.lAll = uicontrol('Parent',hPathsStatsGui.fig,'Units','normalized','BackgroundColor',[1 1 1],'Callback','fPathStatsGui(''Update'',getappdata(0,''hPathsStatsGui''));',...
                           'Position',[0.05 0.79 0.35 0.19],'String',str,'Style','listbox','Value',1,'Tag','lAll','Max',length(PathStats));                         
                       
hPathsStatsGui.pOptions = uipanel('Parent',hPathsStatsGui.fig,'Units','normalized','Title','Options',...
                             'Position',[0.05 0.625 0.35 0.15],'Tag','pOptions');

if ~isempty(PathStats)
    hPathsStatsGui.cDrift = uicontrol('Parent',hPathsStatsGui.pOptions,'Units','normalized','Callback','fPathStatsGui(''Drift'',getappdata(0,''hPathsStatsGui''));',...
                            'Position',[0.1 0.82 0.6 0.16],'String','Correct for Drift','Style','radiobutton','Tag','cDrift','Value',PathStats(1).Drift);     
else
    hPathsStatsGui.cDrift = uicontrol('Parent',hPathsStatsGui.pOptions,'Units','normalized','Callback','fPathStatsGui(''Drift'',getappdata(0,''hPathsStatsGui''));',...
                            'Position',[0.1 0.82 0.6 0.16],'String','Correct for Drift','Style','radiobutton','Tag','cDrift','Value',0);     
end

hPathsStatsGui.bAuto = uicontrol('Parent',hPathsStatsGui.pOptions,'Units','normalized','Callback','fPathStatsGui(''Update'',getappdata(0,''hPathsStatsGui''));',...
                            'Position',[0.75 0.55 0.2 0.4],'String','Auto Fit','Tag','bReset');    
                        
hPathsStatsGui.bReset = uicontrol('Parent',hPathsStatsGui.pOptions,'Units','normalized','Callback','fPathStatsGui(''Update'',getappdata(0,''hPathsStatsGui''));',...
                            'Position',[0.75 0.05 0.2 0.4],'String','Reset plots','Tag','bReset');                        
                        
hPathsStatsGui.rLinear = uicontrol('Parent',hPathsStatsGui.pOptions,'Units','normalized','Callback','fPathStatsGui(''Update'',getappdata(0,''hPathsStatsGui''));',...
                            'Position',[0.1 0.66 0.6 0.16],'String','Linear path','Style','radiobutton','Tag','rLinear','Value',0);                         

hPathsStatsGui.rPoly2 = uicontrol('Parent',hPathsStatsGui.pOptions,'Units','normalized','Callback','fPathStatsGui(''Update'',getappdata(0,''hPathsStatsGui''));',...
                            'Position',[0.1 0.50 0.6 0.16],'String','2nd deg polynomial path','Style','radiobutton','Tag','rPoly2','Value',0);          

hPathsStatsGui.rPoly3 = uicontrol('Parent',hPathsStatsGui.pOptions,'Units','normalized','Callback','fPathStatsGui(''Update'',getappdata(0,''hPathsStatsGui''));',...
                            'Position',[0.1 0.34 0.6 0.16],'String','3rd deg polynomial path','Style','radiobutton','Tag','rPoly3','Value',0);                          

hPathsStatsGui.rAverage = uicontrol('Parent',hPathsStatsGui.pOptions,'Units','normalized','Callback','fPathStatsGui(''Update'',getappdata(0,''hPathsStatsGui''));',...
                            'Position',[0.1 0.18 0.6 0.16],'String','Average path over defined region','Style','radiobutton','Tag','rAverage','Value',0);   
                        
hPathsStatsGui.eAverage = uicontrol('Parent',hPathsStatsGui.pOptions,'Units','normalized','Callback','fPathStatsGui(''Update'',getappdata(0,''hPathsStatsGui''));','Enable','off',...
                              'Position',[0.3 0.02 0.3 0.16],'String','1000','Style','edit','Tag','eAverage','BackgroundColor',[1 1 1]);                         
                          
hPathsStatsGui.tNM = uicontrol('Parent',hPathsStatsGui.pOptions,'Units','normalized','Position',[0.62 0 0.1 0.2],'Enable','off',...
                        'String','nm','Style','text','Tag','tNM','HorizontalAlignment','left');

hPathsStatsGui.aPlotDist = axes('Parent',hPathsStatsGui.fig,'Units','normalized','Position',[0.05 0.3 0.9 0.3],'Tag','aPlotDist');

ylabel(hPathsStatsGui.aPlotDist,'Distance along path');
                          
hPathsStatsGui.aPlotSide = axes('Parent',hPathsStatsGui.fig,'Units','normalized','Position',[0.05 0.1 0.9 0.175],'Tag','aPlotSide');

ylabel(hPathsStatsGui.aPlotSide,'Sideways motion (distance to path)');
    
hPathsStatsGui.bLoad = uicontrol('Parent',hPathsStatsGui.fig,'Units','normalized','Callback','fPathStatsGui(''Load'',getappdata(0,''hPathsStatsGui''));',...
                            'Position',[0.1 0.025 0.25 0.05],'String','Load','Tag','bLoad');

hPathsStatsGui.bSaveMat = uicontrol('Parent',hPathsStatsGui.fig,'Units','normalized','Callback','fPathStatsGui(''Save'',getappdata(0,''hPathsStatsGui''));',...
                            'Position',[0.4 0.05 0.25 0.025],'String','Save as MatLab file','Tag','bSave','UserData','mat');
                        
hPathsStatsGui.bSaveSingleText = uicontrol('Parent',hPathsStatsGui.fig,'Units','normalized','Callback','fPathStatsGui(''Save'',getappdata(0,''hPathsStatsGui''));',...
                            'Position',[0.4 0.025 0.12 0.02],'String','single text file','Tag','bSave','UserData','single');
                        
hPathsStatsGui.bSaveMultipleText = uicontrol('Parent',hPathsStatsGui.fig,'Units','normalized','Callback','fPathStatsGui(''Save'',getappdata(0,''hPathsStatsGui''));',...
                            'Position',[0.53 0.025 0.12 0.02],'String','multiple text file','Tag','bSave','UserData','multiple');                        

hPathsStatsGui.bApply = uicontrol('Parent',hPathsStatsGui.fig,'Units','normalized','Callback','fPathStatsGui(''Apply'',getappdata(0,''hPathsStatsGui''));',...
                             'Position',[0.7 0.025 0.25 0.05],'String','Apply','Tag','bClose');                        

hPathsStatsGui.Zoom = zoom(hPathsStatsGui.fig);
set(hPathsStatsGui.Zoom,'ActionPostCallback',@Button);
hPathsStatsGui.Pan = pan(hPathsStatsGui.fig);
set(hPathsStatsGui.Pan,'ActionPostCallback',@Button);

setappdata(0,'hPathsStatsGui',hPathsStatsGui);
setappdata(hPathsStatsGui.fig,'PathStats',PathStats);
if ~isempty(PathStats)
    if strcmp(button,'Load')==0
        StartTime=clock;
        workbar(0/(length(PathStats)),'Calculating path','Progress',0);
        for i=1:length(PathStats)
            PathStats(i).Path=[];    
            if strcmp(button,'Fit')
                X=PathStats(i).Results(:,3);
                Y=PathStats(i).Results(:,4);    
                [param1,resnorm1]=PathFitLinear(X,Y); %#ok<NASGU>
                [PathX,PathY,Dis,Side]=LinearPath(X,Y,param1);
                [param2,resnorm2]=PathFitPoly2(X,Y,Side,param1); %#ok<NASGU>
                [param3,resnorm3]=PathFitPoly3(X,Y,Side,param1); %#ok<NASGU>
                if all(resnorm1<[resnorm2 resnorm3])
                    if i==1
                        set(hPathsStatsGui.rLinear,'Value',1);  
                    end
                    PathStats(i).AverageDis=-1;
                elseif all(resnorm2<[resnorm1 resnorm3])
                    [PathX,PathY,Dis,Side]=Poly2Path(X,Y,param2);
                    PathStats(i).AverageDis=-2;
                    if i==1
                        set(hPathsStatsGui.rPoly2,'Value',1);   
                    end
                elseif all(resnorm3<[resnorm1 resnorm2])
                    [PathX,PathY,Dis,Side]=Poly3Path(X,Y,param3);
                    PathStats(i).AverageDis=-3;
                    if i==1
                        set(hPathsStatsGui.rPoly3,'Value',1); 
                    end
                end
            elseif strcmp(button,'Average')
                [PathX,PathY,Dis,Side]=AveragePath(PathStats(i).Results(:,1:4),AverageDis);
                PathStats(i).AverageDis=AverageDis;
                if i==1
                    set(hPathsStatsGui.rAverage,'Value',1); 
                    set(hPathsStatsGui.eAverage,'Enable','on','String',num2str(PathStats(1).AverageDis)); 
                    set(hPathsStatsGui.tNM,'Enable','on');
                end
            end
            PathStats(i).Path(:,1)=PathX;
            PathStats(i).Path(:,2)=PathY;
            PathStats(i).NewResults(:,1:4)=PathStats(i).Results(:,1:4);
            PathStats(i).NewResults(:,5)=Dis;
            PathStats(i).NewResults(:,6)=Side;    
            PathStats(i).NewResults(:,7)=PathStats(i).Results(:,7);
            h = findobj('Tag','timebar');
            if isempty(h)
                close(hPathsStatsGui.fig);
                return
            end
            timeleft=etime(clock,StartTime)/i*(length(PathStats)-i);    
            workbar(i/(length(PathStats)),'Calculating path','Progress',timeleft);     
        end
        setappdata(hPathsStatsGui.fig,'PathStats',PathStats);
        Draw(hPathsStatsGui);    
    end
else
    if strcmp(button,'Load')
        Load(hPathsStatsGui);
    end
end
        
function Apply(hPathsStatsGui)
global Molecule;
global Filament;
PathStats=getappdata(hPathsStatsGui.fig,'PathStats');
for n=1:length(PathStats)
    if isreal(PathStats(n).Index)
        idx=real(PathStats(n).Index);
        Molecule(idx).NewResults=PathStats(n).NewResults;
        Molecule(idx).Path=PathStats(n).Path;        
    else
        idx=real(PathStats(n).Index);
        Filament(idx).NewResults=PathStats(n).NewResults;
        Filament(idx).Path=PathStats(n).Path;        
    end
end
close(hPathsStatsGui.fig);
    
function Load(hPathsStatsGui)
PathStats=getappdata(hPathsStatsGui.fig,'PathStats');
[FileName, PathName] = uigetfile({'*.mat','FIESTA Path(*.mat)'},'Load FIESTA Path',fShared('GetLoadDir'));
if FileName~=0
    fShared('SetLoadDir',PathName);
    temp_PathStats=fLoad([PathName FileName],'PathStats');
    if isempty(temp_PathStats)
        temp_PathStats=fLoad([PathName FileName],'fPathStats');        
    end
    PathStats=[PathStats temp_PathStats];     
    for i=1:length(PathStats)
       str{i}=PathStats(i).Name; %#ok<AGROW>
    end
    set(hPathsStatsGui.rLinear,'Value',0);                       
    set(hPathsStatsGui.rAverage,'Value',0);                       
    set(hPathsStatsGui.rPoly2,'Value',0);    
    set(hPathsStatsGui.rPoly3,'Value',0);  
    set(hPathsStatsGui.eAverage,'Enable','off'); 
    set(hPathsStatsGui.tNM,'Enable','off');
    if PathStats(1).AverageDis==-1
        set(hPathsStatsGui.rLinear,'Value',1);                       
    elseif PathStats(1).AverageDis==-2
        set(hPathsStatsGui.rPoly2,'Value',1);   
    elseif PathStats(1).AverageDis==-3
        set(hPathsStatsGui.rPoly3,'Value',1); 
    elseif PathStats(1).AverageDis>0
        set(hPathsStatsGui.rAverage,'Value',1);          
        set(hPathsStatsGui.eAverage,'Enable','on','String',num2str(PathStats(1).AverageDis)); 
        set(hPathsStatsGui.tNM,'Enable','on');
    end
    set(hPathsStatsGui.lAll,'String',str,'Value',1);  
    set(hPathsStatsGui.cDrift,'Value',PathStats(1).Drift);   
    setappdata(hPathsStatsGui.fig,'PathStats',PathStats);
    Draw(hPathsStatsGui);
end    


function Save(hPathsStatsGui)
PathStats=getappdata(hPathsStatsGui.fig,'PathStats');
Mode=get(gcbo,'UserData');
if strcmp(Mode,'mat');
    [FileName, PathName] = uiputfile({'*.mat','MAT-files (*.mat)'},'Save FIESTA Path',fShared('GetSaveDir'));
    fShared('SetSaveDir',PathName);
    file = [PathName FileName];
    if isempty(findstr('.mat',file))
        file = [file '.mat'];
    end
    hMainGui=getappdata(0,'hMainGui');
    Config=getappdata(hMainGui.fig,'Config'); %#ok<NASGU>
    save(file,'PathStats','Config');
else
    if strcmp(Mode,'single');
        [FileName, PathName] = uiputfile({'*.txt','Delimeted Text (*.txt)'}, 'Save FIESTA Tracks as...',fShared('GetSaveDir'));
        file = [PathName FileName];
        if FileName~=0
            if isempty(findstr('.txt',file))
                file = [file '.txt'];
            end        
            f = fopen(file,'w');
        end
    else
        PathName=uigetdir(fShared('GetSaveDir'));
    end
    if PathName~=0
        fShared('SetSaveDir',PathName);
        for i=1:length(PathStats)
            if strcmp(Mode,'multiple')
                file=[PathName filesep PathStats(i).Name '.txt'];
                f = fopen(file,'w');
            end
%           fprintf(f,'%s - %s%s\n',PathStats(i).Name,PathStats(i).Directory,PathStats(i).File);
%           fprintf(f,'Frame\tTime\tXPosition\tYPosition\tDistance\tSideways\tIntensity\n');
            fprintf(f,'%f\t%f\t%f\t%f\t%f\t%f\t%f\n',str2num(PathStats(i).Name(10:length(PathStats(i).Name))),0,0,0,0,0,0);  %%%added by YS
            sRes=size(PathStats(i).NewResults,1);
            for j=1:sRes
                fprintf(f,'%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
                           PathStats(i).NewResults(j,1),PathStats(i).NewResults(j,2),PathStats(i).NewResults(j,3),PathStats(i).NewResults(j,4),...
                           PathStats(i).NewResults(j,5),PathStats(i).NewResults(j,6),PathStats(i).NewResults(j,7));

            end
%           fprintf(f,'\n'); 
            if strcmp(Mode,'multiple')
                fclose(f);
            end
        end
        if strcmp(Mode,'single')
            fclose(f);
        end
    end
end

function Update(hPathsStatsGui)
PathStats=getappdata(hPathsStatsGui.fig,'PathStats');
set(hPathsStatsGui.rLinear,'Value',0);                       
set(hPathsStatsGui.rAverage,'Value',0);                       
set(hPathsStatsGui.rPoly2,'Value',0);    
set(hPathsStatsGui.rPoly3,'Value',0);  
set(hPathsStatsGui.eAverage,'Enable','off'); 
set(hPathsStatsGui.tNM,'Enable','off');
n=get(hPathsStatsGui.lAll,'Value');
if gcbo==hPathsStatsGui.rLinear
    set(hPathsStatsGui.rLinear,'Value',1);                       
elseif gcbo==hPathsStatsGui.rPoly2
    set(hPathsStatsGui.rPoly2,'Value',1);   
elseif gcbo==hPathsStatsGui.rPoly3
    set(hPathsStatsGui.rPoly3,'Value',1); 
elseif gcbo==hPathsStatsGui.rAverage
    set(hPathsStatsGui.rAverage,'Value',1);          
    set(hPathsStatsGui.eAverage,'Enable','on','String',''); 
    set(hPathsStatsGui.tNM,'Enable','on');
end
if gcbo==hPathsStatsGui.lAll||gcbo==hPathsStatsGui.bReset
    i=n(1);
    if PathStats(i).AverageDis==-1
        set(hPathsStatsGui.rLinear,'Value',1);    
    elseif PathStats(i).AverageDis==-2
        set(hPathsStatsGui.rPoly2,'Value',1);   
    elseif PathStats(i).AverageDis==-3
        set(hPathsStatsGui.rPoly3,'Value',1);
    else 
        set(hPathsStatsGui.rAverage,'Value',1);          
        set(hPathsStatsGui.eAverage,'Enable','on','String',num2str(PathStats(i).AverageDis)); 
        set(hPathsStatsGui.tNM,'Enable','on');   
    end    
    Draw(hPathsStatsGui);
else
    cla(hPathsStatsGui.aPlotXY);
    set(hPathsStatsGui.aPlotXY,'Visible','off');   
    set(hPathsStatsGui.tCalcPath,'Visible','on');
    drawnow;
    for i = n
        PathStats(i).Path=[];    
        X=PathStats(i).Results(:,3);
        Y=PathStats(i).Results(:,4);    
        if gcbo==hPathsStatsGui.bAuto
            [param1,resnorm1]=PathFitLinear(X,Y); %#ok<NASGU>
            [PathX,PathY,Dis,Side]=LinearPath(X,Y,param1);
            [param2,resnorm2]=PathFitPoly2(X,Y,Side,param1); %#ok<NASGU>
            [param3,resnorm3]=PathFitPoly3(X,Y,Side,param1); %#ok<NASGU>
            if all(resnorm1<[resnorm2 resnorm3])
                set(hPathsStatsGui.rLinear,'Value',1);  
                PathStats(i).AverageDis=-1;
            elseif all(resnorm2<[resnorm1 resnorm3])
                [PathX,PathY,Dis,Side]=Poly2Path(X,Y,param2);
                PathStats(i).AverageDis=-2;
                set(hPathsStatsGui.rPoly2,'Value',1);   
            elseif all(resnorm3<[resnorm1 resnorm2])
                [PathX,PathY,Dis,Side]=Poly3Path(X,Y,param3);
                PathStats(i).AverageDis=-3;
                set(hPathsStatsGui.rPoly3,'Value',1); 
            end
        else
            if get(hPathsStatsGui.rLinear,'Value')==1
                [param,resnorm]=PathFitLinear(X,Y); %#ok<NASGU>
                [PathX,PathY,Dis,Side]=LinearPath(X,Y,param);
                PathStats(i).AverageDis=-1;
            elseif get(hPathsStatsGui.rPoly2,'Value')==1
                [param,resnorm]=PathFitLinear(X,Y); %#ok<NASGU>
                [PathX,PathY,Dis,Side]=LinearPath(X,Y,param);
                [param,resnorm]=PathFitPoly2(X,Y,Side,param); %#ok<NASGU>
                [PathX,PathY,Dis,Side]=Poly2Path(X,Y,param);
                PathStats(i).AverageDis=-2;
            elseif get(hPathsStatsGui.rPoly3,'Value')==1
                [param,resnorm]=PathFitLinear(X,Y); %#ok<NASGU>
                [PathX,PathY,Dis,Side]=LinearPath(X,Y,param);
                [param,resnorm]=PathFitPoly3(X,Y,Side,param); %#ok<NASGU>
                [PathX,PathY,Dis,Side]=Poly3Path(X,Y,param);    
                PathStats(i).AverageDis=-3;
            else
                [PathX,PathY,Dis,Side]=AveragePath(PathStats(i).Results(:,1:4),round(str2double(get(hPathsStatsGui.eAverage,'String'))));
                PathStats(i).AverageDis=round(str2double(get(hPathsStatsGui.eAverage,'String')));
                set(hPathsStatsGui.eAverage,'Enable','on');     
                set(hPathsStatsGui.rAverage,'Value',1);   
            end
        end
        PathStats(i).Path(:,1)=PathX;
        PathStats(i).Path(:,2)=PathY;
        PathStats(i).NewResults(:,1:4)=PathStats(i).Results(:,1:4);
        PathStats(i).NewResults(:,5)=Dis;
        PathStats(i).NewResults(:,6)=Side;    
        PathStats(i).NewResults(:,7)=PathStats(i).Results(:,7);
    end
    if ~isempty(PathStats)
        setappdata(hPathsStatsGui.fig,'PathStats',PathStats);
        Draw(hPathsStatsGui);    
    end
end

function Draw(hPathsStatsGui)
set(hPathsStatsGui.tCalcPath,'Visible','off');
set(hPathsStatsGui.aPlotXY,'Visible','on');   
PathStats=getappdata(hPathsStatsGui.fig,'PathStats');
idx=get(hPathsStatsGui.lAll,'Value');
idx=idx(1);
PathStats(idx).Path(:,1)=PathStats(idx).Path(:,1)-min(PathStats(idx).Results(:,3));
PathStats(idx).Path(:,2)=PathStats(idx).Path(:,2)-min(PathStats(idx).Results(:,4));
PathStats(idx).Results(:,3)=PathStats(idx).Results(:,3)-min(PathStats(idx).Results(:,3));
PathStats(idx).Results(:,4)=PathStats(idx).Results(:,4)-min(PathStats(idx).Results(:,4));
axes(hPathsStatsGui.aPlotXY)
plot(PathStats(idx).Results(:,3),PathStats(idx).Results(:,4),'b-*')
hold on
plot(PathStats(idx).Path(:,1),PathStats(idx).Path(:,2),'g-')
hold off
axis ij
axis auto;
xy=get(hPathsStatsGui.aPlotXY,{'xlim','ylim'});
lx=(xy{1}(2)-xy{1}(1));
ly=(xy{2}(2)-xy{2}(1));
if ly>lx
    xy{1}(1)=xy{1}(1)+lx/2-ly/2;
    xy{1}(2)=xy{1}(1)+lx/2+ly/2;
else
    xy{2}(1)=xy{2}(1)+ly/2-lx/2;
    xy{2}(2)=xy{2}(1)+ly/2+lx/2;
end
set(hPathsStatsGui.aPlotXY,{'xlim','ylim'},xy);
axes(hPathsStatsGui.aPlotDist)
plot(PathStats(idx).Results(:,2),PathStats(idx).Results(:,5),'r--')
hold on
plot(PathStats(idx).NewResults(:,2),PathStats(idx).NewResults(:,5),'b-')
hold off
ylabel(hPathsStatsGui.aPlotDist,'Distance along path');
axes(hPathsStatsGui.aPlotSide)
plot(PathStats(idx).NewResults(:,2),PathStats(idx).NewResults(:,6),'g-')
ylabel(hPathsStatsGui.aPlotSide,'Sideways motion (distance to path)');

function Drift(hPathsStatsGui)
PathStats=getappdata(hPathsStatsGui.fig,'PathStats');
hMainGui=getappdata(0,'hMainGui');
Drift=getappdata(hMainGui.fig,'Drift');
if ~isempty(Drift)
    for j=1:length(PathStats)
        nData=size(PathStats(j).Results,1);
        for i=1:nData
            k=find(Drift(:,1)==PathStats(j).Results(i,1));
            if length(k)==1
                if get(hPathsStatsGui.cDrift,'Value')==1
                    PathStats(j).Results(i,3)=PathStats(j).Results(i,3)-Drift(k,2);
                    PathStats(j).Results(i,4)=PathStats(j).Results(i,4)-Drift(k,3);
                else
                    PathStats(j).Results(i,3)=PathStats(j).Results(i,3)+Drift(k,2);
                    PathStats(j).Results(i,4)=PathStats(j).Results(i,4)+Drift(k,3);
                end
            end
           PathStats(j).Results(i,5)=norm([PathStats(j).Results(i,3)-PathStats(j).Results(1,3) PathStats(j).Results(i,4)-PathStats(j).Results(1,4)]);
        end
    end
    setappdata(hPathsStatsGui.fig,'PathStats',PathStats);
    Update(hPathsStatsGui)
    Draw(hPathsStatsGui,0);
end

function res=LinearModel(param,X,Y)
Proj=(X-param(1))*sin(param(3)) + (Y-param(2))*cos(param(3));
res=( X - (sin(param(3))*Proj+param(1)) ).^2 + ( Y - (cos(param(3))*Proj+param(2))).^2;

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

function res=Poly2Model(param,X,Y)
c3 = 2*param(4)^2;
c2 = 0;
c1 = (2*(param(1)-X)*param(4)*cos(param(3))+2*(Y-param(2))*param(4)*sin(param(3))+1)/c3;
c0 = ((param(1)-X)*sin(param(3))+(param(2)-Y)*cos(param(3)))/c3;
p = (3*c1-c2^2)/3;
q = (9*c1*c2-27*c0-2*c2^3)/27; 
Q=(1/3)*p;
R=(1/2)*q;
D=Q.^3+R.^2;
k=find(D>=0);
S=zeros(length(D),1);
T=zeros(length(D),1);
S(k)=nthroot(R(k)+sqrt(D(k)),3);
T(k)=nthroot(R(k)-sqrt(D(k)),3);
root=zeros(length(D),1);
root(k,1) = -(1/3)*c2+(S(k)+T(k));
root(k,2) = -(1/3)*c2-(1/2)*(S(k)+T(k))+(1/2)*i*sqrt(3)*(S(k)-T(k));
root(k,3) = -(1/3)*c2-(1/2)*(S(k)+T(k))-(1/2)*i*sqrt(3)*(S(k)-T(k));
k=find(D<0);
phi=zeros(length(D),3);
phi(k)=acos(R(k)./sqrt(-Q(k).^3));
root(k,1) = 2*sqrt(-Q(k)).*cos(phi(k)/3)-(1/3)*c2;
root(k,2) = 2*sqrt(-Q(k)).*cos((phi(k)+2*pi)/3)-(1/3)*c2;
root(k,3) = 2*sqrt(-Q(k)).*cos((phi(k)+4*pi)/3)-(1/3)*c2;
root(imag(root)~=0)=NaN;
W=sqrt(([X X X]-(sin(param(3))*root+param(1)+root.^2*param(4)*cos(param(3)))).^2+([Y Y Y]-(cos(param(3))*root+param(2)-root.^2*param(4)*sin(param(3)))).^2);
[m,lx]=min(W,[],2);
Proj=root(sub2ind([length(X) 3],(1:length(X))',lx));
res=( X - (sin(param(3))*Proj+param(1)+Proj.^2*param(4)*cos(param(3)))).^2 + ( Y - (cos(param(3))*Proj+param(2)-Proj.^2*param(4)*sin(param(3)))).^2;

function [param,resnorm]=PathFitPoly2(X,Y,Side,param)
Proj=(X-param(1))*sin(param(3)) + (Y-param(2))*cos(param(3));
fd=fit(Proj,Side,'poly2');
x0=-fd.p2/(2*fd.p1);
y0=fd.p1*x0^2+fd.p2*x0+fd.p3;
param0(1)=sin(param(3))*x0+param(1)+y0*cos(param(3));
param0(2)=cos(param(3))*x0+param(2)-y0*sin(param(3));
param0(3)=param(3);
param0(4)=fd.p1;
options = optimset('Display','off','MaxFunEvals',400,'MaxIter',300,'TolFun',1e-3,'TolX',1e-3,'LargeScale','on');
[param,resnorm,residual,exitflag,output]= lsqnonlin(@Poly2Model,param0,[],[],options,X,Y); %#ok<NASGU>


function [PathX,PathY,Dis,Side]=Poly2Path(X,Y,param)
c3 = 2*param(4)^2;
c2 = 0;
c1 = (2*(param(1)-X)*param(4)*cos(param(3))+2*(Y-param(2))*param(4)*sin(param(3))+1)/c3;
c0 = ((param(1)-X)*sin(param(3))+(param(2)-Y)*cos(param(3)))/c3;
p = (3*c1-c2^2)/3;
q = (9*c1*c2-27*c0-2*c2^3)/27; 
Q=(1/3)*p;
R=(1/2)*q;
D=Q.^3+R.^2;
k=find(D>=0);
S=zeros(length(D),1);
T=zeros(length(D),1);
S(k)=nthroot(R(k)+sqrt(D(k)),3);
T(k)=nthroot(R(k)-sqrt(D(k)),3);
root=zeros(length(D),1);
root(k,1) = -(1/3)*c2+(S(k)+T(k));
root(k,2) = -(1/3)*c2-(1/2)*(S(k)+T(k))+(1/2)*i*sqrt(3)*(S(k)-T(k));
root(k,3) = -(1/3)*c2-(1/2)*(S(k)+T(k))-(1/2)*i*sqrt(3)*(S(k)-T(k));
k=find(D<0);
phi=zeros(length(D),3);
phi(k)=acos(R(k)./sqrt(-Q(k).^3));
root(k,1) = 2*sqrt(-Q(k)).*cos(phi(k)/3)-(1/3)*c2;
root(k,2) = 2*sqrt(-Q(k)).*cos((phi(k)+2*pi)/3)-(1/3)*c2;
root(k,3) = 2*sqrt(-Q(k)).*cos((phi(k)+4*pi)/3)-(1/3)*c2;
root(imag(root)~=0)=NaN;
W=sqrt(([X X X]-(sin(param(3))*root+param(1)+root.^2*param(4)*cos(param(3)))).^2+([Y Y Y]-(cos(param(3))*root+param(2)-root.^2*param(4)*sin(param(3)))).^2);
[m,lx]=min(W,[],2);
Proj=root(sub2ind([length(D) 3],(1:length(D))',lx));
Int=param(4)*(Proj.*sqrt(Proj.^2+1/(2*param(4))^2)+1/(2*param(4))^2*log(Proj+sqrt(Proj.^2+1/(2*param(4))^2)));
Dis=Int-Int(1);
v=[X-(sin(param(3))*Proj+Proj.^2*param(4)*cos(param(3))+param(1)) Y-(cos(param(3))*Proj-Proj.^2*param(4)*sin(param(3))+param(2)) zeros(length(Proj),1)];
u=[(sin(param(3))*Proj+Proj.^2*param(4)*cos(param(3))+param(1))-(sin(param(3))*(min(Proj)-1)+(min(Proj)-1).^2*param(4)*cos(param(3))+param(1))...
   (cos(param(3))*Proj-Proj.^2*param(4)*sin(param(3))+param(2))-(cos(param(3))*(min(Proj)-1)-(min(Proj)-1).^2*param(4)*sin(param(3))+param(2)) zeros(length(Proj),1)];
Side=sqrt( v(:,1).^2 + v(:,2).^2 ).*-sum(sign(cross(v,u)),2);
if Dis(1)>mean(Dis)
    Dis=Dis*-1;
    Side=Side*-1;
end
Dis=Dis-Dis(1);
PathX=(sin(param(3))*sort(Proj)+sort(Proj).^2*param(4)*cos(param(3))+param(1));
PathY=(cos(param(3))*sort(Proj)-sort(Proj).^2*param(4)*sin(param(3))+param(2));

function res=Poly3Model(param,X,Y)
c5 = 3*param(5)^2;
c4 = 5*param(4)*param(5);
c3 = 2*param(4)^2;
c2 = (param(1)-X)*3*param(5)*cos(param(3))+(Y-param(2))*3*param(5)*sin(param(3));
c1 = (2*(param(1)-X)*param(4)*cos(param(3))+2*(Y-param(2))*param(4)*sin(param(3))+1);
c0 = ((param(1)-X)*sin(param(3))+(param(2)-Y)*cos(param(3)));
root=zeros(length(X),5);
for i=1:length(X)
    root(i,:)=roots([c5 c4 c3 c2(i) c1(i) c0(i)])';
end
root(imag(root)~=0)=NaN;
W=sqrt(([X X X X X]-(sin(param(3))*root+param(1)+(root.^2*param(4)+root.^3*param(5))*cos(param(3)))).^2+([Y Y Y Y Y]-(cos(param(3))*root+param(2)-(root.^2*param(4)+root.^3*param(5))*sin(param(3)))).^2);
[m,lx]=min(W,[],2);
Proj=root(sub2ind([length(X) 5],(1:length(X))',lx));
res=( X - (sin(param(3))*Proj+param(1)+(Proj.^2*param(4)+Proj.^3*param(5))*cos(param(3)))).^2 + ( Y - (cos(param(3))*Proj+param(2)-(Proj.^2*param(4)+Proj.^3*param(5))*sin(param(3)))).^2;

function [param,resnorm]=PathFitPoly3(X,Y,Side,param)
Proj=(X-param(1))*sin(param(3)) + (Y-param(2))*cos(param(3));
[p,S,m]=polyfit(Proj,Side,3);
x0=(-2*p(2)+[sqrt(4*p(2)^2-12*p(1)*p(3)) -sqrt(4*p(2)^2-12*p(1)*p(3))])/(6*p(1));
if (p(1)>0&&p(2)>=0)||(p(1)<0&&p(2)<=0)
    if isreal(max(x0))
        x0=max(x0);
    else
        x0=min(x0);        
    end
else
   if isreal(min(x0))
        x0=min(x0);
    else
        x0=max(x0);        
    end
end
y0=polyval(p,x0);
x0=x0*m(2)+m(1);
Side=Side-y0;
Proj=Proj-x0;
F=fittype('p1*x^3+p2*x^2','coefficients',{'p1','p2'});
fd=fit(Proj,Side,F,'Startpoint',[1 1]);
param0(1)=sin(param(3))*x0+param(1)+y0*cos(param(3));
param0(2)=cos(param(3))*x0+param(2)-y0*sin(param(3));
param0(3)=param(3);
param0(4)=fd.p2;
param0(5)=fd.p1;
options = optimset('Display','off','MaxFunEvals',400,'MaxIter',300,'TolFun',1e-3,'TolX',1e-3,'LargeScale','on');
[param,resnorm,residual,exitflag,output]= lsqnonlin(@Poly3Model,param0,[],[],options,X,Y); %#ok<NASGU>


function [PathX,PathY,Dis,Side]=Poly3Path(X,Y,param)
c5 = 3*param(5)^2;
c4 = 5*param(4)*param(5);
c3 = 2*param(4)^2;
c2 = (param(1)-X)*3*param(5)*cos(param(3))+(Y-param(2))*3*param(5)*sin(param(3));
c1 = (2*(param(1)-X)*param(4)*cos(param(3))+2*(Y-param(2))*param(4)*sin(param(3))+1);
c0 = ((param(1)-X)*sin(param(3))+(param(2)-Y)*cos(param(3)));
Proj=zeros(length(X),1);
Dis=zeros(length(X),1);
for i=1:length(X)
    root=roots([c5 c4 c3 c2(i) c1(i) c0(i)])';
    root(imag(root)~=0)=NaN;
    W=sqrt(([X(i) X(i) X(i) X(i) X(i)]-(sin(param(3))*root+param(1)+(root.^2*param(4)+root.^3*param(5))*cos(param(3)))).^2+([Y(i) Y(i) Y(i) Y(i) Y(i)]-(cos(param(3))*root+param(2)-(root.^2*param(4)+root.^3*param(5))*sin(param(3)))).^2);
    [m,lx]=min(W);
    Proj(i)=root(lx);
    if i>1
        F = @(t)sqrt( (sin(param(3))+(2*t*param(4)+3*t.^2*param(5))*cos(param(3))).^2+(cos(param(3))-(2*t*param(4)+3*t.^2*param(5))*sin(param(3))).^2);
        Dis(i) = quad(F,Proj(1),Proj(i)); 
    end
end
v=[X-(sin(param(3))*Proj+(Proj.^2*param(4)+Proj.^3*param(5))*cos(param(3))+param(1)) Y-(cos(param(3))*Proj-(Proj.^2*param(4)+Proj.^3*param(5))*sin(param(3))+param(2)) zeros(length(Proj),1)];
u=[(sin(param(3))*Proj+(Proj.^2*param(4)+Proj.^3*param(5))*cos(param(3))+param(1))-(sin(param(3))*(min(Proj)-1)+((min(Proj)-1).^2*param(4)+(min(Proj)-1).^3*param(5))*cos(param(3))+param(1))...
   (cos(param(3))*Proj-(Proj.^2*param(4)+Proj.^3*param(5))*sin(param(3))+param(2))-(cos(param(3))*(min(Proj)-1)-((min(Proj)-1).^2*param(4)+(min(Proj)-1).^3*param(5))*sin(param(3))+param(2)) zeros(length(Proj),1)];
u(:,1)=u(:,1)./sqrt(u(:,1).^2+u(:,2).^2);
u(:,2)=u(:,2)./sqrt(u(:,1).^2+u(:,2).^2);
Side=sqrt( v(:,1).^2 + v(:,2).^2 ).*-sum(sign(cross(v,u)),2);
if Dis(1)>mean(Dis)
    Dis=Dis*-1;
    Side=Side*-1;
end
Dis=Dis-Dis(1);
PathX=(sin(param(3))*sort(Proj)+(sort(Proj).^2*param(4)+sort(Proj).^3*param(5))*cos(param(3))+param(1));
PathY=(cos(param(3))*sort(Proj)-(sort(Proj).^2*param(4)+sort(Proj).^3*param(5))*sin(param(3))+param(2));

function [X,Y,Dis,Side]=AveragePath(Results,DisRegion)
nData=size(Results,1);
p=2;
NRes(1,1)=Results(1,2);
NRes(1,2)=Results(1,3);
NRes(1,3)=Results(1,4);
k=find(sqrt( (Results(1,3)-Results(:,3)).^2+(Results(1,4)-Results(:,4)).^2)<DisRegion,1,'last');
n=max(k)+1;
while n<nData
    k=find(sqrt( (Results(n,3)-Results(:,3)).^2+(Results(n,4)-Results(:,4)).^2)<DisRegion);
    NRes(p,1)=mean(Results(k,2));
    NRes(p,2)=mean(Results(k,3));
    NRes(p,3)=mean(Results(k,4));
    i=n;
    while i<=max(k)
        w=find(i==k(:),1);
        if isempty(w)
            NRes(p,1)=mean(Results(n:i-1,2));
            NRes(p,2)=mean(Results(n:i-1,3));
            NRes(p,3)=mean(Results(n:i-1,4));
            break
        else
            i=i+1;
        end
    end
    n=i;
    p=p+1;
end
NRes(p,1)=Results(nData,2);
NRes(p,2)=Results(nData,3);
NRes(p,3)=Results(nData,4);
X=NRes(:,2);
Y=NRes(:,3);
T=NRes(:,1);
i=1;
while i<length(T)
    k=find(T(i)==T(:));
    if length(k)>1
        T(i)=mean(T(k));
        X(i)=mean(X(k));
        Y(i)=mean(Y(k));
        T(k(2):k(length(k)))=[];
        X(k(2):k(length(k)))=[];
        Y(k(2):k(length(k)))=[];
    end
    i=i+1;
end
int=mean(T(2:length(T))-T(1:length(T)-1))/1000;
ti=(T(1):int:T(length(T)))';
xi=interp1(T,X,ti);
yi=interp1(T,Y,ti);
for i=1:nData
    [m,k]=min(sqrt( (Results(i,3)-xi).^2+ (Results(i,4)-yi).^2));
    X(i)=xi(k);
    Y(i)=yi(k);
    Dis(i)=0; %#ok<AGROW>
    Side(i)=m*sum(sign(cross([xi(k(1))-xi(1) yi(k(1))-yi(1) 0],[Results(i,3)-xi(k(1)) Results(i,4)-yi(k(1)) 0]))); %#ok<AGROW>
    for j=2:k(1)
        Dis(i)=Dis(i)+norm([xi(j)-xi(j-1) yi(j)-yi(j-1)]); %#ok<AGROW>
    end
end
Dis=Dis-Dis(1);

function Button(hObject, eventdata) %#ok<INUSD>
hPathsStatsGui=getappdata(0,'hPathsStatsGui');
xy=get(hPathsStatsGui.aPlotDist,{'xlim','ylim'});
cp=get(hPathsStatsGui.aPlotDist,'currentpoint');
cp=cp(1,[1 2]);
if all(cp>=[xy{1}(1) xy{2}(1)]) && all(cp<=[xy{1}(2) xy{2}(2)]) && strcmp(get(hPathsStatsGui.ToolCursor,'State'),'off')
    set(hPathsStatsGui.aPlotSide,'xlim',xy{1});
end
xy=get(hPathsStatsGui.aPlotSide,{'xlim','ylim'});
cp=get(hPathsStatsGui.aPlotSide,'currentpoint');
cp=cp(1,[1 2]);
if all(cp>=[xy{1}(1) xy{2}(1)]) && all(cp<=[xy{1}(2) xy{2}(2)]) && strcmp(get(hPathsStatsGui.ToolCursor,'State'),'off')
    set(hPathsStatsGui.aPlotDist,'xlim',xy{1});
end

function hPathsStatsGui=ToolBar(hPathsStatsGui)
hPathsStatsGui.ToolBar=uitoolbar(hPathsStatsGui.fig);  
hPathsStatsGui=ToolCursor(hPathsStatsGui);
hPathsStatsGui=ToolPan(hPathsStatsGui);
hPathsStatsGui=ToolZoomIn(hPathsStatsGui);

%/////////////////////////////////////////////////////////////////////////%
%                            Create Cursor Button in Toolbar              %
%/////////////////////////////////////////////////////////////////////////%
function hPathsStatsGui=ToolCursor(hPathsStatsGui)

CData(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,0,0,0,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,0,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN;];
CData(:,:,2)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,0,0,0,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,0,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN;];
CData(:,:,3)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,0,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,0,0,0,0,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,0,1,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,0,0,1,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,0,1,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,0,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN;];
hPathsStatsGui.ToolCursor=uitoggletool(hPathsStatsGui.ToolBar,'CData',CData,'TooltipString','Cursor','Separator','on','State','on','OnCallback','fPathStatsGui(''bToggleToolCursor'',getappdata(0,''hPathsStatsGui''));');

function bToggleToolCursor(hPathsStatsGui)
set(hPathsStatsGui.ToolCursor,'State','on');
set(hPathsStatsGui.ToolPan,'State','off');
set(hPathsStatsGui.ToolZoomIn,'State','off');
set(hPathsStatsGui.Zoom,'Enable','off');
set(hPathsStatsGui.Pan,'Enable','off');

%/////////////////////////////////////////////////////////////////////////%
%                            Create Zoom In Button in Toolbar             %
%//////////////////////////////////////////////////////////////////////%
function hPathsStatsGui=ToolPan(hPathsStatsGui)
CData(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,0,0,NaN,0,1,1,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,0,NaN;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,0,1,0;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,1,1,0;NaN,0,0,NaN,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,1,0,1,1,1,1,1,1,1,1,1,0,NaN;NaN,0,1,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,0,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;];
CData(:,:,2)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,0,0,NaN,0,1,1,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,0,NaN;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,0,1,0;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,1,1,0;NaN,0,0,NaN,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,1,0,1,1,1,1,1,1,1,1,1,0,NaN;NaN,0,1,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,0,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;];
CData(:,:,3)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,0,0,NaN,0,1,1,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,NaN,NaN;NaN,NaN,0,1,1,0,0,1,1,0,1,1,0,NaN,0,NaN;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,0,1,0;NaN,NaN,NaN,0,1,1,0,1,1,0,1,1,0,1,1,0;NaN,0,0,NaN,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,0;0,1,1,1,0,1,1,1,1,1,1,1,1,1,0,NaN;NaN,0,1,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,1,0,NaN;NaN,NaN,0,1,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,0,1,1,1,1,1,1,1,1,1,0,NaN,NaN;NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,0,1,1,1,1,1,1,0,NaN,NaN,NaN;];
hPathsStatsGui.ToolPan=uitoggletool(hPathsStatsGui.ToolBar,'CData',CData,'TooltipString','Pan','ClickedCallback','fPathStatsGui(''bToolPan'',getappdata(0,''hPathsStatsGui''));');

function bToolPan(hPathsStatsGui)
set(hPathsStatsGui.ToolCursor,'State','off');
set(hPathsStatsGui.ToolPan,'State','on');
set(hPathsStatsGui.ToolZoomIn,'State','off');
set(hPathsStatsGui.Zoom,'Enable','off');
set(hPathsStatsGui.Pan,'Enable','on');


%/////////////////////////////////////////////////////////////////////////%
%                            Create Zoom In Button in Toolbar             %
%/////////////////////////////////////////////////////////////////////////%
function hPathsStatsGui=ToolZoomIn(hPathsStatsGui)
CData(:,:,1)=[NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;NaN,NaN,0,0,0.8,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,NaN,NaN;NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN;NaN,0,NaN,NaN,NaN,0,0,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN;0,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN;0,NaN,NaN,0,0,0,0,0,0,NaN,NaN,0,NaN,NaN,NaN,NaN;0,NaN,NaN,0,0,0,0,0,0,NaN,NaN,0,NaN,NaN,NaN,NaN;0,NaN,NaN,NaN,NaN,0,0,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN;NaN,0,NaN,NaN,NaN,0,0,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN;NaN,0,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,NaN,NaN,NaN,NaN,NaN;NaN,NaN,0,0,NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0,0,0,0,NaN,NaN,0,0,0,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,0,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0,0,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
CData(:,:,2)=[1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1;1,1,0,0,0.8,1,1,1,0,0,1,1,1,1,1,1;1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1;1,0,1,1,1,0,0,1,1,1,0,1,1,1,1,1;0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1;0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1;0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1;0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1;1,0,1,1,1,0,0,1,1,1,0,1,1,1,1,1;1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1;1,1,0,0,1,1,1,1,0,0,0,0,1,1,1,1;1,1,1,1,0,0,0,0,1,1,0,0,0,1,1,1;1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1;1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1;1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1;1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;];
CData(:,:,3)=[1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1;1,1,0,0,0.8,1,1,1,0,0,1,1,1,1,1,1;1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1;1,0,1,1,1,0,0,1,1,1,0,1,1,1,1,1;0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1;0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1;0,1,1,0,0,0,0,0,0,1,1,0,1,1,1,1;0,1,1,1,1,0,0,1,1,1,1,0,1,1,1,1;1,0,1,1,1,0,0,1,1,1,0,1,1,1,1,1;1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1;1,1,0,0,1,1,1,1,0,0,0.502,0.502,1,1,1,1;1,1,1,1,0,0,0,0,1,1,0.502,0.502,0.502,1,1,1;1,1,1,1,1,1,1,1,1,1,1,0.502,0.502,0.502,1,1;1,1,1,1,1,1,1,1,1,1,1,1,0.502,0.502,0.502,1;1,1,1,1,1,1,1,1,1,1,1,1,1,0.502,0.502,1;1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;];
hPathsStatsGui.ToolZoomIn=uitoggletool(hPathsStatsGui.ToolBar,'CData',CData,'TooltipString','Zoom','ClickedCallback','fPathStatsGui(''bToolZoomIn'',getappdata(0,''hPathsStatsGui''));');

function bToolZoomIn(hPathsStatsGui)
set(hPathsStatsGui.ToolCursor,'State','off');
set(hPathsStatsGui.ToolPan,'State','off');
set(hPathsStatsGui.ToolZoomIn,'State','on');
set(hPathsStatsGui.Zoom,'Enable','on');
set(hPathsStatsGui.Pan,'Enable','off');
