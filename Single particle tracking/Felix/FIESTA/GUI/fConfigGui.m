function fConfigGui(func,varargin)
switch(func)
    case 'Create'
        ConfigGuiCreate;
    case 'OK'
        ConfigGuiOK(varargin{1});
    case 'cancel'
        close(findobj(0,'Tag','hConfigGui'));
    case 'MolPanel'
        MolPanel(varargin{1});
    case 'FilPanel'
        FilPanel(varargin{1});
    case 'OnlyTrack'
        OnlyTrack(varargin{1});
    case 'UseIntensity'
        UseIntensity(varargin{1});        
    case 'SetThreshold'
        SetThreshold(varargin{1});         
    case 'SetFilter'
        SetFilter(varargin{1});             
    case 'SetRefPoint'
        SetRefPoint(varargin{1});             
    case 'ShowModel'
        ShowModel(varargin{1});            
    case 'UpdateParams'
        UpdateParams(varargin{1});             
    case 'Help'
        Help;              
end

function ConfigGuiCreate
global Config;
global Stack;
close(findobj(0,'Tag','hConfigGui'));


hConfigGui.fig=figure('Units','normalized','DockControls','off','IntegerHandle','off','MenuBar','none','Name','FIESTA - Configuration',...
                     'NumberTitle','off','Position',[0.01 0.05 0.7 0.9],'HandleVisibility','callback','Tag','hConfigGui',...
                     'Visible','on','WindowStyle','modal');

hConfigGui.mHelpContext = uicontextmenu('Parent',hConfigGui.fig);

hConfigGui.mHelp = uimenu('Parent',hConfigGui.mHelpContext,'Callback','fConfigGui(''Help'');',...
                          'Label','Help','Tag','mHelp');

hConfigGui.pGeneral.panel = uipanel('Parent',hConfigGui.fig,'Units','normalized','Fontsize',12,'Bordertype','none',...
                                    'Position',[0 0.6 1 0.4],'Tag','pGeneral','Visible','on');          
                                 
hConfigGui.pGeneral.tGeneralOptions = uicontrol('Parent',hConfigGui.pGeneral.panel,'Style','text','Units','normalized',...
                                                'Position',[.0 .94 1 .06],'Tag','tGeneralOptions','Fontsize',12,...
                                                'String','General options','HorizontalAlignment','center','FontWeight','bold','Enable','on',...
                                                'BackgroundColor',[0 0 1],'ForegroundColor','white');                                 

hConfigGui.pGeneral.tStackT = uicontrol('Parent',hConfigGui.pGeneral.panel,'Style','text','Units','normalized',...
                                                'Position',[.01 .85 .09 .06],'Tag','tStackT','Fontsize',12,...
                                                'String','Stack:','HorizontalAlignment','left');     
                                            
hConfigGui.pGeneral.tStack = uicontrol('Parent',hConfigGui.pGeneral.panel,'Style','text','Units','normalized',...
                                                'Position',[.10 .85 .35  .06],'Tag','tStack ','Fontsize',12,...
                                                'String',Config.StackName,'HorizontalAlignment','left');     
                                            
hConfigGui.pGeneral.tStackTypeT = uicontrol('Parent',hConfigGui.pGeneral.panel,'Style','text','Units','normalized',...
                                                'Position',[.51 .85 .14 .06],'Tag','tStackTypeT','Fontsize',12,...
                                                'String','StackType:','HorizontalAlignment','left');     
                                            
hConfigGui.pGeneral.tStackType = uicontrol('Parent',hConfigGui.pGeneral.panel,'Style','text','Units','normalized',...
                                           'Position',[.65 .85 .3 .06],'Tag','tStackType','Fontsize',12,...
                                           'String',Config.StackType,'HorizontalAlignment','left');                      

hConfigGui.pGeneral.pOptions = uipanel('Parent',hConfigGui.pGeneral.panel,'Units','normalized','Fontsize',10,...
                                       'Position',[0.025 0.58 .95 .25],'Tag','pOptions','Visible','on','Title','Stack Options');          
                                   
hConfigGui.pGeneral.tPixSize = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                         'Position',[.025 .55 .175  .4],'Tag','tPixSize','Fontsize',12,...
                                         'String','Pixel size:','HorizontalAlignment','left');     
                                     
hConfigGui.pGeneral.ePixSize = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.25 .55 .1 .4],'Tag','ePixSize','Fontsize',12,'UserData','General options.htm#pixel_size',...
                                         'String',num2str(Config.PixSize),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext);                             
if isempty(Stack)
    set(hConfigGui.pGeneral.ePixSize,'Enable','off');
end

hConfigGui.pGeneral.tNM(1) = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                    'Position',[.37 .55 .06  .4],'Tag','tNM','Fontsize',12,...
                                    'String','nm','HorizontalAlignment','left','TooltipString','Right click for Help');    

hConfigGui.pGeneral.tTimeDiff = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                         'Position',[.5 .55 .3  .4],'Tag','TimeDiff','Fontsize',12,'Enable','off',...
                                         'String','Time difference:','HorizontalAlignment','left');                             

hConfigGui.pGeneral.eTimeDiff = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.8 .55 .1  .4],'Tag','eTimeDiff','Fontsize',12,'Enable','off',...
                                         'String','','BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#time_difference');                             
                                     
hConfigGui.pGeneral.tMS = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                    'Position',[.92 .55 .06  .4],'Tag','tS','Fontsize',12,'Enable','off',...
                                    'String','ms','HorizontalAlignment','left');    
                                
if strcmp(Config.StackType,'TIFF')==1
    set(hConfigGui.pGeneral.eTimeDiff,'String',num2str(Config.Time),'Enable','on');
    set(hConfigGui.pGeneral.tTimeDiff,'Enable','on');
    set(hConfigGui.pGeneral.tMS,'Enable','on');
end
                                  
hConfigGui.pGeneral.tFirstFrame = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                         'Position',[.025 .1 .225  .4],'Tag','tFirstFrame','Fontsize',12,...
                                         'String','First Frame:','HorizontalAlignment','left');                             

hConfigGui.pGeneral.eFirstFrame = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.25 .1 .1 .4],'Tag','eFirstFrame','Fontsize',12,...
                                         'String',num2str(Config.FirstTFrame),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#frame');                                               
                                
hConfigGui.pGeneral.tLastFrame = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','text','Units','normalized',...
                                           'Position',[.5 .1 .3  .4],'Tag','tLastFrame','Fontsize',12,...
                                           'String','Last Frame:','HorizontalAlignment','left');                             

hConfigGui.pGeneral.eLastFrame = uicontrol('Parent',hConfigGui.pGeneral.pOptions,'Style','edit','Units','normalized',...
                                         'Position',[.8 .1 .1 .4],'Tag','eLastFrame','Fontsize',12,...
                                         'String',num2str(Config.LastFrame),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#frame');                             
                                     
hConfigGui.pGeneral.pTrack = uipanel('Parent',hConfigGui.pGeneral.panel,'Units','normalized','Fontsize',10,...
                                       'Position',[0.025 0.21 .45 .35],'Tag','pTrack','Visible','on','Title','Tracking');   
                                   
hConfigGui.pGeneral.tFull = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','text','Units','normalized',...
                                         'Position',[.425 .7 .25  .16],'Tag','tFull','Fontsize',10,...
                                         'String','Full Frame','HorizontalAlignment','left');        

hConfigGui.pGeneral.tLeft = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','text','Units','normalized',...
                                         'Position',[.7 .7 .15  .16],'Tag','tLeft','Fontsize',10,...
                                         'String','Left','HorizontalAlignment','left','ForegroundColor','red'); 

hConfigGui.pGeneral.tRight = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','text','Units','normalized',...
                                      'Position',[.85 .7 .15  .16],'Tag','tRight','Fontsize',10,...
                                      'String','Right','HorizontalAlignment','left','ForegroundColor',[0 0.6 0]);                                       
                                     
hConfigGui.pGeneral.tOnlyMol = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','text','Units','normalized',...
                                         'Position',[.05 .4 .4  .2],'Tag','tOnlyMol','Fontsize',12,...
                                         'String','Only Molecules:','HorizontalAlignment','left');        
                                     
