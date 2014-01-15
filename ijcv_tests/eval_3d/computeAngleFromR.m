function [ pitch, yaw, roll ] = computeAngleFromR( R )

    [z y x] = dcm2angle(R);

    z_angle = z*180./pi;
    y_angle = y*180./pi;
    x_angle = x*180./pi;
    assert(abs(z_angle)<=180);
    assert(abs(y_angle)<=90);
    assert(abs(x_angle)<=180);
    
    %pitch = 180 - x_angle;
    if x_angle >=0
        pitch = -abs(x_angle-90)+90;
    else
        pitch = abs(x_angle+90)-90;
    end
    yaw = y_angle;
    % roll = z_angle;
    assert(x_angle > 90 || x_angle < -90);
    roll = -z_angle;

end

