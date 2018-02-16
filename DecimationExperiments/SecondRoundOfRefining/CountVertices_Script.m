%% This script counts the vertex charge in the Decimated Spin Systems.
clear

Directory = 'Dataset/';

F = dir(Directory);
F(arrayfun(@(X)isempty(strfind(X.name,'.bmp')),F))=[];

Stats = struct(...
    'Coord4',cell(size(F)),...
    'Coord3',cell(size(F)),...
    'Charge4',cell(size(F)),...
    'Charge3',cell(size(F)));

for i = 1:length(F)
%for i = 1
    clf
    figure(1)
    load([Directory,F(i).name(1:end-4),'_Spins.mat'])

    load([Directory,F(i).name(1:end-4),'.mat'])

    S = RemoveDuplicates(S,0.1);
    clf
    display(S)
    
    NominalDecimationFraction = str2double(F(i).name(12:13));
    %% 
    
    S=FindVertices(S);
    line(S.AllVertices(:,1),S.AllVertices(:,2),...
        'Marker','o','LineStyle','none')
    
    %% Get Vertex Charge
    
    Su = S.ScaleSpinSystem(1./ParamSave.Scale);
    %[~,OrI] = min(sqrt(sum(Su.Center.^2,2)));
    Su.Center = Su.Center-...
        repmat(min(Su.Center),size(Su.Center,1),1);
    Su = Su.FindVertices;
    figure(3)
    clf
    display(Su)
    line(Su.AllVertices(:,1),Su.AllVertices(:,2),...
        'Marker','o','LineStyle','none')
    
    [VertI,SpinJ] = meshgrid(1:size(Su.AllVertices,1),1:size(Su.Center,1));
    
    Distances = NaN(size(VertI));
    Distances(:) = ...
        sqrt( sum( (Su.AllVertices(VertI,:)-Su.Center(SpinJ,:)).^2,2));
    
    Distances(Distances<(0.5.*(1.05))) = 0;
    Distances(Distances>=(0.5.*(1.05))) = 1;
    Distances = 1-Distances;
  
    VertexCoordination = sum(Distances);
    
    EndPoints = Su.Center+Su.Direction/2;
    Distances = NaN(size(VertI));
    Distances(:) = ...
        sqrt( sum( (Su.AllVertices(VertI,:)-EndPoints(SpinJ,:)).^2,2));
    
    Distances(Distances<(0.5)) = 0;
    Distances(Distances>=(0.5)) = 1;
    Distances = 1-Distances;
    VertexCharge = sum(Distances);

    NoBoundaries = ...
        Su.AllVertices(:,1)>0 & Su.AllVertices(:,1)<11& ...
        Su.AllVertices(:,2)>0 & Su.AllVertices(:,2)<8;
        
    VertexCoordination(~NoBoundaries) = NaN;
    VertexCharge(~NoBoundaries) = NaN;
    
    hold on
    scatter(Su.AllVertices(:,1),Su.AllVertices(:,2),...
        10,VertexCoordination,'filled')
    hold off
    
    figure(4)
    display(Su)
    
    hold on
    scatter(Su.AllVertices(:,1),Su.AllVertices(:,2),...
        50,VertexCharge,'filled')
    hold off
    
    %% Count Vertices with coordination 3 and 4. 
    
    Coord = hist(VertexCoordination,[2,3,4]);
    Stats(i).Coord4 = Coord(3);
    Stats(i).Coord3 = Coord(2);

    Stats(i).Charge3 = hist(VertexCharge(VertexCoordination==3),[0,1,2,3]);
    Stats(i).Charge4 = ...
        hist(VertexCharge(VertexCoordination==4),[0,1,2,3,4]);
    
    NominalDecimationFraction-Coord(2)
end

%% Plot Results

Ratio = cat(1,Stats.Coord3)./cat(1,Stats.Coord4);

ChargeFreqZ4 = cat(1,Stats.Charge4)./repmat(cat(1,Stats.Coord4),1,5);
ChargeFreqZ3 = cat(1,Stats.Charge3)./repmat(cat(1,Stats.Coord3),1,4);

figure(4)
subplot(1,2,1)
plot(Ratio,ChargeFreqZ3,'+')
xlabel('\eta')
ylabel('P(q)')
title('Charge Frequency in vertices of Z = 3')
legend({'q=0','q=1','q=2','q=3'})

subplot(1,2,2)
plot(Ratio,ChargeFreqZ4,'+')
xlabel('\eta')
ylabel('P(q)')
title('Charge Frequency in vertices of Z = 4')
legend({'q=0','q=1','q=2','q=3','q=4'})

save('Stats.mat','Stats')