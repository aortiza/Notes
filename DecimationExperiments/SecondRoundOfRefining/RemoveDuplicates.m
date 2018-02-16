function S = RemoveDuplicates(S,tol)

%load('/Users/aortiza/Dropbox/Colloids/2017-07-17/DecimationDataProcessing_GUIApproach/Dataset/Decimation_14_2_Spins.mat')

if ~exist('tol')
    tol = 0.1;
end

Su = S.UnitarySystem();

[SpinI,SpinJ] = meshgrid(1:size(S.Center,1),1:size(S.Center,1));

Distances = NaN(size(SpinI));
Distances(:) = ...
    sqrt( sum( (Su.Center(SpinI,:)-Su.Center(SpinJ,:)).^2,2));

Distances(Distances<=(0.*(1+tol))) = 0;
Distances(Distances>(0.*(1+tol))) = 1;
Distances = 1-Distances;

Remove = find(...
    sum((Distances-eye(size(Distances))).*cumsum(eye(size(Distances)))));

S.Center(Remove,:)=[];
S.Direction(Remove,:)=[];