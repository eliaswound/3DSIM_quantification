function [ f, xb ] = evaluate( model, x )
  global xg yg
  
  if nargout == 1 % calculate value of function
    f = x(6) * exp( - ( (xg-x(1)) ./ x(3) ).^2 ...
                    - ( (yg-x(2)) ./ x(4) ).^2 ...
                    + x(5) .* (xg-x(1)) .* (yg-x(2)) );
                
  else % calculate value of function and jacobian 'xb'
    xb = zeros( numel( xg ), 6 ); % allocate memory
    
    % calculate temporary variables and value of function in ...
    % ... forward direction
    tempx = (xg-x(1)) ./ x(3);
    tempy = (yg-x(2)) ./ x(4);
    temp1 = x(5) .* (xg-x(1));
    temp2 = temp1 .* (yg-x(2)) - tempy.^2 - tempx.^2;
    % ... backward direction
    tempb = exp(temp2);
    f = x(6) .* tempb;
    tempcb = (yg-x(2)) .* f;
    tempyb = -(2.0 .* tempy .* f ./ x(4));
    tempxb = -(2.0 .* tempx .* f ./ x(3));
    
    % calculate derivative
    xb(:,1) = tempxb + x(5) .* tempcb;
    xb(:,2) = tempyb + temp1 .* f;
    xb(:,3) = tempx .* tempxb;
    xb(:,4) = tempy .* tempyb;
    xb(:,5) = - (xg-x(1)) .* tempcb;
    xb(:,6) = - tempb;
  end
  
end