hConfigGui.pGeneral.cMolFull = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','checkbox','Units','normalized','Callback','fConfigGui(''OnlyTrack'',getappdata(0,''hConfigGui''));',...
                                         'Position',[.525 .44 .12 .15],'Tag','cMolFull','HorizontalAlignment','left','Value',Config.OnlyTrack.MolFull,...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#tracking');     
                                     
hConfigGui.pGeneral.cMolLeft = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','checkbox','Units','normalized','Callback','fConfigGui(''OnlyTrack'',getappdata(0,''hConfigGui''));',...
                                         'Position',[.715 .44 .12 .15],'Tag','cMolLeft','HorizontalAlignment','left','Value',Config.OnlyTrack.MolLeft,...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#tracking');     
                                     
hConfigGui.pGeneral.cMolRight = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','checkbox','Units','normalized','Callback','fConfigGui(''OnlyTrack'',getappdata(0,''hConfigGui''));',...
                                         'Position',[.88 .44 .12 .15],'Tag','cMolRight','HorizontalAlignment','left','Value',Config.OnlyTrack.MolRight,...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#tracking');                                             
                                     
hConfigGui.pGeneral.tOnlyFil = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','text','Units','normalized',...
                                         'Position',[.05 .1 .45  .2],'Tag','tOnlyFil ','Fontsize',12,...
                                         'String','Only Filaments:','HorizontalAlignment','left');                    
                                     
hConfigGui.pGeneral.cFilFull = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','checkbox','Units','normalized','Callback','fConfigGui(''OnlyTrack'',getappdata(0,''hConfigGui''));',...
                                         'Position',[.525 .14 .12 .15],'Tag','cMolFull','HorizontalAlignment','left','Value',Config.OnlyTrack.FilFull,...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#tracking');                       
                                     
hConfigGui.pGeneral.cFilLeft = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','checkbox','Units','normalized','Callback','fConfigGui(''OnlyTrack'',getappdata(0,''hConfigGui''));',...
                                         'Position',[.715 .14 .12 .15],'Tag','cMolLeft','HorizontalAlignment','left','Value',Config.OnlyTrack.FilLeft,...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#tracking');                      
                                     
hConfigGui.pGeneral.cFilRight = uicontrol('Parent',hConfigGui.pGeneral.pTrack,'Style','checkbox','Units','normalized','Callback','fConfigGui(''OnlyTrack'',getappdata(0,''hConfigGui''));',...
                                         'Position',[.88 .14 .12 .15],'Tag','cMolRight','HorizontalAlignment','left','Value',Config.OnlyTrack.FilRight,...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#tracking');                                     
                                     
hConfigGui.pGeneral.pThreshold = uipanel('Parent',hConfigGui.pGeneral.panel,'Units','normalized','Fontsize',10,...
                                       'Position',[.525 .21 .45 .35],'Tag','pThreshold','Visible','on','Title','Threshold');   

hConfigGui.pGeneral.tAreaThreshold = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.025 .7 .15  .2],'Tag','tAreaThreshold','Fontsize',12,...
                                              'String','Area:','HorizontalAlignment','left');              

hConfigGui.pGeneral.eAreaThreshold = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','edit','Units','normalized',...
                                              'Position',[.18 .7 .12  .2],'Tag','eAreaThreshold','Fontsize',12,...
                                              'String',num2str(Config.Threshold.Area),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#area'); 
                                          
hConfigGui.pGeneral.tPix = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.32 .7 .08 .2],'Tag','tPix','Fontsize',12,...
                                              'String','pix','HorizontalAlignment','left');              

Value=0;                   
if strcmp(Config.Threshold.Mode,'Constant')==1
    Value=1;
end

hConfigGui.pGeneral.rConstant = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','radiobutton','Units','normalized',...
                                          'Position',[.02 .45 .5  .2],'Tag','rVariable','Fontsize',12,...
                                          'String','Constant Intensity','HorizontalAlignment','left','Value',Value,...
                                          'Callback','fConfigGui(''SetThreshold'',getappdata(0,''hConfigGui''));',...
                                          'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');  
                                      

                                      
Value=0;                   
if strcmp(Config.Threshold.Mode,'Relative')==1
    Value=1;
end

hConfigGui.pGeneral.rRelative = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','radiobutton','Units','normalized',...
                                          'Position',[.02 .25 .5  .2],'Tag','rRelative','Fontsize',12,'Enable','on',...
                                          'String','Relative Intensity','HorizontalAlignment','left','Value',Value,...
                                          'Callback','fConfigGui(''SetThreshold'',getappdata(0,''hConfigGui''));',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');    

Value=0;                   
if strcmp(Config.Threshold.Mode,'Variable')==1
    Value=1;
end

hConfigGui.pGeneral.rVariable = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','radiobutton','Units','normalized',...
                                          'Position',[.02 .05 .5  .2],'Tag','rVariable','Fontsize',12,...
                                          'String','Variable Intensity','HorizontalAlignment','left','Value',Value,...
                                          'Callback','fConfigGui(''SetThreshold'',getappdata(0,''hConfigGui''));',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');          
                                     
hConfigGui.pGeneral.tHeightThreshold = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.52 .7 .22 .2],'Tag','tHeightThreshold','Fontsize',12,...
                                              'String','Heigth:','HorizontalAlignment','left');           
                                          
hConfigGui.pGeneral.eHeightThreshold = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','edit','Units','normalized',...
                                              'Position',[.78 .7 .15  .2],'Tag','eHeightThreshold','Fontsize',12,...
                                              'String',num2str(Config.Threshold.Height),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#cod');    
                                          
hConfigGui.pGeneral.tFitThreshold = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.52 .4 .22 .2],'Tag','tFitThreshold','Fontsize',12,...
                                              'String','Fit(CoD):','HorizontalAlignment','left');           
                                          
hConfigGui.pGeneral.eFitThreshold = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','edit','Units','normalized',...
                                              'Position',[.78 .4 .15  .2],'Tag','eFitThreshold','Fontsize',12,...
                                              'String',num2str(Config.Threshold.Fit),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#cod');      
                                          
hConfigGui.pGeneral.tFWHM = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.52 .1 .25 .2],'Tag','tCurvatureThreshold','Fontsize',12,...
                                              'String','FWHM(Est.):','HorizontalAlignment','left');                                                     
                                          
hConfigGui.pGeneral.eFWHM = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','edit','Units','normalized',...
                                              'Position',[.78 .1 .15  .2],'Tag','eCurvatureThreshold','Fontsize',12,...
                                              'String',num2str(Config.Threshold.FWHM),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#fwhm');                                          
                                          
hConfigGui.pGeneral.tNM(2) = uicontrol('Parent',hConfigGui.pGeneral.pThreshold,'Style','text','Units','normalized',...
                                              'Position',[.93 .1 .06 .2],'Tag','tNM','Fontsize',12,...
                                              'String','nm','HorizontalAlignment','left');              
                                     
hConfigGui.pGeneral.pFilter = uipanel('Parent',hConfigGui.pGeneral.panel,'Units','normalized','Fontsize',10,...
                                         'Position',[.025 .03 .95 .16],'Tag','pThreshold','Visible','on','Title','Filter for thresholding (will be used for relative/constant intensity thresholding)');                                      
Value=0;                   
if strcmp(Config.Threshold.Filter,'none')==1
    Value=1;
end

