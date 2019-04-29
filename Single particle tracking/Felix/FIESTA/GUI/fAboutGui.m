function fAboutGui(hMainGui)
global DirRoot;

file=[DirRoot 'FIESTA' filesep 'Help' filesep 'Images' filesep 'CBG-Logo.JPG'];

hAboutGui.fig = figure('Units','normalized','DockControls','off','IntegerHandle','off','MenuBar','none','Name','About FIESTA',...
                       'NumberTitle','off','Position',[0.325 0.35 0.35 0.3],'HandleVisibility','callback','Tag','hAboutGui',...
                      'Visible','on','WindowStyle','modal');
                  
hAboutGui.panel = uipanel('Parent',hAboutGui.fig,'Units','normalized','Fontsize',12,'Bordertype','none',...
                          'Position',[0 0 1 1],'Tag','pAbout','Visible','on');                           
                  
hAboutGui.tFIESTA = uicontrol('Parent',hAboutGui.panel,'Style','text','Units','normalized','FontWeight','bold',...
                             'Position',[.01 .9 .98 .07],'Tag','tFIESTA','Fontsize',12,'String','Fluorescence Image Evaluation Software for Tracking and Analysis');     
                         
hAboutGui.tVersion = uicontrol('Parent',hAboutGui.panel,'Style','text','Units','normalized',...
                             'Position',[.01 .84 .98 .06],'Tag','tVersion','Fontsize',12,'String',hMainGui.Version);    
                         
hAboutGui.tDate = uicontrol('Parent',hAboutGui.panel,'Style','text','Units','normalized',...
                             'Position',[.01 .78 .98 .06],'Tag','tDate','Fontsize',12,'String',hMainGui.Date);                             
                         
hAboutGui.tCopyrights = uicontrol('Parent',hAboutGui.panel,'Style','text','Units','normalized',...
                                'Position',[.01 .67 .98 .06],'Tag','tCopyrights','Fontsize',12,'String','Copyrights: Max Planck Institute of Molecular Cell Biology and Genetics');                    

hAboutGui.tAuthors = uicontrol('Parent',hAboutGui.panel,'Style','text','Units','normalized',...
                                'Position',[.01 .60 .98 .07],'Tag','tAuthors','Fontsize',12,'String','Authors: Felix Ruhnow & David Zwicker');
                            
hAboutGui.tAcknowledgements = uicontrol('Parent',hAboutGui.panel,'Style','text','Units','normalized',...
                                    'Position',[.01 .52 .98 .07],'Tag','tAuthors','Fontsize',12,'String','Acknowledgements: export_fig.m by Oliver Woodford (mathworks file exchange #23629)');        

set(hAboutGui.fig,'Units','pixel')
t=get(hAboutGui.fig,'Position');

hAboutGui.aMPICBG = axes('Parent',hAboutGui.fig,'Units','pixel','Position',[round((t(3)-260)/2) round(0.2*t(4)) 260 100],'Tag','Plot','Visible','off');

set(hAboutGui.aMPICBG,'Units','normalized')
set(hAboutGui.fig,'Units','normalized')

axis(hAboutGui.aMPICBG);

I=imread(file);

image(I);
axis off

hAboutGui.bClose = uicontrol('Parent',hAboutGui.fig,'Units','normalized','Callback','close(gcf);',...
                             'Position',[0.3 0.05 0.4 0.1],'String','OK','Tag','bClose','Fontsize',12);