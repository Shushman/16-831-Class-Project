classdef Map
    %MAP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        siteDist % pairwise distance. 
        locations % 2xn where ith column is the (x,y) loc of ride i
        im;
        map;
        m
    end
    
    methods
        function self = Map(n, m)
            % Uniformly random
            self.m = m;
            X = ceil(m*rand(2, n));
            siteDist = zeros(n);
            for i = 1:n
                for j = 1:n
                    siteDist(i,j) = norm(X(:,i) - X(:,j));
                end
            end
            self.locations = X;
            self.siteDist = siteDist;
           
            figure(2);
            f = getframe;
            [self.im,self.map] = rgb2ind(f.cdata,256,'nodither');

        end
        
        % draws expected reward from current site
        function [im, map] = draw(self, site, nextsite, game, filename)
            
            figure(2);clf;hold on;
            n = size(self.locations, 2);
            m = self.m;
            means = game.means;
            lambdas = game.lambdas;
           
            % siteDist
            if site > 0
                siteDist = self.siteDist(site,:);
            else 
                siteDist = ones(1,n)*game.m0;
            end
            
            % expected rewards
            rewards = -game.weightDist*siteDist ...
                     - game.weightWait*lambdas ...
                     + game.weightRide*means;
            
            rewards = (rewards - min(rewards) + 1);
            rewards = rewards / max(rewards);
            
            % all rides
            for i = 1:n
                loc = self.locations(:,i);
                x = loc(1); 
                y = loc(2);
                s = scatter(x, y, 200);
                s.LineWidth = 0.6;
                c = [rewards(i), 1-rewards(i), 0];
                s.MarkerFaceColor = c;
                s.MarkerEdgeColor = c;

            end
            
            if site > 0
                pos = self.locations(:,site);
            else 
                pos = [m/2, m/2]';
            end
            nextpos = self.locations(:,nextsite);
            
            % draw current site and arrow to next site
            if site ~= nextsite
                direction = nextpos - pos;
                quiver(pos(1), pos(2), direction(1), direction(2), 'LineWidth', 3, 'color', 'r');
            else
                quiver(pos(1)-2, pos(2)-2,  2, 2, 'LineWidth', 3, 'color','b');
            end
            cmap = [linspace(0,1,64); linspace(1, 0, 64); zeros(1,64)]';
            colormap(cmap);
            colorbar
            % axis
            plot([0.5 0.5], [0.5,m+0.5], 'k', 'LineWidth',2);
            plot([m+0.5,0.5], [m+0.5,m+0.5],'k','LineWidth',2);
            plot([0.5 m+0.5], [0.5,0.5], 'k', 'LineWidth',2);
            plot([m+0.5,m+0.5], [0.5,m+0.5],'k','LineWidth',2);
            axis([0,11,0,11])
            axis equal tight
            drawnow;
            saveas(gcf,strcat('../fig/', filename, ...
                   sprintf('%.2d',game.round), '.png'));

            pause(0.001);
            hold off;
            im = self.im;
            map = self.map;
        end
        
        
        
    end
    
end