hConfigGui.pGeneral.rFilterNone = uicontrol('Parent',hConfigGui.pGeneral.pFilter,'Style','radiobutton','Units','normalized',...
                                          'Position',[.025 .1 .3  .8],'Tag','rFilterNone','Fontsize',12,...
                                          'String','none','HorizontalAlignment','left','Value',Value,...
                                          'Callback','fConfigGui(''SetFilter'',getappdata(0,''hConfigGui''));',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');          
                                      
Value=0;                   
if strcmp(Config.Threshold.Filter,'average')==1
    Value=1;
end

hConfigGui.pGeneral.rFilterAverage = uicontrol('Parent',hConfigGui.pGeneral.pFilter,'Style','radiobutton','Units','normalized',...
                                          'Position',[.35 .1 .3  .8],'Tag','rFilterAverage','Fontsize',12,'Enable','on',...
                                          'String','Average before','HorizontalAlignment','left','Value',Value,...
                                          'Callback','fConfigGui(''SetFilter'',getappdata(0,''hConfigGui''));',...
                                          'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');    
Value=0;                   
if strcmp(Config.Threshold.Filter,'smooth')==1
    Value=1;
end

hConfigGui.pGeneral.rFilterSmooth = uicontrol('Parent',hConfigGui.pGeneral.pFilter,'Style','radiobutton','Units','normalized',...
                                          'Position',[.675 .1 .3  .8],'Tag','rFilterSmooth','Fontsize',12,...
                                          'String','Smooth after','HorizontalAlignment','left','Value',Value,...
                                          'Callback','fConfigGui(''SetFilter'',getappdata(0,''hConfigGui''));',...
                                          'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','General options.htm#intensity');                                                  
                                      
hConfigGui.pMolecules.panel = uipanel('Parent',hConfigGui.fig,'Units','normalized','Fontsize',12,'Bordertype','none',...
                                     'Position',[0 .06 1 0.54],'Tag','pNorm','Visible','on');

hConfigGui.pMolecules.tTrackingOptions = uicontrol('Parent',hConfigGui.pMolecules.panel,'Style','text','Units','normalized',...
                                   'Position',[.0 .955 1 .045],'Tag','ConfigGui.TrackingOptions','Fontsize',12,...
                                   'String','Tracking options','HorizontalAlignment','center','FontWeight','bold','Enable','on',...
                                   'BackgroundColor',[0 0 1],'ForegroundColor','white');                                 
                                 
hConfigGui.pMolecules.tMoleculesM = uicontrol('Parent',hConfigGui.pMolecules.panel,'Style','text','Units','normalized',...
                                   'Position',[.0 .91 .5 .045],'Tag','ConfigGui.tMoleculesM','Fontsize',12,...
                                   'String','Molecules','HorizontalAlignment','center','FontWeight','bold','Enable','on',...
                                   'BackgroundColor',[.5 .5 1],'ForegroundColor','white');
                                   
hConfigGui.pMolecules.tFilamentsM = uicontrol('Parent',hConfigGui.pMolecules.panel,'Style','text','Units','normalized',...
                                      'Position',[.5 .91 .5 .045],'Tag','ConfigGui.tFilamentsM','Fontsize',12,...
                                      'String','Filaments','HorizontalAlignment','center','BackgroundColor',[.5 .5 .5],...
                                      'FontWeight','bold','Enable','off',...
                                      'ButtonDownFcn','fConfigGui(''FilPanel'',getappdata(0,''hConfigGui''));');

hConfigGui.pMolecules.pConnect = uipanel('Parent',hConfigGui.pMolecules.panel,'Units','normalized','Fontsize',10,...
                                       'Position',[0.025 0.65 .575 .25],'Tag','pConnect','Visible','on','Title','Connecting');                                            

hConfigGui.pMolecules.tMaxVelocity = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                         'Position',[.025 .7 .25  .2],'Tag','tMaxVelocity','Fontsize',12,...
                                         'String','max. Velocity:','HorizontalAlignment','left');                             

hConfigGui.pMolecules.eMaxVelocity = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','edit','Units','normalized',...
                                         'Position',[.275 .7 .1  .2],'Tag','eMaxVelocity','Fontsize',10,...
                                         'String',num2str(Config.ConnectMol.MaxVelocity),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#max_velocity');                             

hConfigGui.pMolecules.tNMpS = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                    'Position',[.380 .7 .1  .2],'Tag','tNMpS','Fontsize',12,...
                                    'String','nm/s','HorizontalAlignment','left');           

hConfigGui.pMolecules.tNumVerification = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                         'Position',[.5 .7 .325  .2],'Tag','tNumVerification','Fontsize',12,...
                                         'String','Verification Steps:','HorizontalAlignment','left');                             

hConfigGui.pMolecules.eNumVerification = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','edit','Units','normalized',...
                                         'Position',[.85 .7 .1  .2],'Tag','eNumVerification','Fontsize',12,...
                                         'String',num2str(Config.ConnectMol.NumberVerification),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#num_verification');                                   
 
hConfigGui.pMolecules.tWeightPosition = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.225 .45 .2  .15],'Tag','tWeightMolecule','Fontsize',10,...
                                                    'String','Position','HorizontalAlignment','center'); 
                                                
hConfigGui.pMolecules.tWeightDirection = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.415 .45 .2  .15],'Tag','tWeightDirection','Fontsize',10,...
                                                    'String','Direction','HorizontalAlignment','center');  
                                                
hConfigGui.pMolecules.tWeightSpeed = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.605 .45 .2  .15],'Tag','tWeightSpeed','Fontsize',10,...
                                                    'String','Speed','HorizontalAlignment','center');  
                                                
hConfigGui.pMolecules.tWeightIntensity  = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.8 .45 .2  .15],'Tag','tWeightLength','Fontsize',10,...
                                                    'String','Intensity','HorizontalAlignment','center');   
                                                
hConfigGui.pMolecules.tWeights = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.025 .25 .2  .2],'Tag','tWeightMolecule','Fontsize',12,...
                                                    'String','Weights:','HorizontalAlignment','left');    
                                                
hConfigGui.pMolecules.eWeightPos = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.275 .27 .1  .18],'Tag','eWeightMolPos','Fontsize',10,...
                                              'String',num2str(Config.ConnectMol.Position*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');             
                                          
hConfigGui.pMolecules.tPercent(1) = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.375 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center');                                              
                                          
hConfigGui.pMolecules.eWeightDir = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.465 .27 .1  .18],'Tag','eWeightMolDir','Fontsize',10,...
                                              'String',num2str(Config.ConnectMol.Direction*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');      
                                          
hConfigGui.pMolecules.tPercent(2) = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.565 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center');                                              

hConfigGui.pMolecules.eWeightSpd = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.655 .27 .1  .18],'Tag','eWeightMolSpd','Fontsize',10,...
                                              'String',num2str(Config.ConnectMol.Speed*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');       
                                          
hConfigGui.pMolecules.tPercent(3) = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.755 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center');                                              
if Config.ConnectMol.UseIntensity==1
    enable='on';
else
    enable='off';
end

hConfigGui.pMolecules.eWeightInt = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.85 .27 .1  .18],'Tag','eWeightMolSpd','Fontsize',10,...
                                              'String',num2str(Config.ConnectMol.IntensityOrLength*100),'BackgroundColor','white','HorizontalAlignment','center','Enable',enable,...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');      
                                          
hConfigGui.pMolecules.tPercent(4) = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.95 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center','Enable',enable);  
                                          
hConfigGui.pMolecules.cActivateInt = uicontrol('Parent',hConfigGui.pMolecules.pConnect,'Style','checkbox','Units','normalized',...
                                              'Position',[.275 .05 .6  .18],'Tag','cActivateInt','Fontsize',10,'Value',Config.ConnectMol.UseIntensity,...
                                              'String','Use Intensity for connecting molecules','HorizontalAlignment','left',...
                                              'Callback','fConfigGui(''UseIntensity'',getappdata(0,''hConfigGui''));',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#use_intensity');       
                                          
hConfigGui.pMolecules.pTracks = uipanel('Parent',hConfigGui.pMolecules.panel,'Units','normalized','Fontsize',10,...
                                        'Position',[0.65 0.65 .325 .25],'Tag','pConnect','Visible','on','Title','Tracks');      
                                    
hConfigGui.pMolecules.tMinLength = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.025 .7 .6  .2],'Tag','tMinLength','Fontsize',12,...
                                         'String','Minimum Length:','HorizontalAlignment','left');                             

hConfigGui.pMolecules.eMinLength = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','edit','Units','normalized',...
                                         'Position',[.65 .7 .2  .2],'Tag','eMinLength','Fontsize',12,...
                                         'String',num2str(Config.ConnectMol.MinLength),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#min_length');              

hConfigGui.pMolecules.tMaxBreak = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.025 .4 .6  .2],'Tag','tMaxBreak','Fontsize',12,...
                                         'String','Maximum Break:','HorizontalAlignment','left');                             

hConfigGui.pMolecules.eMaxBreak = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','edit','Units','normalized',...
                                         'Position',[.65 .4 .2  .2],'Tag','eMaxBreak','Fontsize',12,...
                                         'String',num2str(Config.ConnectMol.MaxBreak),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#max_break');  
                                     
hConfigGui.pMolecules.tMaxAngle = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.025 .1 .6  .2],'Tag','tMaxAngle','Fontsize',12,...
                                         'String','Maximum Angle:','HorizontalAlignment','left');                             

