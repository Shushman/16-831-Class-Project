classdef Game < handle
    %GAME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        round
        weightDist           % weight on distance
        weightWait          % weight on wait time
        weightRide           % weight on ride satisfaction
        nRounds     % number of total rounds

    end
    
    methods
        function reset(self)
            self.round = 0;
        end
        
        function [reward, dist, waitTime, satisf] = get_reward(self, site, next_site)
            if nargin == 3
                [dist, waitTime, satisf] = get_eltwise_reward(self, site, next_site);
            else
                [dist, waitTime, satisf] = get_eltwise_reward(self, site);
            end
            reward = compute_reward(self.weightDist, self.weightWait, self.weightRide,...
                                    dist, waitTime, satisf);                 
        end
             
        [dist, waitTime, satisf] = get_eltwise_reward(self, site, next_site); 
    end
    
end

