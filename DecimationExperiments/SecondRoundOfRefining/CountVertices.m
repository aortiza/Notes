
NominalDecimationFraction = str2double(F(i).name(12:13));
%%

%S = FindVertices(S);

S = RemoveDuplicates(S,0.1);

%% Get Vertex Charge

[Su] = ScaleSpinSystem(S,1./ParamSave.Scale);
%[~,OrI] = min(sqrt(sum(Su.Center.^2,2)));
Su.Center = Su.Center-...
    repmat(min(Su.Center),size(Su.Center,1),1);
Su = Su.FindVertices;

[VertI,SpinJ] = meshgrid(1:size(Su.AllVertices,1),1:size(Su.Center,1));

Distances = NaN(size(VertI));
Distances(:) = ...
    sqrt( sum( (Su.AllVertices(VertI,:)-Su.Center(SpinJ,:)).^2,2));

Distances(Distances<(0.5.*(1.1))) = 0;
Distances(Distances>=(0.5.*(1.1))) = 1;
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

%% Count Vertices with coordination 3 and 4.

Coord = hist(VertexCoordination,[2,3,4]);
Stats.Coord4 = Coord(3);
Stats.Coord3 = Coord(2);

Stats.Charge3 = hist(VertexCharge(VertexCoordination==3),[0,1,2,3]);
Stats.Charge4 = ...
    hist(VertexCharge(VertexCoordination==4),[0,1,2,3,4]);

display(Stats.Coord3-NominalDecimationFraction)
