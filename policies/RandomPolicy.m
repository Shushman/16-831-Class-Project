classdef RandomPolicy < Policy
    %RANDOMPOLICY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        game
        nSites
    end
    
    methods
        function self = RandomPolicy(game)
            self.game = game;
            self.nSites = game.nSites;
        end
        function nextsite = decision(self, site, round)
            % choose among n-1 sites
            nextsite = randsample(self.nSites - 1, 1);
            if nextsite >= site
                nextsite = nextsite + 1;
            end
        end

    end
    
end

