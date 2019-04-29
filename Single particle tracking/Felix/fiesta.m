function fiesta(version,server_version)
%FIESTA starting the Fluorescent Image Evaluation Software for Tracking and Analysis
% The script automatically looks for a new version of the software and does an
% update, if necessary.
%
% Options
% <a href="matlab:fiesta('list')">fiesta('list')</a> - list of all available versions
% fiesta('x.xx.xxxx') - downloads version x.xx.xxxx (only if available in list)
%
% example
% fiesta('1.00.0023') - downloads version 1.00.0023

%Name of PC where the FIESTA Tracking Server runs
global TrackingPC;
global defaultuser;

%set default username
defaultuser='GoldmanLab'; %#ok<NASGU>

%set variable to computer name:
%TrackingPC='Diez-zzz';
TrackingPC='';

%check user input 5
if nargin == 0
    %update to newest version and start
    StartFiesta(''); 
elseif nargin == 1
    if strcmp(version,'list') || strcmp(version,'server')
        %update to version 'x.xx.xxxx' and start        
        ListFiestaVersion(version);
    else
        %get FIESTA version 'x.xx.xxxx' and start
        StartFiesta(version);
    end
else
    %set FIESTA version on tracking server to 'x.xx.xxxx' 
    DirServer = CheckServer;
    if ~isempty(DirServer)
        file_id = fopen([DirServer filesep 'Server' filesep 'fiesta_readme.txt'], 'w'); 
        fprintf(file_id,server_version);
        fclose(file_id); 
        disp('Restart the server before the changes take effect');
    else
        disp('FIESTA Tracking Server not available');
    end
end

function StartFiesta(version)
global PathBackup;
global DirRoot;
global defaultuser;

%get path where fiesta.m was started
DirRoot = [fileparts( mfilename('fullpath') ) filesep];

%Set root directory for FIESTA
DirFIESTA = [DirRoot 'FIESTA' filesep];
    
clear functions;

%backup path to reset path after closing FIESTA
PathBackup = path;
%set path to MatLab functions only
restoredefaultpath;
    
%get online version of FIESTA
[index,status] = FiestaUrlRead('http://www.mpi-cbg.de/~ruhnow/fiesta_readme.txt','');
%online_version = native2unicode(index(86:94),'UTF-8');  %YS remarked because it caused error message. 04/20/2010

%compare local version with online version
if isempty(version) && isdir(DirFIESTA)
    %get local version of FIESTA
    file_id = fopen([DirFIESTA 'fiesta_readme.txt'], 'r'); 
    if file_id ~= -1
        index = fgetl(file_id);
        local_version = index(86:94);
        fclose(file_id); 
    else
        local_version = '';
    end
    if ~status
        disp('Warning: Could not access FIESTA files online - check internet connection');
        online_version = '';        
    end
    %compare local version with online version
%     if ~strcmp( local_version , online_version )
%         button = questdlg({'There is FIESTA update available!','',['Do you want to update to version ' online_version ' now?'],'(Might require valid username/password)'},'FIESTA Update','Yes','No','Yes');
%         if strcmp(button,'Yes')
%             version='newest';
%         else
%             version='';
%         end        
%     end
end

%check if FIESTA is installed
if ~isdir(DirFIESTA)
    if ~isempty(version)
        online_version=version;
    end
    button = questdlg({'FIESTA has not been installed in:',DirRoot,'',['Do you want to install version ' online_version ' now?'],'(Might require valid username/password)'},'FIESTA Installation','Yes','No','Yes');
    if strcmp(button,'Yes')
        if status
            if isempty(version)
                version='newest';
            end
        else
            errordlg('Could not access FIESTA files online - check internet connection','FIESTA Installation Error','modal');
            return;
        end
    else
        version='';
    end
end

%check whether to download and install FIESTA 
if ~isempty(version)&&status
    %check if FIESTA online is accessable
    [index,status]=FiestaUrlRead('http://www.mpi-cbg.de/~ruhnow/FIESTA','');
    if ~status
        %get authentication for FIESTA online
        authentication=GetAuthentication(defaultuser);
        if strcmp(authentication,':')
            return;
        else
            %check if FIESTA online is accessable with user authentication
            [index,status]=FiestaUrlRead('http://www.mpi-cbg.de/~ruhnow/FIESTA/archive',authentication);        
            if ~status
                errordlg('Could not access FIESTA files online - wrong Username/Password','FIESTA Installation Error','modal');
                return;
            end
        end
    else
        authentication='';
    end
    if strcmp(version,'newest')
        %get newest version
        disp('Updating FIESTA to the newest version...');        
        urlzip ='http://www.mpi-cbg.de/~ruhnow/FIESTA/FIESTA.zip'; 
        [index,status] = FiestaUrlRead(urlzip,authentication);                    
    else
        %get version x.xx.xxxx
        disp(['Downloading FIESTA version version ' version '...']);
        urlzip=['http://www.mpi-cbg.de/~ruhnow/FIESTA/archive/' version '.zip'];                
        %check if FIESTA version x.xx.xxxx is available
        [index,status] = FiestaUrlRead(urlzip,authentication);  
        if ~status
            %FIESTA online files are available but wrong version input
            errordlg(['Version ' version ' not available - check fiesta(''list'') for all available versions)'],'FIESTA Installation Error','modal');
            return;
        end
    end
    if status
        if isdir(DirFIESTA)
            %delete all old files
            rmdir(DirFIESTA,'s');
        end
        %create new FIESTA directory
        mkdir(DirFIESTA);  
        file_id = fopen([DirRoot 'FIESTA.zip'],'w');
        fwrite(file_id,index);
        fclose(file_id);
        %unzip FIESTA files to directory
        filenames = unzip([DirRoot 'FIESTA.zip'],DirFIESTA);
        for i=1:length(filenames)
            fileattrib(filenames{i},'+w');
        end
        delete([DirRoot 'FIESTA.zip']);
    end
