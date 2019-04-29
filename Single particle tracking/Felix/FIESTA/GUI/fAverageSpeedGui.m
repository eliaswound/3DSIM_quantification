function fAverageSpeedGui(func,varargin)
switch func
    case 'Create'
        Create;
    case 'Calculate'
        Calculate(varargin{1});        
    case 'Save'
        Save(varargin{1});   
    case 'Update'
        Update(varargin{1});           
end

function Create

h=findobj('Tag','hAverageSpeedGui');
close(h)

hAverageSpeedGui.fig = figure('Units','normalized','WindowStyle','modal','DockControls','off','IntegerHandle','off','MenuBar','none','Name','Path Statistics',...
                      'NumberTitle','off','Position',[0.4 0.3 0.2 0.3],'HandleVisibility','callback','Tag','hAverageSpeedGui',...
                      'Visible','on','Resize','off','Color',[0.9255 0.9137 0.8471]);

hAverageSpeedGui.tResults = uicontrol('Parent',hAverageSpeedGui.fig,'Units','normalized','Position',[0.05 0.85 0.9 0.12],'Enable','on',...
                                      'String','','Style','text','Tag','tResults','HorizontalAlignment','left');
                    
hAverageSpeedGui.pOptions = uipanel('Parent',hAverageSpeedGui.fig,'Units','normalized','Title','Options',...
                             'Position',[0.05 0.325 0.9 0.5],'Tag','pOptions');

hAverageSpeedGui.rCenter = uicontrol('Parent',hAverageSpeedGui.pOptions,'Units','normalized','Callback','fAverageSpeedGui(''Update'',getappdata(0,''hAverageSpeedGui''));',...
                            'Position',[0.1 0.825 0.8 0.15],'String','Center point','Style','radiobutton','Tag','rCenter','Value',1);                         

hAverageSpeedGui.tMTonly = uicontrol('Parent',hAverageSpeedGui.pOptions,'Units','normalized','Position',[0.1 0.625 0.8 0.15],'Enable','on',...
                                      'String','only for microtubule:','Style','text','Tag','tMTonly','HorizontalAlignment','left');
                                  
hAverageSpeedGui.rStart = uicontrol('Parent',hAverageSpeedGui.pOptions,'Units','normalized','Callback','fAverageSpeedGui(''Update'',getappdata(0,''hAverageSpeedGui''));',...
                            'Position',[0.1 0.425 0.8 0.15],'String','Start point','Style','radiobutton','Tag','rStart','Value',0);   
                        
hAverageSpeedGui.rEnd = uicontrol('Parent',hAverageSpeedGui.pOptions,'Units','normalized','Callback','fAverageSpeedGui(''Update'',getappdata(0,''hAverageSpeedGui''));',...
                            'Position',[0.1 0.225 0.8 0.15],'String','End point','Style','radiobutton','Tag','rEnd','Value',0);                         
                        
hAverageSpeedGui.rLength = uicontrol('Parent',hAverageSpeedGui.pOptions,'Units','normalized','Callback','fAverageSpeedGui(''Update'',getappdata(0,''hAverageSpeedGui''));',...
                            'Position',[0.1 0.025 0.8 0.15],'String','Length','Style','radiobutton','Tag','rLength','Value',0);   
                     
                        
hAverageSpeedGui.cSaveFigures = uicontrol('Parent',hAverageSpeedGui.fig,'Units','normalized','Position',[0.05 0.2 0.9 0.1],'Enable','on','Value',0,...
                                          'String','Save fit as figures','Style','checkbox','Tag','cSaveFigures','HorizontalAlignment','left');

hAverageSpeedGui.bCalc = uicontrol('Parent',hAverageSpeedGui.fig,'Units','normalized','Callback','fAverageSpeedGui(''Calculate'',getappdata(0,''hAverageSpeedGui''));',...
                            'Position',[0.05 0.025 0.4 0.15],'String','Calculate','Tag','bCalc');

hAverageSpeedGui.bSave = uicontrol('Parent',hAverageSpeedGui.fig,'Units','normalized','Callback','fAverageSpeedGui(''Save'',getappdata(0,''hAverageSpeedGui''));',...
                             'Position',[0.55 0.025 0.4 0.15],'String','Save','Tag','bSave');                        

setappdata(0,'hAverageSpeedGui',hAverageSpeedGui);
SpeedData=[];
setappdata(hAverageSpeedGui.fig,'SpeedData',SpeedData);


