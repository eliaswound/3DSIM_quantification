function value = transformResult( model, x, xe, data )
  value.x = double_error( x(1:2) + data.offset, xe(1:2) );
  value.o = double_error( [] );
  
  % rearrange width parameters
  value.w(1:3) = double_error( zeros(1,3) ); % init width values
  if x(5) == 0
    value.w(1:2) = 2.35482 * double_error( x(3:4), xe(3:4) );
    value.w(3) = double_error( 0, 0 );
  else
    s = double_error( x(3:5), xe(3:5) ); % get transformed values
    value.w(3) = prod(s) * 0.5; % calculate correlation
    t = sqrt( 2 * ( 1 - s(3)*s(3) ) );
    value.w(1:2) = 2.35482 * s(1:2) ./ t; % calculate both widths and transform them to FWHM
  end
  value.h = double_error( x(6), xe(6) );
  value.r = double_error( [] );  
  value.b = data.background;
end