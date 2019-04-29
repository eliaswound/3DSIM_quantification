function abort=fAnalyseStack(Stack,StackInfo,Config,StatusNr,Objects)
global logfile;
global error_events;

% get path of current script
DirRoot = [fileparts( mfilename('fullpath') ) filesep];

DirImageProc = [DirRoot 'imageprocessing' filesep];
  
% add fitting subdirectory to Matlab path
addpath( [ DirImageProc 'Fit2D' ] );
  

% add optimisation for R2007b bug fix, if present
optim_fixed_path = [ DirImageProc 'Fit2D' filesep 'optim' filesep 'R2007b' filesep];
if exist( optim_fixed_path, 'dir' )
    
    if strfind( version, 'R2007b' ) % check matlab version
        addpath( optim_fixed_path ); % contains fixed snls() routine
    else
        warning_state = warning( 'off', 'MATLAB:rmpath:DirNotFound' );
        rmpath( optim_fixed_path ); % make sure corrected path is not included, because of possible version conflict
        warning( warning_state );
    end
end

% add optimisation for R2009b bug fix, if present
optim_fixed_path = [ DirImageProc 'Fit2D' filesep 'optim' filesep 'R2009b' filesep];
if exist( optim_fixed_path, 'dir' )
    if strfind( version, 'R2009b' ) % check matlab version
        addpath( optim_fixed_path ); % contains fixed snls() routine
    else
        warning_state = warning( 'off', 'MATLAB:rmpath:DirNotFound' );
        rmpath( optim_fixed_path ); % make sure corrected path is not included, because of possible version conflict
        warning( warning_state );
    end
end
  
DirServer = strrep(DirRoot,['FIESTA' filesep],'');

error_events=[];
abort=0;

if strcmp(Config.Threshold.Mode,'Constant')==1
    params.threshold=Config.Threshold.Value;
end

if max(max(Config.Region))==1
    params.bw_regions=Config.Region;
end

params.bead_model=Config.Model;
params.max_beads_per_region=Config.MaxFunc;
params.scale=Config.PixSize;
params.ridge_model = 'quadratic';


params.find_molecules=1;
params.find_beads=1;

if Config.OnlyTrackMol==1
    params.find_molecules=0;
end
if Config.OnlyTrackFil==1
    params.find_beads=0;
end

params.area_threshold=Config.Threshold.Area;
params.height_threshold=Config.Threshold.Height;   
params.fwhm_estimate=Config.Threshold.FWHM;
params.min_cod=Config.Threshold.Fit;
params.binary_image_processing=Config.Threshold.Filter;
params.display=1;

params.options = optimset( 'Display', 'off');
params.options.MaxFunEvals = []; 
params.options.MaxIter = [];
params.options.TolFun = [];
params.options.TolX = [];

filestr = [DirRoot 'imageprocessing' filesep 'imlogfile.txt'];

logfile=fopen(filestr,'w');
if Config.FirstTFrame>0
    StartTime=clock;
    s=sprintf('Tracking - Frame:  %d/%d',Config.FirstTFrame,min([Config.LastFrame length(Stack)]));
    workbar(0,s,'Progress',0) 
    for n=Config.FirstTFrame:min([Config.LastFrame length(Stack)])
        params.creation_time=(StackInfo.CreationTime(n)-StackInfo.CreationTime(1))/1000;
        if strcmp(Config.Threshold.Mode,'Relative')==1
            params.threshold=Config.Threshold.Value(n);
        end
        Log(sprintf('Analysing frame %d',n),params);
        Objects{n}=ScanImage(Stack{n},params);
        if n>Config.FirstTFrame
            h = findobj('Tag','timebar');
            if isempty(h)
                abort=1;
                return
            end
        end
        if Config.FirstCFrame>0
            timeleft=etime(clock,StartTime)/(n-Config.FirstTFrame+1)*(Config.LastFrame-n);
            s=sprintf('Tracking - Frame:  %d/%d - Objects found: %d',n+1,Config.LastFrame,length(Objects{n}));
            workbar((n-Config.FirstTFrame+1)/(Config.LastFrame-Config.FirstTFrame+1),s,'Progress',timeleft) 
            if StatusNr>0
                StatusT=(n-Config.FirstTFrame+1)/(Config.LastFrame-Config.FirstTFrame+1); %#ok<NASGU>
                TimeT=timeleft; %#ok<NASGU>
                try
                    save([DirServer 'Status' filesep 'FiestaStatus' num2str(StatusNr) '.mat'],'StatusT','TimeT','-append');
                catch
                end
            end
        end
    end
end
fclose(logfile);
disp(Config.StackName)
disp(error_events)
if Config.LastFrame>length(Stack)&&Config.FirstTFrame>0
    disp(sprintf('Warning out of memory - Only tracked till frame number %4.0f',length(Stack)));
