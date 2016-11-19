classdef (Abstract) Game < handle
    %GAME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        reward = get_reward(self, site, next_site);
        rewards = get_all_rewards(self, site);
        [dist, waitTime, satisf] = get_eltwise_reward(self, site, next_site); 
        [dists, waitTimes, satisfs] = get_eltwise_rewards(self, site);
    end
    
end

