function Object=fShared(func,varargin)
Object=[];
switch func
    case 'AddStack'
        AddStack(varargin{1});
    case 'AnalyseQueue'
        AnalyseQueue(varargin{1});
    case 'SelectOne'
        Object=SelectOne(varargin{1},varargin{2},varargin{3},varargin{4});
    case 'VisibleOne'
        Object=VisibleOne(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6});        
    case 'DeleteTracks'
        DeleteTracks(varargin{1},varargin{2},varargin{3});
    case 'DeleteScan'
        DeleteScan(varargin{1});        
    case 'MergeTracks'
        MergeTracks;        
    case 'ClearTracks'
        ClearTracks(varargin{1});                
    case 'UpdateMenu'
        UpdateMenu(varargin{1});         
    case 'SetDrift'
        SetDrift(varargin{1});        
    case 'ReturnFocus'
        ReturnFocus;  
    case 'GetSaveDir'
        Object=GetSaveDir;
    case 'SetSaveDir'
        SetSaveDir(varargin{1});  
    case 'GetLoadDir'
        Object=GetLoadDir;
    case 'SetLoadDir'
        SetLoadDir(varargin{1});         
end

function SaveDir=GetSaveDir
global FiestaDir;
SaveDir=FiestaDir.Save;
if isempty(SaveDir)
    if isempty(FiestaDir.Load)
        SaveDir=FiestaDir.Stack;
    else
        SaveDir=FiestaDir.Load;
    end
end

function SetSaveDir(SaveDir)
global FiestaDir;
FiestaDir.Save=SaveDir;

function LoadDir=GetLoadDir
global FiestaDir;
LoadDir=FiestaDir.Load;
if isempty(LoadDir)
    LoadDir=FiestaDir.Stack;
end

function SetLoadDir(LoadDir)
global FiestaDir;
FiestaDir.Load=LoadDir;

function ReturnFocus
hMainGui=getappdata(0,'hMainGui');
warning off MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame
javaFrame = get(hMainGui.fig,'JavaFrame');
javaFrame.getAxisComponent.requestFocus;

function MergeTracks
global Molecule;
global Filament;
MolSelected=[Molecule.Selected];
FilSelected=[Filament.Selected];
kMol=find(MolSelected==1);
kFil=find(FilSelected==1);
h = findobj('Tag','hMergeGui');
if ~isempty(h)
    close(h);
end
if isempty(kMol)&&~isempty(kFil)
    fMergeGui('Create','Filament',kFil);
elseif ~isempty(kMol)&&isempty(kFil)
    fMergeGui('Create','Molecule',kMol);    
elseif ~isempty(kMol)&&~isempty(kFil)
    errordlg('FOTS can not merge molecules AND microtubules');
    ReturnFocus;
end


function DeleteTracks(hMainGui,MolSelect,FilSelect)
global Molecule;
global Filament;
global KymoTrackMol;
global KymoTrackFil;
global Stack;
if isempty(MolSelect)
    MolSelect=[Molecule.Selected];
end
if isempty(FilSelect)
    FilSelect=[Filament.Selected];
end
[Molecule,KymoTrackMol]=DeleteSelection(Molecule,KymoTrackMol,MolSelect);
[Filament,KymoTrackFil]=DeleteSelection(Filament,KymoTrackFil,FilSelect);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.MolList,Molecule,hMainGui.RightPanel.pData.sMolList,hMainGui.Menu.ctListMol);
fRightPanel('UpdateList',hMainGui.RightPanel.pData.FilList,Filament,hMainGui.RightPanel.pData.sFilList,hMainGui.Menu.ctListFil);
if isempty(Molecule)
    Molecule=[];
    Molecule=fDefStructure(Molecule,'Molecule');
    set(hMainGui.RightPanel.pData.cMolDrift,'Enable','off');    
    set(hMainGui.RightPanel.pData.cIgnoreMol,'Enable','off');
end
if isempty(Filament)
    Filament=[];
    Filament=fDefStructure(Filament,'Filament'); 
    set(hMainGui.RightPanel.pData.cIgnoreFil,'Enable','off');            
    set(hMainGui.RightPanel.pData.cFilDrift,'Enable','off');
end
UpdateMenu(hMainGui)
setappdata(0,'hMainGui',hMainGui);
if isempty(Stack) && isempty(Filament) && isempty(Molecule)
    set(hMainGui.MidPanel.pView,'Visible','off');
    set(hMainGui.MidPanel.pNoData,'Visible','on')
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','on');      
    drawnow expose
else
    fShow('Image',hMainGui);
    fShow('Tracks',hMainGui);
end

function ClearTracks(hMainGui)
global Molecule;
global Filament;
global Stack;
MolSelect=ones(1,length(Molecule));
FilSelect=ones(1,length(Filament));
DeleteTracks(hMainGui,MolSelect,FilSelect);
if isempty(Stack)
    set(hMainGui.MidPanel.pView,'Visible','off');
    set(hMainGui.MidPanel.pNoData,'Visible','on')
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Tracks present','Visible','on');      
    drawnow expose