function Save(hAverageSpeedGui)
SpeedData=getappdata(hAverageSpeedGui.fig,'SpeedData');   
[FileName, PathName] = uiputfile({'*.txt','TXT-File (*.txt)';},fShared('GetSaveDir'));
if sum(FileName)~=0&&~isempty(SpeedData)
    fShared('SetSaveDir',PathName);
    file = [PathName FileName];
    if isempty(findstr('.txt',file))
        file = [file '.txt'];
    end
    f = fopen(file,'w');
    speed=cell2mat(SpeedData(:,2));
    fprintf(f,'average speed: %6.2f nm/s standard deviation: %5.2f nm/s\n',mean(speed(:,1)),std(speed(:,1)));
    for i=1:size(SpeedData,1)
        fprintf(f,'%s\t%6.2f\n',SpeedData{i,1},speed(i,1));
    end
    fclose(f);
    if get(hAverageSpeedGui.cSaveFigures,'Value')==1
        for i=1:size(SpeedData,1)
            f=figure('Units','Pixels','Position',[574 256 680 484]);
            legh = []; legt = {};   % handles and text for legend
            xlim = [Inf -Inf];       % limits of x axis
            ax = axes;
            set(ax,'Units','normalized','OuterPosition',[0 .5 1 .5]);
            ax2 = axes;
            set(ax2,'Units','normalized','OuterPosition',[0 0 1 .5]);
            set(ax2,'Box','on');
            legrh = []; legrt = {};
            set(ax,'Box','on');
            axes(ax); hold on;
            % --- Plot data originally in dataset "y vs. x"
            x = SpeedData{i,4};
            y = SpeedData{i,5};
            h = line(x,y,'Parent',ax,'Color',[0.333333 0 0.666667],'LineStyle','none', 'LineWidth',1,'Marker','.', 'MarkerSize',12);
            xlim(1) = min(xlim(1),min(x));
            xlim(2) = max(xlim(2),max(x));
            legh(end+1) = h;
            legt{end+1} = '';

            % Nudge axis limits beyond data limits
            if all(isfinite(xlim))
                xlim = xlim + [-1 1] * 0.01 * diff(xlim);
                set(ax,'XLim',xlim)
                set(ax2,'XLim',xlim)
            else
                set(ax, 'XLim',[-1.3000000000000003, 335.30000000000001]);
                set(ax2,'XLim',[-1.3000000000000003, 335.30000000000001]);
            end
        
            parameters=SpeedData{i,2};
            cf=SpeedData{i,3};

            % Plot this fit
            h = plot(cf,'fit',0.95);
            set(h(1),'Color',[1 0 0],'LineStyle','-', 'LineWidth',2,'Marker','none', 'MarkerSize',6);
            text(min(x)+20,max(y)-20,['ActinL=' num2str(parameters(1),4) '*t + ' num2str(parameters(2),4)]);

            legh(end+1) = h(1);
            legt{end+1} = '';
            res = y - cf(x);
            [x,j] = sort(x);
            axes(ax2); hold on;
            h = line(x,res(j),'Parent',ax2,'Color',[1 0 0],'LineStyle','-', 'LineWidth',1,'Marker','.', 'MarkerSize',6);
            axes(ax); hold on;
            legrh(end+1) = h;
            legrt{end+1} = '';

            % Done plotting data and fits.  Now finish up loose ends.
            hold off;
            xlabel(ax,'Time (s)');               % remove x label
            ylabel(ax,'Actin Length (nm)');               % remove y label
            xlabel(ax2,'Time (s)');
            ylabel(ax2,'Residue (nm)');
            title(ax,'Actin Length vs. Time');
            title(ax2,'Residuals');
            saveas(f,sprintf('%s/#%03.0f-%s.fig',PathName,i,SpeedData{i,1}),'fig'); 
            close(f);
        end
    end
end
close(hAverageSpeedGui.fig);

function Update(hAverageSpeedGui)
if get(hAverageSpeedGui.rCenter,'Value')==1&&gcbo==hAverageSpeedGui.rCenter
    set(hAverageSpeedGui.rStart,'Value',0);      
    set(hAverageSpeedGui.rEnd,'Value',0);  
    set(hAverageSpeedGui.rLength,'Value',0);  