hConfigGui.pMolecules.eMaxAngle = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','edit','Units','normalized',...
                                         'Position',[.65 .1 .2  .2],'Tag','eMaxAngle','Fontsize',12,...
                                         'String',num2str(Config.ConnectMol.MaxAngle),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#max_angle');                   
                                     
hConfigGui.pMolecules.tDeg = uicontrol('Parent',hConfigGui.pMolecules.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.865 .1 .1  .2],'Tag','tDeg','Fontsize',14,...
                                         'String','°','HorizontalAlignment','left');                                  
                                     
hConfigGui.pMolecules.pModel = uipanel('Parent',hConfigGui.pMolecules.panel,'Units','normalized','Fontsize',10,...
                                       'Position',[0.025 0.025 .95 .6],'Tag','pModel','Visible','on','Title','Model');      
                                      
hConfigGui.pMolecules.tMaxFunc = uicontrol('Parent',hConfigGui.pMolecules.pModel,'Style','text','Units','normalized',...
                                         'Position',[.025 .9 .3 .075],'Tag','tMaxFunc','Fontsize',12,...
                                         'String','Maximum Number of functions:','HorizontalAlignment','left');                                 

hConfigGui.pMolecules.eMaxFunc = uicontrol('Parent',hConfigGui.pMolecules.pModel,'Style','edit','Units','normalized',...
                                         'Position',[.325 .9 .05 .075],'Tag','eMaxFunc','Fontsize',12,...
                                         'String',num2str(Config.MaxFunc),'BackgroundColor','white',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,...
                                         'UserData','Tracking options.htm#model',...
                                         'Callback','fConfigGui(''UpdateParams'',getappdata(0,''hConfigGui''));'); 

hConfigGui.pMolecules.tParams = uicontrol('Parent',hConfigGui.pMolecules.pModel,'Style','text','Units','normalized',...
                                         'Position',[.4 .9 .1 .075],'Tag','tMaxFunc','Fontsize',12,...
                                         'String','Parameter:','HorizontalAlignment','left');                                 

hConfigGui.pMolecules.eParams = uicontrol('Parent',hConfigGui.pMolecules.pModel,'Style','edit','Units','normalized',...
                                         'Position',[.525 .9 .05 .075],'Tag','eMaxFunc','Fontsize',12,...
                                         'String','','Enable','inactive',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#model');                                      

%define available models
str={'Symmetric 2D-Gaussian',...
     'Streched 2D-Gaussian',...
     'Symmetric 2D-Gaussian plus Gaussian Ring',...
     'Symmetric 2D-Gaussian plus two opposing Gaussian Rings'};

hConfigGui.pMolecules.mModel = uicontrol('Parent',hConfigGui.pMolecules.pModel,'Style','popupmenu','Units','normalized',...
                                          'Position',[.025 .8 .55 .075],'Tag','rSymmetricGauss','Fontsize',12,'String',str,...
                                          'Callback','fConfigGui(''ShowModel'',getappdata(0,''hConfigGui''));','Value',0,...
                                          'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,...
                                          'UserData','Tracking options.htm#model','BackgroundColor','white');    
                                      
if strcmp(Config.Model,'GaussSymmetric')
    set(hConfigGui.pMolecules.mModel,'Value',1);
elseif strcmp(Config.Model,'GaussStreched')
    set(hConfigGui.pMolecules.mModel,'Value',2);
elseif strcmp(Config.Model,'GaussPlusRing')
    set(hConfigGui.pMolecules.mModel,'Value',3);    
else
    set(hConfigGui.pMolecules.mModel,'Value',4);
end

hConfigGui.pMolecules.aModelLabel = axes('Parent',hConfigGui.pMolecules.pModel,'Units','normalized',....
                                            'Position',[0.025 .325 .55 .4],'Tag','aModelLabel','Visible','off');  

hConfigGui.pMolecules.aModelPreview = axes('Parent',hConfigGui.pMolecules.pModel,'Units','normalized',....
                                            'Position',[.55 .325 .45 .55],'Tag','aModelPreview','Visible','off');     
                                        
hConfigGui.pMolecules.aModelEquation = axes('Parent',hConfigGui.pMolecules.pModel,'Units','normalized',....
                                            'Position',[0.025 .025 .95 .225],'Tag','aModelEquation','Visible','off');         

ShowModel(hConfigGui);

hConfigGui.pFilaments.panel = uipanel('Parent',hConfigGui.fig,'Units','normalized','Fontsize',12,'Bordertype','none',...
                                     'Position',[0 .06 1 0.54],'Tag','pNorm','Visible','off');

hConfigGui.pFilaments.tTrackingOptions = uicontrol('Parent',hConfigGui.pFilaments.panel,'Style','text','Units','normalized',...
                                   'Position',[.0 .955 1 .045],'Tag','ConfigGui.tTrackingOptions','Fontsize',12,...
                                   'String','Tracking options','HorizontalAlignment','center','FontWeight','bold','Enable','on',...
                                   'BackgroundColor',[0 0 1],'ForegroundColor','white');                                 
                               
hConfigGui.pFilaments.tMoleculesM = uicontrol('Parent',hConfigGui.pFilaments.panel,'Style','text','Units','normalized',...
                                     'Position',[.0 .91 .5 .045],'Tag','ConfigGui.tMoleculesM','Fontsize',12,...
                                     'String','Molecules','HorizontalAlignment','center','BackgroundColor',[.5 .5 .5],...
                                     'FontWeight','bold','Enable','off',...
                                     'ButtonDownFcn','fConfigGui(''MolPanel'',getappdata(0,''hConfigGui''));');
  
                                   
hConfigGui.pFilaments.tFilamentsM = uicontrol('Parent',hConfigGui.pFilaments.panel,'Style','text','Units','normalized',...
                                      'Position',[.5 .91 .5 .045],'Tag','ConfigGui.tFilamentsM','Fontsize',12,...
                                      'String','Filaments','HorizontalAlignment','center','FontWeight','bold','Enable','on',...
                                      'BackgroundColor',[.5 .5 1],'ForegroundColor','white');

hConfigGui.pFilaments.pConnect = uipanel('Parent',hConfigGui.pFilaments.panel,'Units','normalized','Fontsize',10,...
                                       'Position',[0.025 0.65 .575 .25],'Tag','pConnect','Visible','on','Title','Connecting');                                            

hConfigGui.pFilaments.tMaxVelocity = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                         'Position',[.025 .7 .25  .2],'Tag','tMaxVelocity','Fontsize',12,...
                                         'String','Maximum Velocity:','HorizontalAlignment','left');                             

hConfigGui.pFilaments.eMaxVelocity = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','edit','Units','normalized',...
                                         'Position',[.275 .7 .1  .2],'Tag','eMaxVelocity','Fontsize',12,...
                                         'String',num2str(Config.ConnectFil.MaxVelocity),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#max_velocity');                                   

hConfigGui.pFilaments.tNMpS = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                    'Position',[.380 .7 .1  .2],'Tag','tNMpS','Fontsize',12,...
                                    'String','nm/s','HorizontalAlignment','left');        
                                
hConfigGui.pFilaments.tNumVerification = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                         'Position',[.5 .7 .325  .2],'Tag','tNumVerification','Fontsize',12,...
                                         'String','Number of verification steps:','HorizontalAlignment','left');                             

hConfigGui.pFilaments.eNumVerification = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','edit','Units','normalized',...
                                         'Position',[.85 .7 .1  .2],'Tag','eNumVerification','Fontsize',12,...
                                         'String',num2str(Config.ConnectFil.NumberVerification),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#num_verification');                                 
 
hConfigGui.pFilaments.tWeightPosition = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.225 .45 .2  .15],'Tag','tWeightMolecule','Fontsize',10,...
                                                    'String','Position','HorizontalAlignment','center'); 
                                                
hConfigGui.pFilaments.tWeightDirection = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.415 .45 .2  .15],'Tag','tWeightDirection','Fontsize',10,...
                                                    'String','Direction','HorizontalAlignment','center');  
                                                
hConfigGui.pFilaments.tWeightSpeed = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.605 .45 .2  .15],'Tag','tWeightSpeed','Fontsize',10,...
                                                    'String','Speed','HorizontalAlignment','center');  
                                                
hConfigGui.pFilaments.tWeightLength  = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.8 .45 .2  .15],'Tag','tWeightLength','Fontsize',10,...
                                                    'String','Length','HorizontalAlignment','center');   
                                                