end 


function SetDrift(hMainGui)
global Molecule;
fRightPanel('CheckDrift',hMainGui);
mode = questdlg('Fit mode:','Set Drift','fit path','to origin','cancel','fit path'); 
if strcmp(mode,'fit path')==1
    button =  questdlg('Fit drift path:','Set Drift','linear','poly2','poly3','linear'); 
else
    button='';
end
nMol=length(Molecule);
if nMol>0
    nData=zeros(nMol,1);
    for i=1:nMol
        nData(i)=Molecule(i).Results(size(Molecule(i).Results,1),1);
    end
    n=max(nData);
    n=n(1);
    F=(1:n);
    k=find([Molecule.Selected]==1);
    X=zeros(n,length(k));
    Y=zeros(n,length(k));
    p=1;
    for i=k
        R_Index=Molecule(i).Results(:,1);
        R_X=Molecule(i).Results(:,3);
        R_Y=Molecule(i).Results(:,4);
        if strcmp(mode,'fit path')==1
            if strcmp(button,'linear')
                num=1;
            elseif strcmp(button,'poly2')
                num=2;
            elseif strcmp(button,'poly3')
                num=3;
            end
            dx=polyfit(R_Index,R_X,num);       
            dy=polyfit(R_Index,R_Y,num);
            DisX=polyval(dx,F);
            DisY=polyval(dy,F);
            DisX=DisX-DisX(1);
            DisY=DisY-DisY(1);     
        else
            DisX=zeros(n,1);
            DisY=zeros(n,1);
            for j=1:n
                [m,k2]=min(abs(j-R_Index));
                DisX(j)=R_X(k2(1))-R_X(1);
                DisY(j)=R_Y(k2(1))-R_Y(1);
            end
        end
        X(:,p)=DisX;
        Y(:,p)=DisY;
        p=p+1;
    end
    drift_x=mean(X,2);
    drift_y=mean(Y,2);
    drift_dx=std(X,0,2);
    drift_dy=std(Y,0,2);
    Drift=[F' drift_x drift_y drift_dx drift_dy];
    setappdata(hMainGui.fig,'Drift',Drift);
    UpdateMenu(hMainGui);
end

function [Object,KymoObject]=DeleteSelection(Object,KymoObject,Selected)
pTrack=[Object.pTrack];
pTrackSelectB=[Object.pTrackSelectB];
pTrackSelectW=[Object.pTrackSelectW];
pKymoTrack=[KymoObject.plot];
pKymoTrackSelectW=[KymoObject.plotSelectW];
pKymoTrackSelectB=[KymoObject.plotSelectB];
Selection=(Selected==1);
k=ismember([KymoObject.Index],find(Selection==1));
delete(pKymoTrack(k));
delete(pKymoTrackSelectW(k));
delete(pKymoTrackSelectB(k));
KymoObject(k)=[];
delete(pTrack(Selection));
delete(pTrackSelectB(Selection));
delete(pTrackSelectW(Selection));
for n=1:length(KymoObject)
    cIndex=sum(Selection(1:KymoObject(n).Index));
    KymoObject(n).Index=KymoObject(n).Index-cIndex;
end
Object(Selection)=[];

function UpdateMenu(hMainGui)
global Stack;
global Objects;
global Molecule;
global Filament;
global FiestaDir;
Drift=getappdata(hMainGui.fig,'Drift');
OffsetMap=getappdata(hMainGui.fig,'OffsetMap');
enable='off';
if ~isempty(Stack)
    enable='on';
end
set(hMainGui.RightPanel.pButton.bAddLocal,'Enable',enable);
set(hMainGui.Menu.mSaveStack,'Enable',enable);
set(hMainGui.Menu.mCloseStack,'Enable',enable);
if ~isempty(FiestaDir.Server)
    set(hMainGui.Menu.mLoadServer,'Enable','on');
    set(hMainGui.Menu.mLoadObjServer,'Enable','on');
    set(hMainGui.Menu.mAddStackServer,'Enable',enable);
    set(hMainGui.RightPanel.pButton.bAddServer,'Enable',enable);    
    set(hMainGui.RightPanel.pQueue.bSrvRefresh,'Enable','on');    
else
    set(hMainGui.Menu.mLoadServer,'Enable','off');
    set(hMainGui.Menu.mLoadObjServer,'Enable','off');
    set(hMainGui.Menu.mAddStackServer,'Enable','off');
    set(hMainGui.RightPanel.pButton.bAddServer,'Enable','off');    
    set(hMainGui.RightPanel.pQueue.bSrvRefresh,'Enable','off');    
end
set(hMainGui.Menu.mAddStackLocal,'Enable',enable)
set(hMainGui.Menu.mManualTracking,'Enable',enable)
set(hMainGui.Menu.mAnalyseFrame,'Enable',enable);
set(hMainGui.Menu.mNormalizeStack,'Enable',enable);
set(hMainGui.Menu.mFilterStack,'Enable',enable);
set(hMainGui.Menu.mFrame,'Enable',enable);
set(hMainGui.Menu.mMaximum,'Enable',enable);
set(hMainGui.Menu.mAverage,'Enable',enable);
set(hMainGui.Menu.mZProjection,'Enable',enable);
set(hMainGui.Menu.mRedGreenOverlay,'Enable',enable);
set(hMainGui.Menu.mExport,'Enable',enable);
set(get(hMainGui.Menu.mTools,'Children'),'Enable',enable);
enable='off';
if ~isempty(Molecule)||~isempty(Filament)
    enable='on';
end
set(hMainGui.Menu.mSaveTracks,'Enable',enable);
set(hMainGui.Menu.mSaveAs,'Enable',enable);
set(hMainGui.Menu.mClearTracks,'Enable',enable);
set(hMainGui.Menu.mFind,'Enable',enable);
set(hMainGui.Menu.mFindMoving,'Enable',enable);
set(hMainGui.Menu.mFindStatic,'Enable',enable);
set(hMainGui.Menu.mMergeTracks,'Enable',enable);
set(hMainGui.Menu.mDeleteTracks,'Enable',enable);
if isempty(Molecule)
    set(hMainGui.Menu.mSetDrift,'Enable','off');
    set(hMainGui.Menu.mAddToChannel,'Enable','off');    
    set(hMainGui.RightPanel.pData.cMolDrift,'Enable','off','Value',0);
    set(hMainGui.RightPanel.pData.cIgnoreMol,'Enable','off','Value',0);     
else
    set(hMainGui.Menu.mSetDrift,'Enable','on');
    set(hMainGui.Menu.mAddToChannel,'Enable','on');        
    if ~isempty(Drift)
        set(hMainGui.RightPanel.pData.cMolDrift,'Enable','on');
    else
        set(hMainGui.RightPanel.pData.cMolDrift,'Enable','off','Value',0);
    end
    set(hMainGui.RightPanel.pData.cIgnoreMol,'Enable','on');
end
if isempty(Filament)
    set(hMainGui.RightPanel.pData.cFilDrift,'Enable','off','Value',0);   
    set(hMainGui.RightPanel.pData.cIgnoreFil,'Enable','off','Value',0);            
else
    if ~isempty(Drift)
        set(hMainGui.RightPanel.pData.cFilDrift,'Enable','on');
    else
        set(hMainGui.RightPanel.pData.cFilDrift,'Enable','off','Value',0);
    end
    set(hMainGui.RightPanel.pData.cIgnoreFil,'Enable','on');
end

if isempty(Drift)
    set(hMainGui.Menu.mSaveDrift,'Enable','off');
else
    set(hMainGui.Menu.mSaveDrift,'Enable','on');
end
enable='off';
if ~isempty(Objects)
    enable='on';
else
    set(hMainGui.RightPanel.pData.cShowAllMol,'Value',0);
    set(hMainGui.RightPanel.pData.cShowAllFil,'Value',0);
    set(hMainGui.RightPanel.pData.cShowWholeFil,'Value',0,'Enable','off');
end
set(hMainGui.Menu.mSaveObjects,'Enable',enable);
set(hMainGui.Menu.mClearObjects,'Enable',enable);
set(hMainGui.Menu.mReconnect,'Enable',enable);
set(hMainGui.RightPanel.pData.cShowAllMol,'Enable',enable);
set(hMainGui.RightPanel.pData.cShowAllFil,'Enable',enable);

enable='off';
if ~isempty(OffsetMap.RedXY)||~isempty(OffsetMap.GreenXY)
    enable='on';
end
set(hMainGui.Menu.mShowOffsetMap,'Enable',enable);
set(hMainGui.Menu.mSaveOffsetMap,'Enable',enable);
set(hMainGui.Menu.mClearChannel,'Enable',enable);
set(hMainGui.Menu.mMatchChannels,'Enable',enable);
enable='off';
if ~isempty(OffsetMap.Match)
    enable='on';
end
set(hMainGui.Menu.mCorrectOffset,'Enable',enable);


function Object=SelectOne(Object,KymoObject,n,v)
if Object(n).Selected==0||Object(n).Selected==1
    if isempty(v)
        Object(n).Selected=1-Object(n).Selected;
    else
        Object(n).Selected=v;
    end
    if Object(n).Selected==1
        visible='on';
    else
        visible='off';        
    end
    if Object(n).Visible==0
        visible='off';
    end
    set(Object(n).pTrackSelectB,'Visible',visible);
    set(Object(n).pTrackSelectW,'Visible',visible);  
    k=find([KymoObject.Index]==n);
    if ~isempty(k)
        set(KymoObject(k).plotSelectB,'Visible',visible);        
        set(KymoObject(k).plotSelectW,'Visible',visible);   
    end   
end

function Object=VisibleOne(Object,KymoObject,List,n,v,slider)
hMainGui=getappdata(0,'hMainGui');
nObj=length(Object);
value=round(get(slider,'Value'));
if imag(n)>0
    if nObj>8
        idx=imag(n);
        n=nObj-7-value+imag(n);
    else
        idx=imag(n);
        n=imag(n);
    end
else
   idx=n+value+7-nObj;
end
if Object(n).Selected>-1
    if isempty(v)
        Object(n).Visible=1-Object(n).Visible;
    else
        Object(n).Visible=v;
    end
    selected='off';
    if Object(n).Visible
        CDataVisible(:,:,1)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.964705882352941,0.886274509803922,0.811764705882353,0.721568627450980,0.650980392156863,0.635294117647059,0.721568627450980,0.862745098039216,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.858823529411765,0.596078431372549,0.462745098039216,0.356862745098039,0.262745098039216,0.196078431372549,0.176470588235294,0.262745098039216,0.431372549019608,0.709803921568628,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.992156862745098,0.600000000000000,0.168627450980392,0,0,0,0,0,0,0,0,0,0,0.258823529411765,0.905882352941177,NaN;NaN,NaN,NaN,0.843137254901961,0.227450980392157,0,0,0,0,0,0,0,0,0,0,0,0,0,0.372549019607843,NaN;NaN,NaN,0.729411764705882,0.0509803921568627,0,0,0,0,0,0,0,0,0.0274509803921569,0.211764705882353,0.00392156862745098,0,0,0.0745098039215686,0.874509803921569,NaN;NaN,0.650980392156863,0,0,0,0,0.0392156862745098,0.168627450980392,0,0,0,0,0.0666666666666667,0.968627450980392,0.827450980392157,0.325490196078431,0,0,0.329411764705882,0.886274509803922;0.682352941176471,0.239215686274510,0.235294117647059,0,0.462745098039216,0.352941176470588,0.231372549019608,NaN,0.156862745098039,0,0,0,0.125490196078431,0.976470588235294,NaN,0.913725490196078,0.0117647058823529,0.129411764705882,0.129411764705882,0.800000000000000;0.937254901960784,0.674509803921569,0.0431372549019608,0.247058823529412,NaN,0.882352941176471,0.0941176470588235,0.976470588235294,0.403921568627451,0,0,0,0.376470588235294,NaN,NaN,0.603921568627451,0,0.317647058823529,0.960784313725490,0.960784313725490;0.984313725490196,0.121568627450980,0,0.447058823529412,NaN,NaN,0.407843137254902,0.266666666666667,0.258823529411765,0,0,0.0549019607843137,0.858823529411765,NaN,0.854901960784314,0.0627450980392157,0.0156862745098039,0.298039215686275,0.996078431372549,NaN;NaN,0.345098039215686,0,0.0313725490196078,0.717647058823529,NaN,NaN,0.305882352941177,0,0,0.164705882352941,0.784313725490196,NaN,0.858823529411765,0.109803921568627,0,0.384313725490196,0.890196078431373,NaN,NaN;NaN,0.862745098039216,0.0431372549019608,0,0,0.368627450980392,0.827450980392157,NaN,0.945098039215686,0.894117647058824,NaN,NaN,0.592156862745098,0.00784313725490196,0.0117647058823529,0.203921568627451,0.662745098039216,NaN,NaN,NaN;NaN,NaN,0.698039215686275,0,0,0,0,0.188235294117647,0.329411764705882,0.392156862745098,0.317647058823529,0.0823529411764706,0.0274509803921569,0.431372549019608,0.615686274509804,0.682352941176471,0.937254901960784,NaN,NaN,NaN;NaN,NaN,NaN,0.709803921568628,0.341176470588235,0,0,0,0.0313725490196078,0,0.266666666666667,0.372549019607843,0.537254901960784,0.690196078431373,0.937254901960784,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.972549019607843,0.592156862745098,0.109803921568627,0.0745098039215686,0.501960784313726,0.631372549019608,0.400000000000000,0.721568627450980,0.819607843137255,0.952941176470588,0.964705882352941,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0.972549019607843,0.913725490196078,0.843137254901961,NaN,0.929411764705882,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
        CDataVisible(:,:,2)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.964705882352941,0.886274509803922,0.811764705882353,0.721568627450980,0.650980392156863,0.635294117647059,0.721568627450980,0.862745098039216,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.858823529411765,0.596078431372549,0.462745098039216,0.356862745098039,0.262745098039216,0.196078431372549,0.176470588235294,0.262745098039216,0.431372549019608,0.709803921568628,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.992156862745098,0.600000000000000,0.168627450980392,0,0,0,0,0,0,0,0,0,0,0.258823529411765,0.905882352941177,NaN;NaN,NaN,NaN,0.843137254901961,0.227450980392157,0,0,0,0,0,0,0,0,0,0,0,0,0,0.372549019607843,NaN;NaN,NaN,0.729411764705882,0.0509803921568627,0,0,0,0,0,0,0,0,0.0274509803921569,0.211764705882353,0.00392156862745098,0,0,0.0745098039215686,0.874509803921569,NaN;NaN,0.650980392156863,0,0,0,0,0.0392156862745098,0.168627450980392,0,0,0,0,0.0666666666666667,0.968627450980392,0.827450980392157,0.325490196078431,0,0,0.329411764705882,0.886274509803922;0.682352941176471,0.239215686274510,0.235294117647059,0,0.462745098039216,0.352941176470588,0.231372549019608,NaN,0.156862745098039,0,0,0,0.125490196078431,0.976470588235294,NaN,0.913725490196078,0.0117647058823529,0.129411764705882,0.129411764705882,0.800000000000000;0.937254901960784,0.674509803921569,0.0431372549019608,0.247058823529412,NaN,0.882352941176471,0.0941176470588235,0.976470588235294,0.403921568627451,0,0,0,0.376470588235294,NaN,NaN,0.603921568627451,0,0.317647058823529,0.960784313725490,0.960784313725490;0.984313725490196,0.121568627450980,0,0.447058823529412,NaN,NaN,0.407843137254902,0.266666666666667,0.258823529411765,0,0,0.0549019607843137,0.858823529411765,NaN,0.854901960784314,0.0627450980392157,0.0156862745098039,0.298039215686275,0.996078431372549,NaN;NaN,0.345098039215686,0,0.0313725490196078,0.717647058823529,NaN,NaN,0.305882352941177,0,0,0.164705882352941,0.784313725490196,NaN,0.858823529411765,0.109803921568627,0,0.384313725490196,0.890196078431373,NaN,NaN;NaN,0.862745098039216,0.0431372549019608,0,0,0.368627450980392,0.827450980392157,NaN,0.945098039215686,0.894117647058824,NaN,NaN,0.592156862745098,0.00784313725490196,0.0117647058823529,0.203921568627451,0.662745098039216,NaN,NaN,NaN;NaN,NaN,0.698039215686275,0,0,0,0,0.188235294117647,0.329411764705882,0.392156862745098,0.317647058823529,0.0823529411764706,0.0274509803921569,0.431372549019608,0.615686274509804,0.682352941176471,0.937254901960784,NaN,NaN,NaN;NaN,NaN,NaN,0.709803921568628,0.341176470588235,0,0,0,0.0313725490196078,0,0.266666666666667,0.372549019607843,0.537254901960784,0.690196078431373,0.937254901960784,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.972549019607843,0.592156862745098,0.109803921568627,0.0745098039215686,0.501960784313726,0.631372549019608,0.400000000000000,0.721568627450980,0.819607843137255,0.952941176470588,0.964705882352941,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0.972549019607843,0.913725490196078,0.843137254901961,NaN,0.929411764705882,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
        CDataVisible(:,:,3)=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.964705882352941,0.886274509803922,0.811764705882353,0.721568627450980,0.650980392156863,0.635294117647059,0.721568627450980,0.862745098039216,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.858823529411765,0.596078431372549,0.462745098039216,0.356862745098039,0.262745098039216,0.196078431372549,0.176470588235294,0.262745098039216,0.431372549019608,0.709803921568628,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.992156862745098,0.600000000000000,0.168627450980392,0,0,0,0,0,0,0,0,0,0,0.258823529411765,0.905882352941177,NaN;NaN,NaN,NaN,0.843137254901961,0.227450980392157,0,0,0,0,0,0,0,0,0,0,0,0,0,0.372549019607843,NaN;NaN,NaN,0.729411764705882,0.0509803921568627,0,0,0,0,0,0,0,0,0.0274509803921569,0.211764705882353,0.00392156862745098,0,0,0.0745098039215686,0.874509803921569,NaN;NaN,0.650980392156863,0,0,0,0,0.0392156862745098,0.168627450980392,0,0,0,0,0.0666666666666667,0.968627450980392,0.827450980392157,0.325490196078431,0,0,0.329411764705882,0.886274509803922;0.682352941176471,0.239215686274510,0.235294117647059,0,0.462745098039216,0.352941176470588,0.231372549019608,NaN,0.156862745098039,0,0,0,0.125490196078431,0.976470588235294,NaN,0.913725490196078,0.0117647058823529,0.129411764705882,0.129411764705882,0.800000000000000;0.937254901960784,0.674509803921569,0.0431372549019608,0.247058823529412,NaN,0.882352941176471,0.0941176470588235,0.976470588235294,0.403921568627451,0,0,0,0.376470588235294,NaN,NaN,0.603921568627451,0,0.317647058823529,0.960784313725490,0.960784313725490;0.984313725490196,0.121568627450980,0,0.447058823529412,NaN,NaN,0.407843137254902,0.266666666666667,0.258823529411765,0,0,0.0549019607843137,0.858823529411765,NaN,0.854901960784314,0.0627450980392157,0.0156862745098039,0.298039215686275,0.996078431372549,NaN;NaN,0.345098039215686,0,0.0313725490196078,0.717647058823529,NaN,NaN,0.305882352941177,0,0,0.164705882352941,0.784313725490196,NaN,0.858823529411765,0.109803921568627,0,0.384313725490196,0.890196078431373,NaN,NaN;NaN,0.862745098039216,0.0431372549019608,0,0,0.368627450980392,0.827450980392157,NaN,0.945098039215686,0.894117647058824,NaN,NaN,0.592156862745098,0.00784313725490196,0.0117647058823529,0.203921568627451,0.662745098039216,NaN,NaN,NaN;NaN,NaN,0.698039215686275,0,0,0,0,0.188235294117647,0.329411764705882,0.392156862745098,0.317647058823529,0.0823529411764706,0.0274509803921569,0.431372549019608,0.615686274509804,0.682352941176471,0.937254901960784,NaN,NaN,NaN;NaN,NaN,NaN,0.709803921568628,0.341176470588235,0,0,0,0.0313725490196078,0,0.266666666666667,0.372549019607843,0.537254901960784,0.690196078431373,0.937254901960784,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,0.972549019607843,0.592156862745098,0.109803921568627,0.0745098039215686,0.501960784313726,0.631372549019608,0.400000000000000,0.721568627450980,0.819607843137255,0.952941176470588,0.964705882352941,NaN,NaN,NaN,NaN,NaN;NaN,NaN,NaN,NaN,NaN,NaN,0.972549019607843,0.913725490196078,0.843137254901961,NaN,0.929411764705882,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;];
        visible='on';
        if Object(n).Selected
            selected='on';
        end
    else
        CDataVisible=[];
        visible='off';   
        if Object(n).Selected
            selected='off';
        end
    end
    if idx>0&&idx<9
        set(List.Visible(idx),'CData',CDataVisible);
        hMainGui.CurrentKey=[];
        setappdata(0,'hMainGui',hMainGui);
    end
    set(Object(n).pTrack,'Visible',visible);
    set(Object(n).pTrackSelectB,'Visible',selected);
    set(Object(n).pTrackSelectW,'Visible',selected);  
    k=find([KymoObject.Index]==n);
    if ~isempty(k)
        set(KymoObject(k).plot,'Visible',visible);            
        set(KymoObject(k).plotSelectB,'Visible',selected);        
        set(KymoObject(k).plotSelectW,'Visible',selected);   
    end  
