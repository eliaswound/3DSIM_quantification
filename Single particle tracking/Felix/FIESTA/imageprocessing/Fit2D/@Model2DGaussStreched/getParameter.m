function [ model, x0, dx, lb, ub ] = getParameter( model, data )
  global fit_pic
  
  % calculate position in region of interest
  c = double( model.guess.x - data.offset );

  % fill in missing parameters
  if isempty( model.guess.w )
%     [ width, height ] = GuessObjectData( c, [0 pi/2 pi 3*pi/2], data );
%     width = 2*width^2;
%     model.guess.w =  [ width width 0 ];
%     
%     if isempty( model.guess.h )
%       model.guess.h = height;
%     end
    model.guess.w = [ 5.0 5.0 0.0 ];
  end
%   else
    if isempty( model.guess.h )
      model.guess.h = interp2( fit_pic, c(1), c(2), '*nearest' ) - double( data.background );
    end
%   end
  
  % setup parameter array
  %    [ X  Y           sigmaX  sigmaY         Corr  Height           ]
  x0 = [ c(1:2)         model.guess.w(1:3)           model.guess.h    ];
  dx = [ 1  1           model.guess.w(1:2)/10  1     model.guess.h/10 ];
  lb = [ 1  1           0       0              0     model.guess.h/10 ];
  ub = [ data.rect(3:4) 10*model.guess.w(1:2)  Inf   model.guess.h*10 ];
end