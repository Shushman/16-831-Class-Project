classdef ConstantPolicy < Policy
    %ConstantPolicy Always choose the same site
    
    properties
        game
        nSites
        site
    end
    
    methods
        % always choose site
        function self = ConstantPolicy(game, site)
            self.game = game;
            self.nSites = game.nSites;
            self.site = site;
        end
        function nextsite = decision(self, site, round)
            nextsite = self.site;
        end

    end
    
end

