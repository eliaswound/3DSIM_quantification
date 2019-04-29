function varargout=fLoad(file,varargin)
f=who('-file',file);
warning off all
for n=1:length(varargin)
    c=strcmp(varargin(n),f);
    if max(c)>0
        try
            var=load(file,varargin{n});
            varargout{n}=var.(varargin{n});
        catch
            varargout{n}=[];            
        end
    else
        varargout{n}=[];
    end
end
warning on all