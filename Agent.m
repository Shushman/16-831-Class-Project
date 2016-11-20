classdef Agent < handle
    %AGENT One who actively moves around with a policy and collects reward
    
    properties
        policy
        cumReward % cumulative reward
        game
        site
        f
        g
        h
    end
    
    methods
        function self = Agent(policy, game)
            self.policy = policy;
            self.game = game;
            self.cumReward = 0;
            self.site = 0; %initial site
            self.f = game.f;
            self.g = game.g;
            self.h = game.h;
        end
        
        function [reward, nextsite, cumReward, satisf, waitTime] = ride(self)
            nextsite = self.policy.decision(self.site, self.game.round);
            [dist, waitTime, satisf] = self.game.get_eltwise_reward(self.site, nextsite); 
            reward = -self.f*dist - self.g*waitTime + self.h*satisf;
            self.cumReward = self.cumReward + reward;
            cumReward = self.cumReward;
            self.site = nextsite;
        end
 
    end
    
end