end

function DeleteScan(hMainGui)
fToolBar('Cursor',hMainGui);
hMainGui=getappdata(0,'hMainGui');
if ~isempty(hMainGui.Scan)
    fRightPanel('DeleteScan',hMainGui);
    set(hMainGui.RightPanel.pTools.cShowKymoGraph,'Enable','off','Value',0);     
    set(hMainGui.RightPanel.pTools.tKymoStart,'Enable','off');     
    set(hMainGui.RightPanel.pTools.eKymoStart,'Enable','off');                                             
    set(hMainGui.RightPanel.pTools.tKymoEnd,'Enable','off');                                                                                  
    set(hMainGui.RightPanel.pTools.eKymoEnd,'Enable','off');                                                                                  
    set(hMainGui.RightPanel.pTools.aLineScan,'Visible','off');         
    set(hMainGui.RightPanel.pTools.aKymoGraph,'Visible','off');     
    set(hMainGui.RightPanel.pTools.pKymoGraph,'Visible','off');         
end

function AddStack(hMainGui)
global Config;
global Stack;
global Objects;
global Queue;
global FiestaDir;
addConfig=Config;
Mode=get(gcbo,'UserData');
if strcmp(Mode,'Server')
    set(hMainGui.MidPanel.pView,'Visible','off');
    set(hMainGui.MidPanel.pNoData,'Visible','on');
    set(hMainGui.MidPanel.tNoData,'String','Copying Stack to Server - Please wait...','Visible','on');   
    drawnow expose update
