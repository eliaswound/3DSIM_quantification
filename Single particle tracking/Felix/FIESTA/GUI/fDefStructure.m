function Object=fDefStructure(Object,Mode)
nObj=length(Object);
n=nObj;
if nObj==0
    nObj=1;
end
if isfield(Object,'Visible')==0
    for i=1:nObj
        Object(i).Visible=1;
    end
end
if isfield(Object,'Selected')==0
    for i=1:nObj
        Object(i).Selected=0;
    end
end
if isfield(Object,'Name')==0
    for i=1:nObj    
        Object(i).Name='';
    end
end
if isfield(Object,'Directory')==0
    for i=1:nObj    
        Object(i).Directory='';
    end
end
if isfield(Object,'File')==0
    for i=1:nObj    
        Object(i).File='';
    end
end
if isfield(Object,'Color')==0
    for i=1:nObj 
        Object(i).Color=[0 0 1];
    end
else
    for i=1:nObj    
        if ischar(Object(i).Color)
            Object(i).Color=ColorCode(Object(i).Color);
        end
    end
end
if isfield(Object,'Drift')==0
    for i=1:nObj    
        Object(i).Drift=0;
    end
end
if isfield(Object,'PixelSize')==0
    for i=1:nObj    
        Object(i).PixelSize=100;
    end
end
if isfield(Object,'Results')==0
    for i=1:nObj    
        Object(i).Results=[];
    end
else
    for i=1:nObj    
        if size(Object(i).Results,2)==10
            Object(i).Results(:,9:10)=[];
        end
    end
end
        
if strcmp(Mode,'Filament')==1
    if isfield(Object,'ResultsCenter')==0
        for i=1:nObj    
            Object(i).ResultsCenter=[];
        end
    end
    if isfield(Object,'ResultsStart')==0
        for i=1:nObj    
            Object(i).ResultsStart=[];
        end        
    end
    if isfield(Object,'ResultsEnd')==0
        for i=1:nObj    
            Object(i).ResultsEnd=[];
        end
    end
    if isfield(Object,'Orientation')==0
        for i=1:nObj    
            Object(i).Orientation=[];
        end
    end
end        
if isfield(Object,'data')==0
    for i=1:nObj    
        Object(i).data={};
    end
end
if isfield(Object,'Path')==0
    for i=1:nObj    
        Object(i).Path={};
    end
end
if isfield(Object,'NewResults')==0
    for i=1:nObj    
        Object(i).NewResults={};
    end
end
if isfield(Object,'p')==1
    Object=rmfield(Object,'p');
end
if isfield(Object,'Config')==1
    Object=rmfield(Object,'Config');
end
if isfield(Object,'DriftControl')==1
    Object=rmfield(Object,'DriftControl');
end
if isfield(Object,'plot1')==1
    Object=rmfield(Object,'plot1');
end
if isfield(Object,'plot2')==1
    Object=rmfield(Object,'plot2');
end
if isfield(Object,'Check')==1
    Object=rmfield(Object,'Check');
end
for i=1:nObj    
    Object(i).pTrack=[];
end      
for i=1:nObj    
    Object(i).pTrackSelectW=[];
end      
for i=1:nObj    
    Object(i).pTrackSelectB=[];
end      

if n==0
    Object(1)=[];
end

function color=ColorCode(char)
switch(char)
    case 'b'
        color=[0 0 1];
    case 'r'
        color=[1 0 0];
    case 'g'
        color=[1 0 0];
    case 'p'
        color=[1 0.5 0.5];        
    case 'o'
        color=[1 0.5 0];                
    case 'y' 
        color=[1 1 0];
end