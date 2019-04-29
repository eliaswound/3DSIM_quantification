function objects = InterpolateData( objects, img, params )
%INTERPOLATEDATA uses the data gained by fitting to calculate further useful
%details of the objects. The additional values are stored as new fields inside
%the 'objects' struct.
% arguments:
%   objects   the objects array
%   img       the original grey version of the image
%   params    the parameter struct
% results:
%   objects   the extended objects array

  error( nargchk( 3, 3, nargin ) );
  
  global error_events;
  
  % run through all objects
  obj_id = 1;
  while obj_id <= numel(objects)
    
    if isempty( objects(obj_id).p ) % empty objects have to be ignored
      objects(obj_id) = [];
      error_events.empty_object = error_events.empty_object + 1;
      continue
    end
    
    % estimate total length, center of object and interpolate additional data
    if numel( objects(obj_id).p ) <= 1 % point object
      
      % calculate additional data
      objects(obj_id).center_x = objects(obj_id).p(1).x(1) * params.scale;
      objects(obj_id).center_y = objects(obj_id).p(1).x(2) * params.scale;
      objects(obj_id).com_x = objects(obj_id).p(1).x(1) * params.scale;
      objects(obj_id).com_y = objects(obj_id).p(1).x(2) * params.scale;
      objects(obj_id).height = objects(obj_id).p(1).h;
      objects(obj_id).radius = objects(obj_id).p(1).r * params.scale;      
      objects(obj_id).width = objects(obj_id).p(1).w * params.scale;
      objects(obj_id).orientation = NaN; % there is no orientation for a bead
      objects(obj_id).length = double_error( 0 );
      
      if numel( objects(obj_id).p(1).w ) > 1
        width = mean( objects(obj_id).p(1).w(1:2) );
      else
        width = objects(obj_id).p(1).w(1);
      end

      % save point in final data struct
      objects(obj_id).data = struct( 'x', double( objects(obj_id).p(1).x(1) ) * params.scale, ...
                                     'y', double( objects(obj_id).p(1).x(2) ) * params.scale, ...
                                     'l', 0, ...
                                     'w', width * params.scale, ...
                                     'b', double( objects(obj_id).p(1).b ), ...
                                     'h', interp2( double(img), double( objects(obj_id).p(1).x(1) ), ...
                                                   double( objects(obj_id).p(1).x(2) ) ) - ...
                                          double( objects(obj_id).p(1).b ) ...
                                   );
      
    else % elongated object
      
      % init variables
      seg_length = zeros( 1, numel(objects(obj_id).p) );  %<< the length start of each segment on the filament
      x_coeff = zeros( numel(objects(obj_id).p) - 1, 3 ); %<< the 3 coefficients for the interpolation in x-direction for each segment
      y_coeff = zeros( numel(objects(obj_id).p) - 1, 3 ); %<< the 3 coefficients for the interpolation in y-direction for each segment

      % run through all sections
      k = 1;
      while k < numel( objects(obj_id).p ) % run through all points but the last one
        
        % get the two points in question
        s = objects(obj_id).p(k);
        e = objects(obj_id).p(k+1);
        
        % ignore errors for the spline interpolation (converting to double)
        s.x = double( s.x );
        s.o = double( s.o );
        e.x = double( e.x );
        e.o = double( e.o );

        % distinguish several cases of the positions of the two points
        if all( s.x == e.x ) % identical points (this should not happen though) => ignore

          error_events.degenerated_fil = error_events.degenerated_fil + 1;
          continue;
          
        elseif abs( e.x(1) - s.x(1) ) < eps( e.x(2) ) % points directly above each other
          
          if e.x(2) > s.x(2)
            p = e.x(2) - s.x(2);
            rot = pi/2;
          else
            p = s.x(2) - e.x(2);
            rot = -pi/2;
          end
          
        else % general case

          % rotate space to get a real function
          rot = atan2( e.x(2) - s.x(2), e.x(1) - s.x(1) );
          p = ( e.x(1) - s.x(1) ) ./ cos( rot ); %<< distance between points
          
        end

        % calculate the slope for the rotated version
        slope1 = tan( s.o - rot );
        slope2 = tan( e.o - rot );

        % calculate cubic function coefficients (the formulas are derived in the
        % documentation (take non-matrix functions, because otherwise
        % double_error wont work
        c(1) = ( slope1 + slope2 ) ./ p.^2;
        c(2) = -( 2 * slope1 + slope2 ) ./ p;
        c(3) = slope1;

        % rotate back to get the real space cubic coefficients
        % and transform to have parameter in range [0 1]
        x_coeff(k,:) = [ -sin(rot)*c(1)*p.^3 -sin(rot)*c(2)*p.^2 (-sin(rot)*c(3)+cos(rot))*p ];
        y_coeff(k,:) = [  cos(rot)*c(1)*p.^3  cos(rot)*c(2)*p.^2 ( cos(rot)*c(3)+sin(rot))*p ];

        % calculate length segment without error - error will be determined later
        F = @(t)sqrt( (3*x_coeff(k,1)*t.^2 + 2*x_coeff(k,2)*t + x_coeff(k,3) ).^2 + ...
                      (3*y_coeff(k,1)*t.^2 + 2*y_coeff(k,2)*t + y_coeff(k,3) ).^2 );
                    
        length_integral = quad( F, 0, 1 ); %<< integrate arc length
        
        if length_integral == 0 % degenerated segment
          % delete point of object - this should happen very seldom, such that
          % it should be faster to preallocate memory for lists and delete
          % entries, if necessary.
          
          seg_length(end) = [];
          x_coeff(end,:) = [];
          y_coeff(end,:) = [];
          objects(obj_id).p(k) = [];
          
        else
          
          % add segment length to list
          seg_length(k+1) = length_integral;
          k = k + 1; % step to next point
          
        end
        
      end % of run through all sections

      % estimate length and its error
      try
        objects(obj_id).length = double_error( sum( seg_length ), ...
          norm( [ objects(obj_id).p( 1 ).x(1).error * cos( objects(obj_id).p( 1 ).o.value ), ...
                  objects(obj_id).p( 1 ).x(1).error * sin( objects(obj_id).p( 1 ).o.value ) ] ) + ...
          norm( [ objects(obj_id).p(end).x(1).error * cos( objects(obj_id).p(end).o.value ), ...
                  objects(obj_id).p(end).x(1).error * sin( objects(obj_id).p(end).o.value ) ] ) ...
        );
      catch
        warning( 'MPICBG:FIESTA:PointNotFitted', 'one point has not been fitted!' );
        error_events.point_not_fitted = error_events.point_not_fitted + 1;
        objects(obj_id).length = sum( seg_length );
      end
      
      % estimate orientation
      objects(obj_id).orientation = atan2( objects(obj_id).p(end).x(2) - objects(obj_id).p(1).x(2), ...
                                           objects(obj_id).p(end).x(1) - objects(obj_id).p(1).x(1) );
    
      % determine center of mass of object
      weigth = seg_length + [ seg_length(2:end) 0 ];
      weigth_sum = sum( weigth );
      p = transpose( reshape( [ objects(obj_id).p.x ], 2, [] ) );
      objects(obj_id).com_x = sum( weigth' .* p(:,1) ) ./ weigth_sum * params.scale;
      objects(obj_id).com_y = sum( weigth' .* p(:,2) ) ./ weigth_sum * params.scale;
      objects(obj_id).height = sum( weigth .* [ objects(obj_id).p.h ] ) ./ weigth_sum;
      objects(obj_id).width = sum( weigth .* [ objects(obj_id).p.w ] ) ./ weigth_sum * params.scale;
      objects(obj_id).radius = NaN;      
      % determine center of object
      middle = double( objects(obj_id).length ) * 0.5;
      len = 0;
      for k = 2:numel( seg_length )
        len = len + seg_length(k);
        if len > middle
          break
        end
      end
      % => k stores the index of the middle section
      
      t = 1 - ( len - middle ) ./ seg_length(k);
      x_c = x_coeff( k-1, 1:3 );
      y_c = y_coeff( k-1, 1:3 );
      
      objects(obj_id).center_x = ( x_c(1) * t.^3 + x_c(2) * t.^2 + x_c(3) * t + double( objects(obj_id).p(k-1).x(1) ) ) * params.scale;
      objects(obj_id).center_y = ( y_c(1) * t.^3 + y_c(2) * t.^2 + y_c(3) * t + double( objects(obj_id).p(k-1).x(2) ) ) * params.scale;

      % calculate total length
      objects(obj_id).length = objects(obj_id).length * params.scale;

      % interpolate additional data:

      % preallocating
      l = 0;
      x = double( objects(obj_id).p(1).x(1) ); %<< array containing the x-positions
      y = double( objects(obj_id).p(1).x(2) ); %<< array containing the y-positions
      i_s = 2;
      
      % spatial interpolation
      for j = 1 : size( x_coeff, 1 ) % run through all object chunks
        t = linspace( 0, 1, ceil( seg_length(j+1) ) );
        t = t(2:end); % remove first point, because its the same as the last one of the last chunk
        i_e = i_s + numel(t) - 1;
        l(i_s:i_e) = sum( seg_length(1:j) ) + t * seg_length(j+1);

        % calculate positions using the spline interpolation data
        x_c = x_coeff(j,1:3);
        y_c = y_coeff(j,1:3);
        x(i_s:i_e) = x_c(1)*t.^3 + x_c(2)*t.^2 + x_c(3)*t + double( objects(obj_id).p(j).x(1) );
        y(i_s:i_e) = y_c(1)*t.^3 + y_c(2)*t.^2 + y_c(3)*t + double( objects(obj_id).p(j).x(2) );
        i_s = i_e + 1;
      end

      % interpolate background, amplitude and width
      back = interp1( cumsum( double( seg_length ) ), double( [ objects(obj_id).p.b ] ), l, 'cubic' );
      ampli = interp2( double(img), x, y ) - back;
      sigma = interp1( cumsum( double( seg_length ) ), double( [ objects(obj_id).p.w ] ), l, 'cubic' );

      % save points in final data struct
      for j = 1 : numel(x)
        objects(obj_id).data(j) = struct( ...
            'x', x(j) * params.scale, ...
            'y', y(j) * params.scale, ...
            'l', l(j) * params.scale, ...
            'w', sigma(j) * params.scale, ...
            'b', back(j), 'h', ampli(j) );
      end
      
    end % if object is pointlike or elongated

    % pass creation time given by external caller to the struct, such that it
    % migth be used later on
    objects(obj_id).time = params.creation_time;
    
    % step to the next object
    obj_id = obj_id + 1;
    
  end % of running through all objects
  
  % make sure the structure is created, even if no object exists
  if numel( objects ) == 0
    objects = struct( 'center_x', {}, 'center_y', {}, 'com_x', {}, ...
      'com_y', {}, 'height', {}, 'width', {}, 'orientation', {}, ...
      'length', {}, 'data', {}, 'time', {}, 'radius', {});
  else
    % delete unnecessary data
    objects = rmfield( objects, 'p' );
  end
  
end
