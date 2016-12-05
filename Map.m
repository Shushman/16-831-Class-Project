classdef Map
    %MAP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        siteDist % pairwise distance. 
        locations % 2xn where ith column is the (x,y) loc of ride i
        im;
        map;
        gridSize
        m0 % initial distance to all sites, Should be [0,1]
        nSites % number of sites
    end
    
    methods
        function self = Map(nSites, gridSize, m0, maptype)
            self.nSites = nSites;
            self.gridSize = gridSize;
            self.m0 = m0;
            assert (m0 <= 1 && m0 >= 0);

            if strcmp(maptype,'uniform')
                % Uniformly random
                X = ceil(gridSize*rand(2, nSites));
            else                
                nparts = nSites / 4;

                % X, Y location of rides
                XMAX = gridSize;
                YMAX = gridSize;
                GRIDS = XMAX*YMAX;
                [X,Y] = meshgrid(1:XMAX,1:YMAX);
                X = X(:);
                Y = Y(:);
                index = randperm(GRIDS,nparts);
                X = X(index);
                Y = Y(index);
                Cntr = [X';Y'];
                Std = 5*ones(1,nparts);

                X = [];

                n = round(nSites/nparts);
                for i = 1:nparts
                    X = [X randn(2,n)*Std(i)+repmat(Cntr(:,i),1,n)];
                end
            end
            
            siteDist = pdist2(X',X');
            self.locations = X;
            self.siteDist = siteDist / max(max(siteDist));

        end
        
        function draw_map(self)
            figure(1);clf;
            m = self.gridSize;
            hold on;
            scatter(self.locations(1,:), self.locations(2,:), 200, 'Filled');
            
            % axis
            plot([0.5 0.5], [0.5,m+0.5], 'k', 'LineWidth',2);
            plot([m+0.5,0.5], [m+0.5,m+0.5],'k','LineWidth',2);
            plot([0.5 m+0.5], [0.5,0.5], 'k', 'LineWidth',2);
            plot([m+0.5,m+0.5], [0.5,m+0.5],'k','LineWidth',2);
            axis([0,m+1,0,m+1])
            axis equal tight
            
        end
        
        % draws expected reward from current site
        function draw(self, site, nextsite, game, filename)
            
            figure(2);clf;hold on;
            n = size(self.locations, 2);
            m = self.gridSize;
            means = game.means;
            lambdas = game.lambdas;
           
            % siteDist
            if site > 0
                siteDist = self.siteDist(site,:);
            else 
                siteDist = ones(1,n)*game.m0;
            end
            
            % expected rewards
            rewards = compute_reward(game.weightDist, game.weightWait, game.weightRide,...
                                     siteDist, lambdas, means);
                                     
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
            axis([0,m+1,0,m+1])
            axis equal tight
%             drawnow;
            saveas(gcf,strcat('../fig/', filename, ...
                   sprintf('%.3d',game.round), '.png'));

%             pause(0.001);
            hold off;
        end
        
        
        
    end
    
end