end

%check if FIESTA is installed
if isdir(DirFIESTA)
    %check if FIESTA tracking server available
    DirServer = CheckServer;
    if ~isempty(DirServer);
        %get local version of FIESTA
        file_id = fopen([DirFIESTA 'fiesta_readme.txt'], 'r'); 
        if file_id ~= -1
            index = fgetl(file_id);
            local_version = index(86:94);
            fclose(file_id); 
        else
            local_version = '';
        end
        %get server version of FIESTA
        file_id = fopen([DirServer 'Server' filesep 'fiesta_readme.txt'], 'r'); 
        if file_id ~= -1
            index = fgetl(file_id);
            server_version = index(86:94);
            fclose(file_id); 
        else
            server_version = '';
        end
        %compare server version with local version
        if ~strcmp( local_version , server_version )
            t=warndlg({'Detected a different version on the server!';'See fiesta(''server'') or restart server for newest version'},'FIESTA Tracking Server','modal');
            uiwait(t);
        end
    end
    %add path to FIESTA functions
    addpath(genpath(DirFIESTA));
    % finally start the application
    fMainGui('Create');
end

function ListFiestaVersion(version)
global defaultuser;
%get online version of FIESTA
[online_version,status] = FiestaUrlRead('http://www.mpi-cbg.de/~ruhnow/fiesta_readme.txt','');
if status
    %check if FIESTA online is accessable
    [index,status] = FiestaUrlRead('http://www.mpi-cbg.de/~ruhnow/FIESTA/archive','');
    if ~status
        %get authentication for FIESTA online
        authentication=GetAuthentication(defaultuser);
        if strcmp(authentication,':')
            return;
        else
            %check if FIESTA online is accessable with user authentication
            [index,status]=FiestaUrlRead('http://www.mpi-cbg.de/~ruhnow/FIESTA/archive',authentication);        
            if ~status
                errordlg('Could not access FIESTA files online - wrong Username/Password','FIESTA Installation Error','modal');
                return;
            end
        end
    end
    if status
        index = native2unicode(index,'UTF-8');
        p = strfind(index,'<hr>');
        list = index(p(1)+4:p(2)-1);
        list = strrep(list,'.zip','');
        %process list to transform links
        if strcmp(version,'list')==1
            list = regexprep(list,'href="(\d\.\d\d.\d\d\d\d?)"','href="matlab:fiesta(''$1'')"'); %for local version of FIESTA
        else
            list = regexprep(list,'href="(\d\.\d\d.\d\d\d\d?)"','href="matlab:fiesta(''server'',''$1'')"'); %for server version of FIESTA
        end
        disp('Available versions of FIESTA - download with fiesta(''1.xx.xxxx'')...');
        disp(list);
    end
else
    errordlg('Could not access FIESTA files online - check internet connection','FIESTA Installation Error','modal');
    return;
end

