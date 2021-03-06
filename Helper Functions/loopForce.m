function [ F ] = loopForce(loop, mag, loop_pts)
%Finds the force of a single magnet on a single current loop (in the body
%coordinates)
 
%set alpha as pi over 2 for now, change this later
 %alpha = pi/2;
 %these properties should go into the plate
%  omega = 60*2*pi;
%  L = 11.7 *10^-3;
%  R = 1.44;
%  alpha = atan2(omega*L,R);
 r = loop.radius;
 f_thetas = linspace(0,2*pi*(loop_pts -1)/loop_pts,loop_pts);
 F = zeros(3,1);
 
 xMag_bod = mag.pos-loop.plate.pos; %vector to center of plate from magenet in body coordinates
 mMag = att2vec(mag.att,'z');
 rotM = quat2dcm(qq2mq(loop.plate.att));
 mMag_bod = rotM*mMag; %magnet moment in body coordinates
 
 
 switch loop.perpAxis
 %current in YZ plane
     case 'x'
         x = loop.perpCoord;
        for j = 1:loop_pts
            
            y = r*cos(f_thetas(j));
            z = r*sin(f_thetas(j));
            currentVec = loop.cur*[0;-sin(f_thetas(j));cos(f_thetas(j))]; %create the current vector
            F = F + iCrossB(currentVec,x,y,z,mMag_bod,xMag_bod); %sum up the forces on the current around the loop
        end
    %Current in XZ plane
     case 'y'
        y = loop.perpCoord;
        for j = 1:loop_pts
            
            x = r*cos(f_thetas(j));
            z = r*sin(f_thetas(j));
            currentVec = loop.cur*[-sin(f_thetas(j));0;cos(f_thetas(j))]; %create the current vector
            F = F + iCrossB(currentVec,x,y,z,mMag_bod,xMag_bod); %sum up the forces on the current around the loop
        end
    %current in XY plane
     case 'z'
         z = loop.perpCoord;
        for j = 1:loop_pts
            
            x = r*cos(f_thetas(j));
            y = r*sin(f_thetas(j));
            currentVec = loop.cur*[-sin(f_thetas(j));cos(f_thetas(j));0]; %create the current vector
            F = F + iCrossB(currentVec,x,y,z,mMag_bod,xMag_bod); %sum up the forces on the current around the loop
        end
 end
 
 F = sin(loop.phase - mag.phase)*F; %scale the forces by the phase difference between the current and the field over the entire cycle

end