end
if (~isempty(Stack)||strcmp(Mode,'Reconnect'))    
    if isempty(Stack)
        y=1;
        x=1;
    else
        y=size(Stack{1},1);
        x=size(Stack{1},2);
    end
    addConfig.Selected=0;
    if strcmp(Mode,'Reconnect')
        addConfig.FirstTFrame=0;
        hMainGui.Values.Thresh=0;
        addConfig.FirstCFrame=1;
        addConfig.LastFrame=length(Objects);
        addConfig.StackName=[strrep(hMainGui.File,'.mat','') ' - Reconnect'];
        addConfig.Directory=fShared('GetLoadDir');
    elseif strcmp(Mode,'One')==1
        addConfig.FirstTFrame=hMainGui.Values.FrameIdx;
        addConfig.FirstCFrame=0;
        addConfig.LastFrame=hMainGui.Values.FrameIdx;
    else
        if Config.LastFrame<Config.FirstTFrame+4
            errordlg({'There must be at least 5 frames for tracking','Try analyzing current frame'},'FOTS2 Error');
            return;
        end
    end
    if strcmp(Mode,'Server')
        file_id{1} = [addConfig.Directory addConfig.StackName];
        file_id{2} = [FiestaDir.Server 'Data' filesep 'Stacks' filesep addConfig.StackName];
        df1=dir(file_id{1});
        df2=dir(file_id{2}); 
        status = 1;
        if isempty(df2)
            [status,message]=copyfile(file_id{1},file_id{2});          
        else
            if df1.bytes~=df2.bytes
                [status,message]=copyfile(file_id{1},file_id{2});          
            end
        end
        if ~status
            errordlg(message,'FIESTA Server Error','modal');
        end
    end
    nRegion=length(hMainGui.Region);
    if nRegion==0
        Region=ones(y,x);
    else
        Region=zeros(y,x);
        for i=1:nRegion
            Region(hMainGui.Region(i).Area==1)=1;
        end
        if get(hMainGui.LeftPanel.pRegions.cExcludeReg,'Value')
            Region=ones(y,x)-Region;
        end
    end
    addConfig.OnlyTrackMol=0;
    addConfig.OnlyTrackFil=0;
    if addConfig.OnlyTrack.MolFull==1
        addConfig.OnlyTrackMol=1;
    end
    if addConfig.OnlyTrack.FilFull==1
        addConfig.OnlyTrackFil=1;
    end
    if strcmp(get(hMainGui.ToolBar.ToolRedGreenImage,'State'),'on')==0||strcmp(Mode,'Reconnect')==1
        if strcmp(addConfig.Threshold.Mode,'Relative')==1
            for i=1:length(hMainGui.Values.MeanStack)
                addConfig.Threshold.Value(i)=round(hMainGui.Values.MeanStack(i)*hMainGui.Values.RelThresh/100+hMainGui.Values.MinStack);
            end
        else
            addConfig.Threshold.Value=hMainGui.Values.Thresh;
        end
        addConfig.Region=Region;
        if strcmp(Mode,'Server')==1
            ServerQueue = fLoad([FiestaDir.Server 'Queue' filesep 'FiestaQueue.mat'],'ServerQueue');
            if isempty(ServerQueue);
                ServerQueue=addConfig;
            else
                ServerQueue=[ServerQueue addConfig];
            end
            save([FiestaDir.Server 'Queue' filesep 'FiestaQueue.mat'],'ServerQueue');
            fRightPanel('UpdateQueue',hMainGui.RightPanel.pQueue.SrvList,ServerQueue,hMainGui.RightPanel.pQueue.sSrvList,'Server');    
            fRightPanel('QueueServerPanel',hMainGui);            
        elseif strcmp(Mode,'Local')==1||strcmp(Mode,'Reconnect')==1||strcmp(Mode,'One')==1
            if isempty(Queue)
                Queue=addConfig;
            else
                Queue=[Queue addConfig];
            end
            fRightPanel('UpdateQueue',hMainGui.RightPanel.pQueue.LocList,Queue,hMainGui.RightPanel.pQueue.sLocList,'Local');
            fRightPanel('QueueLocalPanel',hMainGui);
        end
    else
        if strcmp(addConfig.Threshold.Mode,'Relative')==1
            for i=1:length(hMainGui.Values.MeanRed)
                addConfig.Threshold.Value(i)=round(hMainGui.Values.MeanRed(i)*hMainGui.Values.RedRelThresh/100+hMainGui.Values.MinRed);
            end
        else
            addConfig.Threshold.Value=hMainGui.Values.RedThresh;
        end    
        addConfig.OnlyTrackMol=0;
        addConfig.OnlyTrackFil=0;        
        if addConfig.OnlyTrack.MolLeft==1||addConfig.OnlyTrack.MolFull==1
            addConfig.OnlyTrackMol=1;
        end
        if addConfig.OnlyTrack.FilLeft==1||addConfig.OnlyTrack.FilFull==1
            addConfig.OnlyTrackFil=1;
        end
        LeftRegion=zeros(y,x);
        LeftRegion(:,1:fix(x/2))=1;
        addConfig.Region=Region.*LeftRegion;
        if strcmp(Mode,'Server')
            ServerQueue = fLoad([FiestaDir.Server 'Queue' filesep 'FiestaQueue.mat'],'ServerQueue');
            if isempty(ServerQueue);
                ServerQueue=addConfig;
            else
                ServerQueue=[ServerQueue addConfig];
            end
            save([FiestaDir.Server 'Queue' filesep 'FiestaQueue.mat'],'ServerQueue');
            fRightPanel('UpdateQueue',hMainGui.RightPanel.pQueue.SrvList,ServerQueue,hMainGui.RightPanel.pQueue.sSrvList,'Server');    
            fRightPanel('QueueServerPanel',hMainGui);            
        elseif strcmp(Mode,'Local')==1||strcmp(Mode,'Reconnect')==1||strcmp(Mode,'One')==1
            if isempty(Queue)
                Queue=addConfig;
            else
                Queue=[Queue addConfig];
            end
            fRightPanel('UpdateQueue',hMainGui.RightPanel.pQueue.LocList,Queue,hMainGui.RightPanel.pQueue.sLocList,'Local');
            fRightPanel('QueueLocalPanel',hMainGui);
        end
        if strcmp(addConfig.Threshold.Mode,'Relative')
            for i=1:length(hMainGui.Values.MeanGreen)
                addConfig.Threshold.Value(i)=round(hMainGui.Values.MeanGreen(i)*hMainGui.Values.GreenRelThresh/100+hMainGui.Values.MinGreen);
            end
        else
            addConfig.Threshold.Value=hMainGui.Values.GreenThresh;
        end       
        addConfig.OnlyTrackMol=0;
        addConfig.OnlyTrackFil=0;
        if addConfig.OnlyTrack.MolRight==1||addConfig.OnlyTrack.MolFull==1
            addConfig.OnlyTrackMol=1;
        end
        if addConfig.OnlyTrack.FilRight==1||addConfig.OnlyTrack.FilFull==1
            addConfig.OnlyTrackFil=1;
        end
        RightRegion=zeros(y,x);
        RightRegion(:,fix(x/2)+1:x)=1;
        addConfig.Region=Region.*RightRegion;
        if strcmp(Mode,'Server')
            ServerQueue = fLoad([FiestaDir.Server 'Queue' filesep 'FiestaQueue.mat'],'ServerQueue');
            if isempty(ServerQueue);
                ServerQueue = addConfig;
            else
                ServerQueue = [ServerQueue addConfig];
            end
            save([FiestaDir.Server 'Queue' filesep 'FiestaQueue.mat'],'ServerQueue');
            fRightPanel('UpdateQueue',hMainGui.RightPanel.pQueue.SrvList,ServerQueue,hMainGui.RightPanel.pQueue.sSrvList,'Server');    
            fRightPanel('QueueServerPanel',hMainGui);            
        elseif strcmp(Mode,'Local')==1||strcmp(Mode,'Reconnect')==1||strcmp(Mode,'One')==1
            if isempty(Queue)
                Queue = addConfig;
            else
                Queue = [Queue addConfig];
            end
            fRightPanel('UpdateQueue',hMainGui.RightPanel.pQueue.LocList,Queue,hMainGui.RightPanel.pQueue.sLocList,'Local');
            fRightPanel('QueueLocalPanel',hMainGui);
        end
    end
