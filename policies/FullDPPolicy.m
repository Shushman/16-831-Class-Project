classdef FullDPPolicy < Policy
    %FullDPPolicy This is a concrete class implementing UCB.

    properties
        % Member variables
        nSites
        round
        game
        actions
        initAction
    end
    
    methods
        function self = FullDPPolicy(game)
            % Initialize
            self.nSites = game.nSites;
            self.round = 0;
            self.game = game;
            self.actions = zeros(game.nSites,1);
            self.initAction = 0;
        end
        
        function action = decision(self, site, ~)
            
            if site < 1
                action = self.initAction;
            else
                action = self.actions(site);
            end
        end
        
        function [] = update(self, site, action)
            if site < 1
                self.initAction = action;
            else
                self.actions(site) = action;
            end
        end        
        
        
    end

end