hConfigGui.pFilaments.tWeights = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                                    'Position',[.025 .25 .2  .2],'Tag','tWeightFilament','Fontsize',12,...
                                                    'String','Weights:','HorizontalAlignment','left');    
                                                
hConfigGui.pFilaments.eWeightPos = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','edit','Units','normalized',...
                                                'Position',[.275 .27 .1  .18],'Tag','eWeightFilPos','Fontsize',10,...
                                                'String',num2str(Config.ConnectFil.Position*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                                'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');                                                          

hConfigGui.pFilaments.tPercent(1) = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.375 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center');                     
                                          
hConfigGui.pFilaments.eWeightDir = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.465 .27 .1  .18],'Tag','eWeightFilDir','Fontsize',10,...
                                              'String',num2str(Config.ConnectFil.Direction*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');  
                                          
hConfigGui.pFilaments.tPercent(2) = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.565 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center');                                                
                                          
hConfigGui.pFilaments.eWeightSpd = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.655 .27 .1  .18],'Tag','eWeightFilSpd','Fontsize',10,...
                                              'String',num2str(Config.ConnectFil.Speed*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');  
                                          
hConfigGui.pFilaments.tPercent(3) = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.755 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center');                                                
                                          
hConfigGui.pFilaments.eWeightLen = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','edit','Units','normalized',...
                                              'Position',[.85 .27 .1  .18],'Tag','eWeightFilLen','Fontsize',10,...
                                              'String',num2str(Config.ConnectFil.IntensityOrLength*100),'BackgroundColor','white','HorizontalAlignment','center',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#weights');          
                                          
hConfigGui.pFilaments.tPercent(4) = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','text','Units','normalized',...
                                              'Position',[.95 .25 .04  .18],'Tag','tPercent','Fontsize',10,...
                                              'String','%','HorizontalAlignment','center');            
                                       
hConfigGui.pFilaments.cDisregardEdge = uicontrol('Parent',hConfigGui.pFilaments.pConnect,'Style','checkbox','Units','normalized',...
                                              'Position',[.275 .05 .6  .18],'Tag','cDisregardEdge','Fontsize',10,'Value',Config.ConnectFil.DisregardEdge,...
                                              'String','Disregard filaments at the edge of the field of view','HorizontalAlignment','left',...
                                              'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#disregard_edge');      
                                          
hConfigGui.pFilaments.pTracks = uipanel('Parent',hConfigGui.pFilaments.panel,'Units','normalized','Fontsize',10,...
                                        'Position',[0.65 0.65 .325 .25],'Tag','pConnect','Visible','on','Title','Tracks');      
                                    
hConfigGui.pFilaments.tMinLength = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.025 .7 .6  .2],'Tag','tMinLength','Fontsize',12,...
                                         'String','Minimum Length:','HorizontalAlignment','left');                             

hConfigGui.pFilaments.eMinLength = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','edit','Units','normalized',...
                                         'Position',[.65 .7 .2  .2],'Tag','eMinLength','Fontsize',12,...
                                         'String',num2str(Config.ConnectFil.MinLength),'BackgroundColor','white','HorizontalAlignment','center',...
                                                'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#min_length');          

hConfigGui.pFilaments.tMaxBreak = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.025 .4 .6  .2],'Tag','tMaxBreak','Fontsize',12,...
                                         'String','Maximum Break:','HorizontalAlignment','left');                             

hConfigGui.pFilaments.eMaxBreak = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','edit','Units','normalized',...
                                         'Position',[.65 .4 .2  .2],'Tag','eMaxBreak','Fontsize',12,...
                                         'String',num2str(Config.ConnectFil.MaxBreak),'BackgroundColor','white','HorizontalAlignment','center',...
                                                'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#max_break');       
                                            
hConfigGui.pFilaments.tMaxAngle = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.025 .1 .6  .2],'Tag','tMaxAngle','Fontsize',12,...
                                         'String','Maximum Angle:','HorizontalAlignment','left');                             

hConfigGui.pFilaments.eMaxAngle = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','edit','Units','normalized',...
                                         'Position',[.65 .1 .2  .2],'Tag','eMaxAngle','Fontsize',12,...
                                         'String',num2str(Config.ConnectFil.MaxAngle),'BackgroundColor','white','HorizontalAlignment','center',...
                                         'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#max_angle');                   
                                     
hConfigGui.pFilaments.tDeg = uicontrol('Parent',hConfigGui.pFilaments.pTracks,'Style','text','Units','normalized',...
                                         'Position',[.865 .1 .1  .2],'Tag','tDeg','Fontsize',14,...
                                         'String','°','HorizontalAlignment','left');                                             
                                                                           
hConfigGui.pFilaments.pRefPoint = uipanel('Parent',hConfigGui.pFilaments.panel,'Units','normalized','Fontsize',10,...
                                             'Position',[0.025 0.505 .95 .12],'Tag','pConnect','Visible','on','Title','Reference Point');       

Value=0;                   
if strcmp(Config.RefPoint,'start')==1
    Value=1;
end

hConfigGui.pRefPoint.rStart = uicontrol('Parent',hConfigGui.pFilaments.pRefPoint,'Style','radiobutton','Units','normalized',...
                                        'Position',[.025 .1 .3  .8],'Tag','rStart','Fontsize',12,...
                                        'String','Start Point','HorizontalAlignment','left','Value',Value,...
                                        'Callback','fConfigGui(''SetRefPoint'',getappdata(0,''hConfigGui''));',...
                                        'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#reference_point');               
                                      
Value=0;                   
if strcmp(Config.RefPoint,'center')==1
    Value=1;
end

hConfigGui.pRefPoint.rCenter = uicontrol('Parent',hConfigGui.pFilaments.pRefPoint,'Style','radiobutton','Units','normalized',...
                                        'Position',[.35 .1 .3  .8],'Tag','rCenter','Fontsize',12,...
                                        'String','Center Point','HorizontalAlignment','left','Value',Value,...
                                        'Callback','fConfigGui(''SetRefPoint'',getappdata(0,''hConfigGui''));',...
                                        'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#reference_point');                  
Value=0;                   
if strcmp(Config.RefPoint,'end')==1
    Value=1;
end

hConfigGui.pRefPoint.rEnd = uicontrol('Parent',hConfigGui.pFilaments.pRefPoint,'Style','radiobutton','Units','normalized',...
                                        'Position',[.675 .1 .3  .8],'Tag','rEnd','Fontsize',12,...
                                        'String','End Point','HorizontalAlignment','left','Value',Value,...
                                        'Callback','fConfigGui(''SetRefPoint'',getappdata(0,''hConfigGui''));',...
                                        'TooltipString','Right click for Help','UIContextMenu',hConfigGui.mHelpContext,'UserData','Tracking options.htm#reference_point');                                                             
                                      
hConfigGui.pButtons = uipanel('Parent',hConfigGui.fig,'Units','normalized','Fontsize',12,'Bordertype','none',...
                                     'Position',[0 0 1 0.06],'Tag','pNorm','Visible','on');
                                 
hConfigGui.bApply = uicontrol('Parent',hConfigGui.pButtons,'Style','pushbutton','Units','normalized',...
                              'Position',[.5 .2 .2 .7],'Tag','bOkay','Fontsize',12,...
                              'String','Apply','Callback','fConfigGui(''OK'',getappdata(0,''hConfigGui''));');                       
                          
hConfigGui.bCancel= uicontrol('Parent',hConfigGui.pButtons,'Style','pushbutton','Units','normalized',...
                              'Position',[.75 .2 .2 .7],'Tag','bCancel','Fontsize',12,...
                              'String','Cancel','Callback','close(findobj(0,''Tag'',''hConfigGui''));');                          
                                  
set(hConfigGui.fig, 'CloseRequestFcn',@Close);                          
setappdata(0,'hConfigGui',hConfigGui);

function Close(hObject,eventdata)
delete(findobj('Tag','hConfigGui'));
fShared('ReturnFocus');


function MolPanel(hConfigGui)
set(hConfigGui.pMolecules.panel,'Visible','on');
set(hConfigGui.pFilaments.panel,'Visible','off');

function FilPanel(hConfigGui)
set(hConfigGui.pMolecules.panel,'Visible','off');
set(hConfigGui.pFilaments.panel,'Visible','on');

