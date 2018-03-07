%generates a vite trajectory assuming the initial position and velocities
%are null. Uses Euler approximation with dt. Uses the ration beta/alpha and not
%beta as a parameter. (intial_pos,target_pos,alpha,ratio,dt)
function trajectory = generate_vite(initial_pos,target_pos,alpha,ratio,dt)
    pos_i = initial_pos;
    vel_i = 0;
    acc_i = 0;
    epsilon = 0.01;
    i = 1;
    %initialize the trajectory to 4 seconds by default, will be shortened
    %if the motion is seen to have stopped before pos - target < epsilon
    %and vel < epsilon 0
    trajectory = zeros(ceil(2.0/dt),3);
    trajectory(i,:) = [initial_pos,0,0];
    while (norm(pos_i-target_pos) > epsilon) || (vel_i > epsilon)
        i = i +1;
        if i > length(trajectory)
            trajectory = [trajectory;zeros(ceil(2.0/dt),3)];
        end
        acc_i = alpha*(-vel_i + alpha*ratio*(target_pos-pos_i));
        vel_i = acc_i*dt + vel_i;
        pos_i = vel_i*dt + pos_i;
        trajectory(i,:) = [pos_i,vel_i,acc_i];
    end
    if i < length(trajectory)
        trajectory = trajectory(1:i,:);
    end
end