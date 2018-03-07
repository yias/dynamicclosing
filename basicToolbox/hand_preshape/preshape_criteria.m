function [Areas,Distance]=preshape_criteria(jointAngles,h,graspType)


% Computes two preshape criteria: 
%       
%       Areas:      the area/surface of the fingertips
%       Distance:   the aperture of the hand i.e the distance between the
%                   fingertips of the thumb and the index finger
%
%
% Inputs:
%       
%       jointAngles:    the joint angles of the fingers
%       h:              the kinematic model of the hand
%       graspType:      the grasp type, a number from 1 to 5



l=size(jointAngles,1);

tips_position=zeros(l,3,5);
Areas=zeros(l,1);
Distance=zeros(l,1);



    for i=1:l
    
    
        thumb=h.Fingers(1).fkine(jointAngles(i,3:7));
        index=h.Fingers(2).fkine(jointAngles(i,8:11));
        middle=h.Fingers(3).fkine(jointAngles(i,12:15));
        ring=h.Fingers(4).fkine(jointAngles(i,16:19));
        litle=h.Fingers(5).fkine(jointAngles(i,20:23));

        tips_position(i,:,1)=[thumb(1,4),thumb(2,4),thumb(3,4)];
        tips_position(i,:,2)=[index(1,4),index(2,4),index(3,4)];
        tips_position(i,:,3)=[middle(1,4),middle(2,4),middle(3,4)];
        tips_position(i,:,4)=[ring(1,4),ring(2,4),ring(3,4)];
        tips_position(i,:,5)=[litle(1,4),litle(2,4),litle(3,4)];

        Areas(i)=calcAreas(tips_position(i,:,1),tips_position(i,:,2),tips_position(i,:,3),tips_position(i,:,4),tips_position(i,:,5),graspType);
        Distance(i)=calcDistance(tips_position(i,:,1),tips_position(i,:,2),tips_position(i,:,5),graspType);

    end


    
end