function OnlyTrack(hConfigGui)
if get(gcbo,'Value')==1
    if gcbo==hConfigGui.pGeneral.cMolFull
        set(hConfigGui.pGeneral.cMolLeft,'Value',0);
        set(hConfigGui.pGeneral.cMolRight,'Value',0);
        set(hConfigGui.pGeneral.cFilFull,'Value',0);
        set(hConfigGui.pGeneral.cFilLeft,'Value',0);
        set(hConfigGui.pGeneral.cFilRight,'Value',0);
    elseif gcbo==hConfigGui.pGeneral.cMolLeft||gcbo==hConfigGui.pGeneral.cFilRight
        set(hConfigGui.pGeneral.cMolFull,'Value',0);
        set(hConfigGui.pGeneral.cMolRight,'Value',0);
        set(hConfigGui.pGeneral.cFilFull,'Value',0);  
        set(hConfigGui.pGeneral.cFilLeft,'Value',0);
    elseif gcbo==hConfigGui.pGeneral.cMolRight||gcbo==hConfigGui.pGeneral.cFilLeft
        set(hConfigGui.pGeneral.cMolFull,'Value',0);
        set(hConfigGui.pGeneral.cMolLeft,'Value',0);
        set(hConfigGui.pGeneral.cFilFull,'Value',0);  
        set(hConfigGui.pGeneral.cFilRight,'Value',0);
    elseif gcbo==hConfigGui.pGeneral.cFilFull
        set(hConfigGui.pGeneral.cMolLeft,'Value',0);
        set(hConfigGui.pGeneral.cMolRight,'Value',0);
        set(hConfigGui.pGeneral.cMolFull,'Value',0);
        set(hConfigGui.pGeneral.cFilLeft,'Value',0);
        set(hConfigGui.pGeneral.cFilRight,'Value',0);
    end
end

function UseIntensity(hConfigGui)
if get(gcbo,'Value')==1
    set(hConfigGui.pMolecules.eWeightInt,'Enable','on');
else
    set(hConfigGui.pMolecules.eWeightInt,'Enable','off');
end

function SetThreshold(hConfigGui)
if gcbo==hConfigGui.pGeneral.rVariable
    set(hConfigGui.pGeneral.rVariable,'Value',1);
    set(hConfigGui.pGeneral.rConstant,'Value',0);
    set(hConfigGui.pGeneral.rRelative,'Value',0);
elseif gcbo==hConfigGui.pGeneral.rConstant
    set(hConfigGui.pGeneral.rVariable,'Value',0);
    set(hConfigGui.pGeneral.rConstant,'Value',1);
    set(hConfigGui.pGeneral.rRelative,'Value',0);
else
    set(hConfigGui.pGeneral.rVariable,'Value',0);
    set(hConfigGui.pGeneral.rConstant,'Value',0);
    set(hConfigGui.pGeneral.rRelative,'Value',1);
end
 
function SetFilter(hConfigGui)
if gcbo==hConfigGui.pGeneral.rFilterNone
    set(hConfigGui.pGeneral.rFilterNone,'Value',1);
    set(hConfigGui.pGeneral.rFilterAverage,'Value',0);
    set(hConfigGui.pGeneral.rFilterSmooth,'Value',0);
elseif gcbo==hConfigGui.pGeneral.rFilterAverage
    set(hConfigGui.pGeneral.rFilterNone,'Value',0);
    set(hConfigGui.pGeneral.rFilterAverage,'Value',1);
    set(hConfigGui.pGeneral.rFilterSmooth,'Value',0);
else
    set(hConfigGui.pGeneral.rFilterNone,'Value',0);
    set(hConfigGui.pGeneral.rFilterAverage,'Value',0);
    set(hConfigGui.pGeneral.rFilterSmooth,'Value',1);
end

function SetRefPoint(hConfigGui)
if gcbo==hConfigGui.pRefPoint.rStart
    set(hConfigGui.pRefPoint.rStart,'Value',1);
    set(hConfigGui.pRefPoint.rCenter,'Value',0);
    set(hConfigGui.pRefPoint.rEnd,'Value',0);
elseif gcbo==hConfigGui.pRefPoint.rCenter
    set(hConfigGui.pRefPoint.rStart,'Value',0);
    set(hConfigGui.pRefPoint.rCenter,'Value',1);
    set(hConfigGui.pRefPoint.rEnd,'Value',0);
else
    set(hConfigGui.pRefPoint.rStart,'Value',0);
    set(hConfigGui.pRefPoint.rCenter,'Value',0);
    set(hConfigGui.pRefPoint.rEnd,'Value',1);
end    

function ConfigGuiOK(hConfigGui)
global Config;
global Filament;
hMainGui=getappdata(0,'hMainGui');

err=[];

Config.PixSize=str2double(get(hConfigGui.pGeneral.ePixSize,'String'));
if Config.PixSize<=0||isnan(Config.PixSize)
    err{length(err)+1}='Wrong pixel size input';
else
    hMainGui.Values.PixSize=Config.PixSize;
end

if strcmp(Config.StackType,'TIFF')==1
    Config.Time = str2double(get(hConfigGui.pGeneral.eTimeDiff,'String'));
    if Config.Time<=0||isnan(Config.Time)
        err{length(err)+1}='Wrong time difference input for TIFF file';
    else
        StackInfo=getappdata(hMainGui.fig,'StackInfo');
        for i=0:length(StackInfo)-1
            StackInfo(i+1).CreationTime=(i*Config.Time); %#ok<AGROW>
        end
        setappdata(hMainGui.fig,'StackInfo',StackInfo);
    end
end

Config.FirstTFrame=round(str2double(get(hConfigGui.pGeneral.eFirstFrame,'String')));
if Config.FirstTFrame<0||isnan(Config.FirstTFrame)||Config.FirstTFrame>hMainGui.Values.MaxIdx
    err{length(err)+1}='First frame input wrong or out of range';
else
    Config.FirstCFrame=Config.FirstTFrame;
end

Config.LastFrame=str2double(get(hConfigGui.pGeneral.eLastFrame,'String'));
if Config.LastFrame<0||isnan(Config.LastFrame)||Config.LastFrame>hMainGui.Values.MaxIdx
    err{length(err)+1}='Last frame input wrong or out of range';
elseif Config.FirstTFrame<0||isnan(Config.FirstTFrame)
    err{length(err)+1}='First frame input wrong or out of range';    
end

Config.OnlyTrack.MolFull=get(hConfigGui.pGeneral.cMolFull,'Value');
Config.OnlyTrack.MolLeft=get(hConfigGui.pGeneral.cMolLeft,'Value');
Config.OnlyTrack.MolRight=get(hConfigGui.pGeneral.cMolRight,'Value');
Config.OnlyTrack.FilFull=get(hConfigGui.pGeneral.cFilFull,'Value');
Config.OnlyTrack.FilLeft=get(hConfigGui.pGeneral.cFilLeft,'Value');
Config.OnlyTrack.FilRight=get(hConfigGui.pGeneral.cFilRight,'Value');

Config.Threshold.Area=str2double(get(hConfigGui.pGeneral.eAreaThreshold,'String'));
if Config.Threshold.Area<=0||isnan(Config.Threshold.Area)
    err{length(err)+1}='Wrong area threshold input';
end

Config.Threshold.Height=str2double(get(hConfigGui.pGeneral.eHeightThreshold,'String'));
if Config.Threshold.Height<=0||isnan(Config.Threshold.Height)
    err{length(err)+1}='Wrong height threshold input';
end

Config.Threshold.Fit=str2double(get(hConfigGui.pGeneral.eFitThreshold,'String'));
if Config.Threshold.Fit<-1||isnan(Config.Threshold.Area)||Config.Threshold.Fit>1
    err{length(err)+1}='Coefficient of determination must be between -1 and 1';
end

Config.Threshold.FWHM=str2double(get(hConfigGui.pGeneral.eFWHM,'String'));
if Config.Threshold.FWHM<=0||isnan(Config.Threshold.FWHM)
     err{length(err)+1}='Wrong FWHM estimate input';
end

if Config.Threshold.FWHM<2*Config.PixSize
     err{length(err)+1}='FWHM estimate is smaller than 2 pixels';
end

if get(hConfigGui.pGeneral.rConstant,'Value')==1
    Config.Threshold.Mode='Constant';
