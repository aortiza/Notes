function Neighbors = VertexNeighbors(S,Scale)

Su = S.ScaleSpinSystem(1./Scale);

Su = Su.FindVertices;

[VertI,SpinJ] = meshgrid(1:size(Su.AllVertices,1),1:size(Su.Center,1));

Distances = NaN(size(VertI));
Distances(:) = ...
    sqrt( sum( (Su.AllVertices(VertI,:)-Su.Center(SpinJ,:)).^2,2));

Distances(Distances<(0.5.*(1.05))) = 0;
Distances(Distances>=(0.5.*(1.05))) = 1;
Distances = 1-Distances;

SpinsInVertex = cell(size(Su.AllVertices,1),1);
VertexInSpins = cell(size(Su.Center,1),1);

for i = 1:size(Su.AllVertices,1)
    
    SpinsInVertex{i} = find(Distances(:,i));
    
end

for j = 1:size(Su.Center,1)
    
    VertexInSpins{j} = find(Distances(j,:));
    
end
%% 
%
% For every vertex (i), I should go to it's spins in vertex directory. 
% Then, for every spin (j) belonging to the vertex, I should look for which 
% other vertex(k) contains this spin (j). 

Neighbors = cell(size(Su.AllVertices,1),1);

for i = 1:size(Su.AllVertices)

    Neighbors{i} = [VertexInSpins{SpinsInVertex{i}}];
    Neighbors{i}(Neighbors{i}==i) = [];
    Neighbors{i} = unique(Neighbors{i});
    
end
