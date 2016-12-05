function [map, varyingGame] = varyingPark(parktype, nSites, gridSize, filename)

map = Map(nSites, gridSize, 1, parktype);

% parameters for functions
T = 60+rand(1,nSites)*40;
T = T;
M = rand(1,nSites);
offset = rand(1,nSites);
phase = rand(1,nSites)*2*pi;

% parameters
satisfMeans = randi(40,1,nSites);
satisfMeans = satisfMeans / max(satisfMeans);
satisfSigmas = 0.1*rand(1,nSites);
waitTimeF = cell(1,nSites);
waitTimeSigmas = 0.1*rand(1,nSites);

for i = 1:nSites
    waitTimeF{i}=timevaryingF(offset(i), M(i), T(i), phase(i),waitTimeSigmas(i));
end
nRounds = 150;
w = [1 1 1]/3;
f = w(1); g = w(2); h = w(3);

varyingGame = VaryingGame(map,satisfMeans,satisfSigmas,waitTimeF,f,g,h,nRounds);

% save data
if nargin == 4
    save(filename,'map','satisfMeans','satisfSigmas','waitTimeF','nRounds','f','g','h');
end

figure(4);clf;
hold on;
for i = 1:nSites
    w = waitTimeF{i}(1:nRounds);
    plot(w(1,:));
end

title('WaitTime Lambdas');
hold off;

figure(5);clf;hold on;
X = map.locations;
cmap = colormap(hot);
for i = 1:nSites
    color = cmap(round(satisfMeans(i)*64),:);
    scatter(X(1,i),X(2,i),300,'Filled',...
           'MarkerEdgeColor','k', 'MarkerFaceColor', color);
end
colorbar;
axis([0 gridSize 0 gridSize]);
hold off;

end