end
if get(hConfigGui.pGeneral.rRelative,'Value')==1
    Config.Threshold.Mode='Relative';
end
if get(hConfigGui.pGeneral.rVariable,'Value')==1
    Config.Threshold.Mode='Variable';
end
fLeftPanel('SetThresh',hMainGui,Config.Threshold.Mode);    
   
r=get(hConfigGui.pGeneral.pFilter,'Children');
k=find(cell2mat(get(r,'Value'))==1,1);
tag=get(r(k),'Tag');
if strcmp( tag, 'rFilterAverage' )
  Config.Threshold.Filter='average';
elseif strcmp( tag, 'rFilterSmooth' )
  Config.Threshold.Filter='smooth';  
else
  Config.Threshold.Filter='none';
end

Config.ConnectMol.MaxVelocity=str2double(get(hConfigGui.pMolecules.eMaxVelocity,'String'));
if Config.ConnectMol.MaxVelocity<=0||isnan(Config.ConnectMol.MaxVelocity)
     err{length(err)+1}='Wrong maximum velocity input for molecules';
end

Config.ConnectMol.NumberVerification=str2double(get(hConfigGui.pMolecules.eNumVerification,'String'));
if Config.ConnectMol.NumberVerification<=0||isnan(Config.ConnectMol.NumberVerification)
     err{length(err)+1}='Wrong number fo verification input for molecules';
end

Config.ConnectMol.Position=str2double(get(hConfigGui.pMolecules.eWeightPos,'String'))/100;
if Config.ConnectMol.Position<0||isnan(Config.ConnectMol.Position)
     err{length(err)+1}='Wrong position weight input for molecules';
end

Config.ConnectMol.Direction=str2double(get(hConfigGui.pMolecules.eWeightDir,'String'))/100;
if Config.ConnectMol.Direction<0||isnan(Config.ConnectMol.Direction)
     err{length(err)+1}='Wrong direction weight input for molecules';
end

Config.ConnectMol.Speed=str2double(get(hConfigGui.pMolecules.eWeightSpd,'String'))/100;
if Config.ConnectMol.Speed<0||isnan(Config.ConnectMol.Speed)
    err{length(err)+1}='Wrong speed weight input for molecules';
end

Config.ConnectMol.UseIntensity=get(hConfigGui.pMolecules.cActivateInt,'Value');

if Config.ConnectMol.UseIntensity==1
    Config.ConnectMol.IntensityOrLength=str2double(get(hConfigGui.pMolecules.eWeightInt,'String'))/100;
    if Config.ConnectMol.IntensityOrLength<0||isnan(Config.ConnectMol.IntensityOrLength)
        err{length(err)+1}='Wrong intensity weight input for molecules';
    end
else
    Config.ConnectMol.IntensityOrLength=0;
end

if abs(Config.ConnectMol.Position+Config.ConnectMol.Direction+Config.ConnectMol.Speed+Config.ConnectMol.IntensityOrLength-1.0)>1e-8
    err{length(err)+1}='Connecting weights for molecules do not equal 100%';
end

Config.ConnectMol.MinLength=str2double(get(hConfigGui.pMolecules.eMinLength,'String'));
if Config.ConnectMol.MinLength<=0||isnan(Config.ConnectMol.MinLength)
    err{length(err)+1}='Wrong minimum length input for molecules';
end

Config.ConnectMol.MaxBreak=str2double(get(hConfigGui.pMolecules.eMaxBreak,'String'));
if Config.ConnectMol.MaxBreak<=0||isnan(Config.ConnectMol.MaxBreak)
    err{length(err)+1}='Wrong maximum break input for molecules';
end

Config.ConnectMol.MaxAngle=str2double(get(hConfigGui.pMolecules.eMaxAngle,'String'));
if Config.ConnectMol.MaxAngle<=0||isnan(Config.ConnectMol.MaxAngle)
    err{length(err)+1}='Wrong maximum angle input for molecules';
end

Config.MaxFunc=str2double(get(hConfigGui.pMolecules.eMaxFunc,'String'));
if Config.ConnectMol.MaxBreak<=0||isnan(Config.ConnectMol.MaxBreak)
    err{length(err)+1}='Wrong maximum function input for molecules';
end

warn='continue';
if str2double(get(hConfigGui.pMolecules.eParams,'String'))>20
    warn = questdlg({'Number of fitting parameters exceeds 20,','fitting might take very long time!'} ,'FIESTA Warning','change','continue','change');
end

switch(get(hConfigGui.pMolecules.mModel,'Value'))
    case 1
        Config.Model='GaussSymmetric';
    case 2 
        Config.Model='GaussStreched';
    case 3
        Config.Model='GaussPlusRing';
    case 4
        Config.Model='GaussPlus2Rings';
end

Config.ConnectFil.MaxVelocity=str2double(get(hConfigGui.pFilaments.eMaxVelocity,'String'));
if Config.ConnectFil.MaxVelocity<=0||isnan(Config.ConnectFil.MaxVelocity)
     err{length(err)+1}='Wrong maximum velocity input for microtubules';
end

Config.ConnectFil.NumberVerification=str2double(get(hConfigGui.pFilaments.eNumVerification,'String'));
if Config.ConnectFil.NumberVerification<=0||isnan(Config.ConnectFil.NumberVerification)
     err{length(err)+1}='Wrong number fo verification input for microtubules';
end

Config.ConnectFil.Position=str2double(get(hConfigGui.pFilaments.eWeightPos,'String'))/100;
if Config.ConnectFil.Position<0||isnan(Config.ConnectFil.Position)
     err{length(err)+1}='Wrong position weight input for microtubules';
end

Config.ConnectFil.Direction=str2double(get(hConfigGui.pFilaments.eWeightDir,'String'))/100;
if Config.ConnectFil.Direction<0||isnan(Config.ConnectFil.Direction)
     err{length(err)+1}='Wrong direction weight input for microtubules';
end

Config.ConnectFil.Speed=str2double(get(hConfigGui.pFilaments.eWeightSpd,'String'))/100;
if Config.ConnectFil.Speed<0||isnan(Config.ConnectFil.Speed)
    err{length(err)+1}='Wrong speed weight input for microtubules';
end

Config.ConnectFil.IntensityOrLength=str2double(get(hConfigGui.pFilaments.eWeightLen,'String'))/100;
if Config.ConnectFil.IntensityOrLength<0||isnan(Config.ConnectFil.IntensityOrLength)
    err{length(err)+1}='Wrong length weight input for microtubules';
end

if abs(Config.ConnectFil.Position+Config.ConnectFil.Direction+Config.ConnectFil.Speed+Config.ConnectFil.IntensityOrLength-1.0)>1e-8
    err{length(err)+1}='Connecting weights for microtubules do not equal 100%';
end

Config.ConnectFil.DisregardEdge=get(hConfigGui.pFilaments.cDisregardEdge,'Value');

Config.ConnectFil.MinLength=str2double(get(hConfigGui.pFilaments.eMinLength,'String'));
if Config.ConnectFil.MinLength<=0||isnan(Config.ConnectFil.MinLength)
    err{length(err)+1}='Wrong minimum length input for microtubules';
end

Config.ConnectFil.MaxBreak=str2double(get(hConfigGui.pFilaments.eMaxBreak,'String'));
if Config.ConnectFil.MaxBreak<=0||isnan(Config.ConnectFil.MaxBreak)
    err{length(err)+1}='Wrong maximum break input for microtubules';
end

Config.ConnectFil.MaxAngle=str2double(get(hConfigGui.pFilaments.eMaxAngle,'String'));
if Config.ConnectFil.MaxAngle<=0||isnan(Config.ConnectFil.MaxAngle)
    err{length(err)+1}='Wrong maximum angle input for microtubules';
end

if get(hConfigGui.pRefPoint.rStart,'Value')==1&&strcmp(Config.RefPoint,'start')==0
    Config.RefPoint='start';
    nFil=length(Filament);
    for i=1:nFil
        Filament(i).Results=Filament(i).ResultsStart;
    end
end    

if get(hConfigGui.pRefPoint.rCenter,'Value')==1&&strcmp(Config.RefPoint,'center')==0
    Config.RefPoint='center';
    nFil=length(Filament);
    for i=1:nFil
        Filament(i).Results=Filament(i).ResultsCenter;
    end
end  

