classdef plate < body
    %a plate is a quirk body with conductive properties
    %   Detailed explanation goes here
    
    properties
        sigma = 1; %conductivity of the plate
        loops = {};
        xLoops = 1; %number of current loops in yz plane
        yLoops = 1; %number of current loops in xz plane
        zLoops = 1; %number of current loops in xy plane
        xr = 0;
        yr = 0;
        zr = 0;
        loopPts = 20; %number of points to evaluate forces around the edge of the loop
        rho = 28.2E-9 %resistivity of the plate
        mu = 1.2E-6; %magnetic permiability of the plate
    end
    
    methods
        function obj = plate(pos,att, varargin)
            if nargin == 0;
                pos = [0;0;0];
                att = [0;0;0;1];
            end
            
            %default size of plate = 0.005mx1mx1m
            defaultSize = '0.005x0.25x0.25';
           obj = obj@body(pos, att, 'shape','box','size',defaultSize);
           obj.xr = obj.sy/2;
           obj.yr = obj.sx/2;
           obj.zr = obj.sx/2;
        end
        %% add the loops on a plate generated by a magnet
        function plt = genLoops(plt,mag)
            %adds loops to the plate generated by the magnet
            
            xCoords = 0;
            yCoords = 0;
            zCoords = 0;
            if plt.xLoops > 1
                xCoords = linspace(-plt.sx/2,plt.sx/2,plt.xLoops);
            end
            if plt.yLoops > 1
                yCoords = linspace(-plt.sy/2,plt.sy/2,plt.yLoops);
            end
            if plt.zLoops > 1
                zCoords = linspace(-plt.sz/2,plt.sz/2,plt.zLoops);
            end
            %generate loops in the x direction
            for x = xCoords
     %           disp(plt.xr);
                plt.loops{length(plt.loops)+1} = iLoop(plt,mag,plt.xr,'x',x);
            end
            %generate loops in the y direction
            for y = yCoords
                plt.loops{length(plt.loops)+1} = iLoop(plt,mag,plt.yr,'y',y);
            end
            %generate loops in the z direction
            for z = zCoords
                plt.loops{length(plt.loops)+1} = iLoop(plt,mag,plt.zr,'z',z);
            end
            
        end
        %% update the loops on the plate
        %this made me realize that the loops should remember what magnet
        %made them - it will make everything easier
        function plt = updateLoops(plt)
            for i = 1:length(plt.loops)
                plt.loops{i}.loopUpdate();
            end
        end
    end
    methods(Static)
        function F = plateForce(plt,mag,t)
            if isempty(plt.loops) == 1
                warning('The plate has no current loops');
            else
                plt.updateLoops();
                
            end
            
            %returns the force on the plate by the magnet in inertial coordinates
            F_bod = zeros(3,1); %keeps track of the net force in the body coordinates
            for loop = plt.loops
                F_bod = F_bod + iLoop.loopForce(loop{:},mag,plt.loopPts);
            end
            %convert body force to inertial force
            bod2iner = inv(quat2dcm(qq2mq(plt.att)));
            F = bod2iner*F_bod; %dividing by iner2bod converts bod coords to inertial coords
        end
        
    end
    
end