elseif get(hAverageSpeedGui.rStart,'Value')==1&&gcbo==hAverageSpeedGui.rStart
    set(hAverageSpeedGui.rCenter,'Value',0);      
    set(hAverageSpeedGui.rEnd,'Value',0);  
    set(hAverageSpeedGui.rLength,'Value',0); 
elseif get(hAverageSpeedGui.rEnd,'Value')==1&&gcbo==hAverageSpeedGui.rEnd
    set(hAverageSpeedGui.rStart,'Value',0);      
    set(hAverageSpeedGui.rCenter,'Value',0);  
    set(hAverageSpeedGui.rLength,'Value',0); 
elseif get(hAverageSpeedGui.rLength,'Value')==1&&gcbo==hAverageSpeedGui.rLength
    set(hAverageSpeedGui.rStart,'Value',0);      
    set(hAverageSpeedGui.rEnd,'Value',0);  
    set(hAverageSpeedGui.rCenter,'Value',0); 
end

function Calculate(hAverageSpeedGui)
global Molecule;
global Filament;
SpeedData=[];
p=1;
if get(hAverageSpeedGui.rCenter,'Value')==1
    for i=1:length(Molecule)
        if Molecule(i).Selected==1
            f=fit(Molecule(i).Results(:,2),Molecule(i).Results(:,5),'poly1');
            parameters=coeffvalues(f);
            SpeedData{p,1}=Molecule(i).Name;
            SpeedData{p,2}=parameters;
            SpeedData{p,3}=f;
            SpeedData{p,4}=Molecule(i).Results(:,2);
            SpeedData{p,5}=Molecule(i).Results(:,5);            
            p=p+1;            
        end
    end
    for i=1:length(Filament)
        if Filament(i).Selected==1
            f=fit(Filament(i).ResultsCenter(:,2),Filament(i).ResultsCenter(:,5),'poly1');
            parameters=coeffvalues(f);
            SpeedData{p,1}=Filament(i).Name;
            SpeedData{p,2}=parameters;
            SpeedData{p,3}=f;
            SpeedData{p,4}=Filament(i).ResultsCenter(:,2);
            SpeedData{p,5}=Filament(i).ResultsCenter(:,5);            
            p=p+1;            
        end
    end
elseif get(hAverageSpeedGui.rStart,'Value')==1
    for i=1:length(Filament)
        if Filament(i).Selected==1
            f=fit(Filament(i).ResultsStart(:,2),Filament(i).ResultsStart(:,5),'poly1');
            parameters=coeffvalues(f);
            SpeedData{p,1}=Filament(i).Name;
            SpeedData{p,2}=parameters;
            SpeedData{p,3}=f;
            SpeedData{p,4}=Filament(i).ResultsStart(:,2);
            SpeedData{p,5}=Filament(i).ResultsStart(:,5);            
            p=p+1;
        end
    end
elseif get(hAverageSpeedGui.rEnd,'Value')==1
    for i=1:length(Filament)
        if Filament(i).Selected==1
            f=fit(Filament(i).ResultsEnd(:,2),Filament(i).ResultsEnd(:,5),'poly1');
            parameters=coeffvalues(f);
            SpeedData{p,1}=Filament(i).Name;
            SpeedData{p,2}=parameters;
            SpeedData{p,3}=f;
            SpeedData{p,4}=Filament(i).ResultsEnd(:,2);
            SpeedData{p,5}=Filament(i).ResultsEnd(:,5);            
            p=p+1;            
        end
    end
elseif get(hAverageSpeedGui.rLength,'Value')==1
    for i=1:length(Filament)
        if Filament(i).Selected==1
            f=fit(Filament(i).Results(:,2),Filament(i).Results(:,6),'poly1');
            parameters=coeffvalues(f);
            SpeedData{p,1}=Filament(i).Name;
            SpeedData{p,2}=parameters;
            SpeedData{p,3}=f;
            SpeedData{p,4}=Filament(i).Results(:,2);
            SpeedData{p,5}=Filament(i).Results(:,6);
            p=p+1;
        end
    end
end
speed=cell2mat(SpeedData(:,2));
str{1}=sprintf('average speed: %5.2f nm/s',mean(speed(:,1)));
str{2}=sprintf('standard deviation: %5.2f nm/s',std(speed(:,1)));
set(hAverageSpeedGui.tResults,'String',str);
setappdata(hAverageSpeedGui.fig,'SpeedData',SpeedData);            