if get(hConfigGui.pRefPoint.rEnd,'Value')==1&&strcmp(Config.RefPoint,'end')==0
    Config.RefPoint='end';
    nFil=length(Filament);
    for i=1:nFil
        Filament(i).Results=Filament(i).ResultsEnd;
    end
end  

if isempty(err)&&strcmp(warn,'continue')
    setappdata(0,'hMainGui',hMainGui);    

    close(findobj('Tag','hConfigGui'));
    fShow('Image');
else
    if ~isempty(err);
        errordlg(err,'FIESTA Error');
    end
end
fShared('ReturnFocus');

function Help
openhelp(sprintf('content\\GUI\\Configuration\\%s',get(gco,'UserData')));

function UpdateParams(hConfigGui)
n=round(str2double(get(hConfigGui.pMolecules.eMaxFunc,'String')));
set(hConfigGui.pMolecules.eMaxFunc,'String',num2str(n));
if n>0
    switch(get(hConfigGui.pMolecules.mModel,'Value'))
        case 1
            params=n*4;
        case 2
            params=n*6;            
        case 3
            params=n*7;                 
        case 4
            params=n*10;            
    end
    set(hConfigGui.pMolecules.eParams,'String',num2str(params));
    if params>20
        set(hConfigGui.pMolecules.eParams,'BackgroundColor','red');
    else
        set(hConfigGui.pMolecules.eParams,'BackgroundColor',get(hConfigGui.pMolecules.pModel,'BackgroundColor'));
    end
else
   set(hConfigGui.pMolecules.eParams,'String','','BackgroundColor','red');    
   set(hConfigGui.pMolecules.eMaxFunc,'String','');       
end

function ShowModel(hConfigGui)
n=str2double(get(hConfigGui.pMolecules.eMaxFunc,'String'));
[X,Y] = meshgrid(-10:1:10);
if n>0
    label=[];
    label2=[];
    label{1}='$$h$$ ... Height of Peak';                        
    label{2}='$$\hat{x}$$ ... X Position of Center';
    label{3}='$$\hat{y}$$ ... Y Position of Center';
    switch(get(hConfigGui.pMolecules.mModel,'Value'))
        case 1
            equation='$$I(x,y) = \frac{h}{2\pi\sigma^2} \cdot \exp\left[ -\frac{(x-\hat{x})^2+(y-\hat{y})^2}{2\sigma^2}\right]$$';
            label{4}='$$\sigma$$ ... Width of Peak';
            Z=Calc2DPeakCircle(X,Y);
        case 2
            label{4}='$$\sigma_x$$ ... Width in X Direction';
            label{5}='$$\sigma_y$$ ... Width in Y Direction';
            label{6}='$$\rho$$ ... Orientation';
            equation='$$I(x,y) = \frac{h}{2\pi\sigma_x\sigma_x\sqrt{1-\rho^2}} \cdot \exp \left[ -\frac{1}{(1-\rho^2)} \left( \frac{(x-\hat{x})^2}{2\sigma^2_x} -\rho\,\frac{(x-\hat{x})}{\sigma_x}\,\frac{(y-\hat{y})}{\sigma_y}+ \frac{(y-\hat{y})^2}{2\sigma^2_y}\right)\right]$$';
            Z=Calc2DPeakEllipses(X,Y);
        case 3
            label{4}='$$\sigma$$ ... Width of Peak';
            label2{1}='$$h_r$$ ... Height of Ring';
            label2{2}='$$r$$ ... Radius of Ring';            
            label2{3}='$$\sigma_r$$ ... Width of Ring';
            equation='$$I(x,y) = \frac{h}{2\pi\sigma^2} \cdot \exp \left[ -\frac{(x-\hat{x})^2+(y-\hat{y})^2}{2\sigma^2}  \right]+\frac{h_r}{2\pi\sigma^2} \cdot \exp\left[ -\frac{\left(\sqrt{ (x-\hat{x})^2+(y-\hat{y})^2}-r\right)^2}{2\sigma^2_r} \right]$$';
            Z=Calc2DPeakRing(X,Y);         
        case 4
            label{4}='$$\sigma$$ ... Width of Peak';
            label2{1}='$$h_{r,1}$$ ... Height of first Ring';
            label2{2}='$$r_1$$ ... Radius of first Ring';            
            label2{3}='$$\sigma_{r,1}$$ ... Width of first Ring';            
            label2{4}='$$h_{r,2}$$ ... Height of second Ring';
            label2{5}='$$r_2$$ ... Radius of second Ring';            
            label2{6}='$$\sigma_{r,2}$$ ... Width of second Ring';                  
            equation='$$I(x,y) = \frac{h}{2\pi\sigma^2} \cdot \exp \left[ -\frac{(x-\hat{x})^2+(y-\hat{y})^2}{2\sigma^2}  \right]+\sum_{n=1}^{2}\frac{(-1)^n h_{r,n}}{2\pi\sigma^2_{r,n}} \cdot \exp\left[-\frac{\left (\sqrt{(x-\hat{x})^2+(y-\hat{y})^2}-r_n  \right )^2}{2\sigma^2_{r,n}} \right]$$';
            Z=Calc2DPeak2Rings(X,Y);                     
    end
    
    cla(hConfigGui.pMolecules.aModelLabel);
    text('Parent',hConfigGui.pMolecules.aModelLabel,'Interpreter','latex','Position',[0.01 0.99],...
         'FontSize',13,'BackgroundColor',get(hConfigGui.pMolecules.pModel,'BackgroundColor'),'String',label,'VerticalAlignment','top');
    if ~isempty(label2) 
        text('Parent',hConfigGui.pMolecules.aModelLabel,'Interpreter','latex','Position',[0.51 0.99],...
             'FontSize',13,'BackgroundColor',get(hConfigGui.pMolecules.pModel,'BackgroundColor'),'String',label2,'VerticalAlignment','top');     
    end
    set(hConfigGui.pMolecules.aModelLabel,'Visible','off');
    
    cla(hConfigGui.pMolecules.aModelPreview);
    surf(X,Y,Z,'Parent',hConfigGui.pMolecules.aModelPreview);
    set(hConfigGui.pMolecules.aModelPreview,{'XLim','YLim','ZLim'},{[-10 10],[-10 10],[0 1]},'CameraViewAngle',22,'CameraPosition',[-10 -30 2],'CameraTarget',[0 0 0])
    set(hConfigGui.pMolecules.aModelPreview,'Visible','off');
    
    cla(hConfigGui.pMolecules.aModelEquation);
    text('Parent',hConfigGui.pMolecules.aModelEquation,'Interpreter','latex','Position',[0.01 0.5],...
         'FontSize',13,'BackgroundColor',get(hConfigGui.pMolecules.pModel,'BackgroundColor'),'String',equation);
    set(hConfigGui.pMolecules.aModelEquation,'Visible','off');
    UpdateParams(hConfigGui)
end

function Z=Calc2DPeakCircle(X,Y)
x=[-0.3 0.2 8 1];
Z = x(4) * exp( -( (X-x(1)).^2 + (Y-x(2)).^2 ) / x(3) );

function Z=Calc2DPeakEllipses(X,Y)
x=[0.3 0.2 3.9 2.8 0.08 1];
Z = x(6) * exp( - ( (X-x(1)) ./ x(3) ).^2  - ( (Y-x(2)) ./ x(4) ).^2 + x(5) .* (X-x(1)) .* (Y-x(2)));

function Z=Calc2DPeakRing(X,Y)
x=[0.3 0.2 8 1 4 0.3 7];
Z = x(4) * exp( -( (X-x(1)).^2 + (Y-x(2)).^2 ) / x(3) ) + x(6) .* exp( -( ( sqrt( (X-x(1)).^2 + (Y-x(2)).^2) - x(7) ).^2 ) / x(5) );

function Z=Calc2DPeak2Rings(X,Y)
x=[0.3 0.2 8 0.6 4 0.3 4 4 0.2 8];
Z = x(4) * exp( -( (X-x(1)).^2 + (Y-x(2)).^2 ) / x(3) ) - x(6) .* exp( -( (sqrt( (X-x(1)).^2 + (Y-x(2)).^2) - x(7)).^2) / x(5) ) + x(9) .* exp( -( ( sqrt( (X-x(1)).^2 + (Y-x(2)).^2) - x(10) ).^2) / x(8) );