end
if strcmp(Mode,'Server')
    set(hMainGui.MidPanel.pView,'Visible','on');
    set(hMainGui.MidPanel.pNoData,'Visible','off');    
    set(hMainGui.MidPanel.tNoData,'String','No Stack or Data present','Visible','off');  
end
ReturnFocus;

%/////////////////////////////////////////////////////////////////////////%
%                           Menu - Analyse all Stacks in Queue            %
%/////////////////////////////////////////////////////////////////////////%
function AnalyseQueue(hMainGui)
global Config;
global Queue;
global Objects;
global Stack;
global StackInfo;
nQueue=length(Queue);
abort=0;
backupStack=[];
backupStackInfo=[];
backupObjects=Objects;
Name=Config.StackName;
while nQueue>0&&abort==0
    if Queue(1).FirstTFrame==0
        if isempty(Objects)
            abort=1;
        end
    else
        Objects={};
        f=sprintf('%s%s',Queue(1).Directory,Queue(1).StackName); 
    end
    if isempty(strfind(Queue(1).StackName,'Reconnect'))
        if ~strcmp(Queue(1).StackName,Name)
            backupStack=Stack;
            backupStackInfo=StackInfo;
            Name='';
            try
                [Stack,TiffInfo,StackInfo]=StackRead(f);  %#ok<ASGLU>
            catch   
                msgstr = lasterr;
                errordlg(msgstr,'Error');  
                abort=1;
            end
            if strcmp(Queue(1).StackType,'TIFF')
                nFrames=length(Stack);
                for i=0:nFrames-1
                    StackInfo.CreationTime(i+1)=(i*Queue(1).Time); 
                end
            end
        end
    end
    if abort==0
        abort=fAnalyseStack(Stack,StackInfo,Queue(1),0,Objects);
    end
    if abort==0
        Queue(1)=[];
        fRightPanel('UpdateQueue',hMainGui.RightPanel.pQueue.LocList,Queue,hMainGui.RightPanel.pQueue.sLocList,'Local');
    end
    nQueue=length(Queue);
end
if ~isempty(backupStack)
    Stack=backupStack;
    StackInfo=backupStackInfo;
end
Objects=backupObjects;
ReturnFocus;
