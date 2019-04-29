function fMenuOptions(func,varargin)
switch func
    case 'LoadConfig'
        LoadConfig(varargin{1});
    case 'SaveConfig'
        SaveConfig;
    case 'SetDefaultConfig'
        SetDefaultConfig(varargin{1});
     case 'SaveDrift'
        SaveDrift(varargin{1});
    case 'LoadDrift'
        LoadDrift(varargin{1});
end

function LoadConfig(hMainGui)
global Config;
[FileName, PathName] = uigetfile({'*.mat','FIESTA Config(*.mat)'},'Load FIESTA Config',fShared('GetLoadDir'));
if FileName~=0
    fShared('SetLoadDir',PathName);
    tempConfig=fLoad([PathName FileName],'Config');
    Config.ConnectMol=tempConfig.ConnectMol;
    Config.ConnectFil=tempConfig.ConnectFil;    
    Config.Threshold=tempConfig.Threshold;
    Config.RefPoint=tempConfig.RefPoint;
    Config.OnlyTrack=tempConfig.OnlyTrack;
end
fShow('Image',hMainGui);

function SaveConfig
global Config; %#ok<NUSED>
[FileName, PathName] = uiputfile({'*.mat','MAT-File(*.mat)'},'Save FIESTA Config',fShared('GetSaveDir'));
if FileName~=0
    fShared('SetSaveDir',PathName);
    file = [PathName FileName];
    if isempty(findstr('.mat',file))
        file = [file '.mat'];
    end
    save(file,'Config');
end

function SetDefaultConfig(hMainGui)
global Config;
button = questdlg('Overwrite the default configuration?','Warning','Overwrite','Cancel','Cancel');
if strcmp(button,'Overwrite')==1
    Config.FirstTFrame=0;
    Config.FirstCFrame=0;
    Config.LastFrame=0;
    save(hMainGui.Directory.Config,'Config');
end

function LoadDrift(hMainGui)
fRightPanel('CheckDrift',hMainGui);
[FileName, PathName] = uigetfile({'*.mat','FIESTA Drift(*.mat)'},'Load FIESTA Drift',fShared('GetLoadDir'));
if FileName~=0
    fShared('SetLoadDir',PathName);    
    Drift=fLoad([PathName FileName],'Drift');
    if ~isempty(Drift)
        setappdata(hMainGui.fig,'Drift',Drift);
    end
    fShared('UpdateMenu',hMainGui);
end
setappdata(0,'hMainGui',hMainGui);

function SaveDrift(hMainGui)
Drift=getappdata(hMainGui.fig,'Drift'); %#ok<NASGU>
[FileName, PathName] = uiputfile({'*.mat','MAT-files (*.mat)'},'Save FIESTA Drift',fShared('GetSaveDir'));
if FileName~=0
    fShared('SetSaveDir',PathName);
    file = [PathName FileName];
    if isempty(findstr('.mat',file))
        file = [file '.mat'];
    end
    save(file,'Drift');
end