function DirServer=CheckServer
global TrackingPC;
if ~isempty(TrackingPC)
    %check if FIESTA tracking server is available
    if ispc 
        %for PC just access the tracking server directory
        DirServer = ['\\' TrackingPC '\FIESTA\'];
    elseif ismac 
        %for MAC ask user if he wants to connect to tracking server 
        button = questdlg({'Do you want to use the FIESTA Tracking Server?',['Connect to smb://' TrackingPC '/fiesta first!']},'FIESTA Tracking Server','Only use Local Version','Connect to Server','Only use Local Version');
        if strcmp(button,'Connect to Server')
            DirServer = '/Volumes/FIESTA/';  
        else
            DirServer = '';
        end
    else
        %error message for users of Linux version of MatLab        
        errordlg('Your Operating System is not yet supported','FIESTA Installation Error','modal');
        return;
    end
    if ~isempty(DirServer)
        %try to access tracking server
        if isempty(dir(DirServer))
            DirServer = '';
        end
    end
else
    DirServer = ''; 
end

function [output,status]=FiestaUrlRead(urlChar,authentication)
if ~usejava('jvm')
   errordlg('FIESTA online requires Java.');
   return;
end

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% Be sure the proxy settings are set.
com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

% Set default outputs.
output = '';

% Determine the protocol (before the ":").
protocol = urlChar(1:min(find(urlChar==':',1,'first'))-1);

% Try to use the native handler, not the ice.* classes.
switch protocol
    case 'http'
        try
            handler = sun.net.www.protocol.http.Handler;
        catch
            handler = [];
        end
    case 'https'
        try
            handler = sun.net.www.protocol.https.Handler;
        catch
            handler = [];
        end
    otherwise
        handler = [];
end

%check if authorization is required
if isempty(authentication)
    authString='';
else
    encoder = sun.misc.BASE64Encoder; 
    authString = char(encoder.encode(uint8(authentication)));
end

% Create the URL object.
if isempty(handler)
    url = java.net.URL(urlChar);
else
    url = java.net.URL([],urlChar,handler);
end

% Determine the proxy.
proxy = [];
if ~isempty(java.lang.System.getProperty('http.proxyHost'))
    try
        ps = java.net.ProxySelector.getDefault.select(java.net.URI(urlChar));
        if (ps.size > 0)
            proxy = ps.get(0);
        end
    catch
        proxy = [];
    end
end

% Open a connection to the URL.
if isempty(proxy)
    urlConnection = url.openConnection;
else
    urlConnection = url.openConnection(proxy);
end

%authenticate url
if ~isempty(authString)
    urlConnection.setRequestProperty('Authorization', ['Basic ' authString]);
end

% Read the data from the connection.
try
    inputStream = urlConnection.getInputStream;
    byteArrayOutputStream = java.io.ByteArrayOutputStream;
    % This StreamCopier is unsupported and may change at any time.
    isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
    isc.copyStream(inputStream,byteArrayOutputStream);
    inputStream.close;
    byteArrayOutputStream.close;
    output = typecast(byteArrayOutputStream.toByteArray','uint8');
    status = 1;
catch
    status=0;
end

function authentication=GetAuthentication(defaultuser)
hAuth.fig = figure('Menubar','none','Units','normalized','Resize','off','NumberTitle','off', ...
                   'Name','FIESTA Authentication','Position',[0.4 0.4 0.2 0.2],'WindowStyle','normal');

uicontrol('Parent',hAuth.fig,'Style','text','Enable','inactive','Units','normalized','Position',[0 0 1 1], ...
          'FontSize',12);
                  
uicontrol('Parent',hAuth.fig,'Style','text','Enable','inactive','Units','normalized','Position',[0.1 0.8 0.8 0.1], ...
                      'FontSize',12,'String','Username:','HorizontalAlignment','left');
                  
                 
hAuth.eUsername = uicontrol('Parent',hAuth.fig,'Style','edit','Tag','username','Units','normalized','Position',[0.1 0.675 0.8 0.125], ...
                       'FontSize',12,'String',defaultuser,'BackGroundColor','white','HorizontalAlignment','left');
                   
uicontrol('Parent',hAuth.fig,'Style','text','Enable','inactive','Units','normalized','Position',[0.1 0.5 0.8 0.1], ...
          'FontSize',12,'String','Password:','HorizontalAlignment','left');
                  
hAuth.ePassword = uicontrol('Parent',hAuth.fig,'Style','edit','Tag','password','Units','normalized','Position',[0.1 0.375 0.8 0.125], ...
                            'FontSize',12,'String','','BackGroundColor','white','HorizontalAlignment','left');                   
                        
uicontrol('Parent',hAuth.fig,'Style','pushbutton','Tag','OK','Units','normalized','Position',[0.1 0.05 0.35 0.2], ...
                            'FontSize',12,'String','OK','Callback','uiresume;');                   
                        
uicontrol('Parent',hAuth.fig,'Style','pushbutton','Tag','Cancel','Units','normalized','Position',[0.55 0.05 0.35 0.2], ...
                            'FontSize',12,'String','Cancel','Callback',@AbortAuthentication);                                           

set(hAuth.fig,'CloseRequestFcn',@AbortAuthentication)
set(hAuth.ePassword,'KeypressFcn',@PasswordKeyPress)

setappdata(0,'hAuth',hAuth);

uicontrol(hAuth.eUsername);

uiwait;

username = get(hAuth.eUsername,'String');
password = get(hAuth.ePassword,'UserData');
authentication = [username ':' password];
delete(hAuth.fig);

function PasswordKeyPress(hObject,event) %#ok<INUSL>
hAuth = getappdata(0,'hAuth');
password = get(hAuth.ePassword,'UserData');
switch event.Key
   case 'backspace'
      password = password(1:end-1);
   case 'return'
      uiresume;
      return;
   otherwise
      password = [password event.Character];
end
set(hAuth.ePassword,'UserData',password)
set(hAuth.ePassword,'String',char('*'*sign(password)))

function AbortAuthentication(hObject,event) %#ok<INUSL>
hAuth = getappdata(0,'hAuth');
set(hAuth.eUsername,'String','');
set(hAuth.ePassword,'UserData','');
uiresume;