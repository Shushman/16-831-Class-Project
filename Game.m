classdef (Abstract) Game < handle
    %GAME This abstract class defines an amusement park setting.
    %   Detailed explanation goes here
    
    % Member variables to define the amusement park problem
    properties
        nSites      %Number of park sites
        siteDist    %Matrix of Pairwise distances between sites
        m0          %Fixed distance from starting point to all sites
        means       %1-x-n Mean satisfaction from ride
        sigmas      %1-x-n Std. Deviations of rides
        lambdas     %1-x-n Vector of Poisson parameters
    end
    
    methods (Abstract)
        
        reward = get_reward(state,action);
        
        
    end
    
end