end
if ~isempty(Objects)
    sObjects=Objects; %#ok<NASGU>
    sConfig=Config; %#ok<NASGU>
    if ~isempty(strfind(Config.StackName,'.stk'))
        sName = strrep(Config.StackName, '.stk', '');
    elseif ~isempty(strfind(Config.StackName,'.tif'))
        sName = strrep(Config.StackName, '.tif', '');
    else
        sName = Config.StackName;
    end
    try
        fData=[Config.Directory sName '(' datestr(clock,'yyyymmddTHHMMSS') ').mat'];
        save(fData,'-v6','Objects','Config');
    catch
        fData=[strrep(DirRoot,['FIESTA' filesep],'') sName '(' datestr(clock,'yyyymmddTHHMMSS') ').mat'];
        save(fData,'-v6','Objects','Config');
    end

    [MolTrack,FilTrack,abort]=fFeatureConnect(Objects,Config,StatusNr);
    if abort==1
        return
    end
    Molecule=[];
    Filament=[];
    Molecule=fDefStructure(Molecule,'Molecule');
    Filament=fDefStructure(Filament,'Filament');

    nMolTrack=length(MolTrack);
    for i = 1:nMolTrack
        nData=size(MolTrack{i},1);
        Molecule(i).Selected=0;
        Molecule(i).Visible=1;    
        s=sprintf('Molecule(%d).Name=''Molecule %d'';',i,i); eval(s)
        Molecule(i).Directory=Config.Directory;
        Molecule(i).File=Config.StackName;
        Molecule(i).Color=[0 0 1];
        Molecule(i).Drift=0;    
        Molecule(i).PixelSize=Config.PixSize;    
        for j = 1:nData
            Molecule(i).Results(j,1) = MolTrack{i}(j,1);
            Molecule(i).Results(j,2) = Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).time;
            Molecule(i).Results(j,3) = Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).center_x;
            Molecule(i).Results(j,4) = Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).center_y;
            Molecule(i).Results(j,5) = norm([Molecule(i).Results(j,3)-Molecule(i).Results(1,3) Molecule(i).Results(j,4)-Molecule(i).Results(1,4)]);
            %determine what kind of Molecule found
            nHeight = length(Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).height);
            if length(double(Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).width))==1 || nHeight>1
                %Symmetric
                Molecule(i).Results(j,6)=double(Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).width(1));
            else
                %Streched
                Molecule(i).Results(j,6)=mean(double(Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).width(1:2)));
            end
            Molecule(i).Results(j,7)=Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).height(1);                
            Molecule(i).Results(j,8)=sqrt((Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).center_x.error)^2+...
                                          (Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).center_y.error)^2);
            if nHeight>1
                Molecule(i).Results(j,9)=Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).radius(2);                
                Molecule(i).Results(j,10)=Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).width(2);                            
                Molecule(i).Results(j,11)=Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).height(2);                                        
                if nHeight>2
                    Molecule(i).Results(j,12)=Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).radius(3);                
                    Molecule(i).Results(j,13)=Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).width(3);                            
                    Molecule(i).Results(j,14)=Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).height(3);                                                        
                end
            end
            Molecule(i).data{j}=Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).data;
            Molecule(i).data{j}.w=double(Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).width);
            Molecule(i).data{j}.h=double(Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).height);
            if isfield(Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)),'radius')
                Molecule(i).data{j}.r=double(Objects{MolTrack{i}(j,1)}(MolTrack{i}(j,2)).radius);        
            else
                Molecule(i).data{j}.r=[];
            end
        end
    end
    if ~isempty(Stack)
        sStack=size(Stack{1});
    end
    nFilTrack=length(FilTrack);
    for i=nFilTrack:-1:1
        nData=size(FilTrack{i},1);
        Filament(i).Selected=0;
        Filament(i).Visible=1;    
        s=sprintf('Filament(%d).Name=''Filament %d'';',i,i); eval(s)
        Filament(i).Directory=Config.Directory;
        Filament(i).File=Config.StackName;
        Filament(i).Color=[0 0 1];
        Filament(i).Drift=0;
        Filament(i).PixelSize=Config.PixSize;  
        for j=1:nData
            Filament(i).ResultsCenter(j,1)=FilTrack{i}(j,1);
            Filament(i).ResultsCenter(j,2)=Objects{FilTrack{i}(j,1)}(FilTrack{i}(j,2)).time;
            Filament(i).ResultsCenter(j,3)=Objects{FilTrack{i}(j,1)}(FilTrack{i}(j,2)).center_x;
            Filament(i).ResultsCenter(j,4)=Objects{FilTrack{i}(j,1)}(FilTrack{i}(j,2)).center_y;
            Filament(i).ResultsCenter(j,5)=norm([Filament(i).ResultsCenter(j,3)-Filament(i).ResultsCenter(1,3) Filament(i).ResultsCenter(j,4)-Filament(i).ResultsCenter(1,4)]);
            Filament(i).ResultsCenter(j,6)=Objects{FilTrack{i}(j,1)}(FilTrack{i}(j,2)).length;
            Filament(i).ResultsCenter(j,7)=double([Objects{FilTrack{i}(j,1)}(FilTrack{i}(j,2)).height]);
            Filament(i).ResultsCenter(j,8)=1;
            Filament(i).data{j}=Objects{FilTrack{i}(j,1)}(FilTrack{i}(j,2)).data;
            Filament(i).Orientation(j)=mod(double(Objects{FilTrack{i}(j,1)}(FilTrack{i}(j,2)).orientation),2*pi);
            if j>1
                d=sqrt( (Filament(i).data{j}(1).x-Filament(i).data{j-1}(1).x)^2 +...
                        (Filament(i).data{j}(1).y-Filament(i).data{j-1}(1).y)^2);
                if d>Filament(i).ResultsCenter(j,6)/2
                   Filament(i).data{j}=Filament(i).data{j}(length(Filament(i).data{j}):-1:1);
                   Filament(i).Orientation(j)=mod(Filament(i).Orientation(j)+pi,2*pi);
                end
            end
            Filament(i).ResultsStart(j,1)=FilTrack{i}(j,1);
            Filament(i).ResultsStart(j,2)=Objects{FilTrack{i}(j,1)}(FilTrack{i}(j,2)).time;
            Filament(i).ResultsStart(j,3)=Filament(i).data{j}(1).x;
            Filament(i).ResultsStart(j,4)=Filament(i).data{j}(1).y;
            Filament(i).ResultsStart(j,5)=norm([Filament(i).ResultsStart(j,3)-Filament(i).ResultsStart(1,3) Filament(i).ResultsStart(j,4)-Filament(i).ResultsStart(1,4)]);
            Filament(i).ResultsStart(j,6)=Objects{FilTrack{i}(j,1)}(FilTrack{i}(j,2)).length;
            Filament(i).ResultsStart(j,7)=Filament(i).data{j}(1).h;
            Filament(i).ResultsStart(j,8)=1;

            END=length(Filament(i).data{j});
            Filament(i).ResultsEnd(j,1)=FilTrack{i}(j,1);
            Filament(i).ResultsEnd(j,2)=Objects{FilTrack{i}(j,1)}(FilTrack{i}(j,2)).time;
            Filament(i).ResultsEnd(j,3)=Filament(i).data{j}(END).x;
            Filament(i).ResultsEnd(j,4)=Filament(i).data{j}(END).y;
            Filament(i).ResultsEnd(j,5)=norm([Filament(i).ResultsEnd(j,3)-Filament(i).ResultsEnd(1,3) Filament(i).ResultsEnd(j,4)-Filament(i).ResultsEnd(1,4)]);
            Filament(i).ResultsEnd(j,6)=Objects{FilTrack{i}(j,1)}(FilTrack{i}(j,2)).length;
            Filament(i).ResultsEnd(j,7)=Filament(i).data{j}(END).h;
            Filament(i).ResultsEnd(j,8)=1;
        end
        if Config.ConnectFil.DisregardEdge && ~isempty(Stack)                                          
            xv = [5 5 sStack(2)-4 sStack(2)-4]*Config.PixSize;
            yv = [5 sStack(1)-4 sStack(1)-4 5]*Config.PixSize;            
            X=Filament(i).ResultsStart(:,3);
            Y=Filament(i).ResultsStart(:,4);
            IN = inpolygon(X,Y,xv,yv);
            Filament(i).ResultsStart(~IN,:)=[];
            Filament(i).ResultsCenter(~IN,:)=[];
            Filament(i).ResultsEnd(~IN,:)=[];
            Filament(i).data(~IN)=[];            
            X=Filament(i).ResultsEnd(:,3);
            Y=Filament(i).ResultsEnd(:,4);
            IN = inpolygon(X,Y,xv,yv);
            Filament(i).ResultsStart(~IN,:)=[];
            Filament(i).ResultsCenter(~IN,:)=[];
            Filament(i).ResultsEnd(~IN,:)=[];     
            Filament(i).data(~IN)=[];
            if isempty(Filament(i).ResultsCenter)
                Filament(i)=[];
            end
        end
    end
    sMolecule=Molecule; %#ok<NASGU>
    sFilament=Filament; %#ok<NASGU>
    try
        save(fData,'-append','-v6','Molecule','Filament');
    catch
        fData=[strrep(DirRoot,['FIESTA' filesep],'') sName '(' datestr(clock,'yyyymmddTHHMMSS') ').mat'];
        save(fData,'-v6','Molecule','Filament','Objects');
        disp('Directory not accessible - File saved in FIESTA root directory');
    end
end