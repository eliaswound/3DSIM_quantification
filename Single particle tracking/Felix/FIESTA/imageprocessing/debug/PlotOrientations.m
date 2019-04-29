function PlotOrientations( p, c, l )
%PLOTORIENTATIONS plots the points 'p' with ther orientation to the current graph
% arguments:
%   p   an n-by-3 vector of point-coordinates and orientations
%   c   an optional color string

  if nargin < 2
    c1 = 'g';
    c2 = 'r';
  else
    c1 = c;
    c2 = c;
  end
  
  if nargin < 3
    l = 10;
  end
  
  if numel( p ) > 0
    l = [0 l];
    hold on
    if isstruct( p )
      for i = 1:numel(p)
        if ~isempty( p(i).o )
          plot( l * double( cos(p(i).o) ) + double( p(i).x(1) ), ...
                l * double( sin(p(i).o) ) + double( p(i).x(2) ), [ c1 '-' ] );
        end
        plot( double( p(i).x(1) ), double( p(i).x(2) ), [ c2 'x' ], 'MarkerSize', 3 );
      end
    else
      for i = 1:size(p,1)
        plot( l * cos(p(i,3)) + p(i,1), l * sin(p(i,3)) + p(i,2), [ c1 '-' ] );
      end
      plot( p(:,1), p(:,2), [ c2 'x' ], 'MarkerSize', 3 );
    end
    hold off
  end
end
