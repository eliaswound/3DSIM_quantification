function status = openhelp( file, anchor )
global DirRoot;
%OPENHELP opens the FIESTA help. It jumps directly to the specified position
% arguments:
%   file    the internal path and file in the help (optional)
%   anchor  the anchor name in that file (optional)
% results:
%   status  the returned status code (should be 0 if successful)

  path_to_help = [DirRoot 'FIESTA' filesep 'Help' filesep];
  if nargin == 0
    status = dos( [ 'hh.exe ms-its:' path_to_help 'FIESTA Help.chm &' ] );
  elseif nargin == 1
    status = dos( [ 'hh.exe ms-its:' path_to_help 'FIESTA Help.chm::/' file '&' ] );
  else
    status = dos( [ 'hh.exe ms-its:' path_to_help 'FIESTA Help.chm::/' file '#' anchor '&' ] );
  end
end
