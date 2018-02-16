%% This script meassures the charge screening in the Decimated Spin System
%
% The charge screening is meassured by adding the total charge that
% surrounds a every vertex of 4-coordination with charge -2
%
% We will ignore vetices with charge +4 as thres should not be a lot of
% them.

clear

Directory = 'Dataset/';

F = dir(Directory);
F(arrayfun(@(X)isempty(strfind(X.name,'.bmp')),F))=[];

ScreeningCharge = NaN(size(F));
DeficitCharge = NaN(size(F));
Decimation = NaN(size(F));
Display = false;

%% First we load a spin system and it's parameters 

for i = 1:length(ScreeningCharge)
    
    load([Directory,F(i).name(1:end-4),'_Spins.mat'])
    
    load([Directory,F(i).name(1:end-4),'.mat'])
    
    S = RemoveDuplicates(S,0.1);
    
    S = VertexChargeAndCoordination(S,ParamSave.Scale);
    
    %% Find Z4 Vertices
    Z4Vertices = find(S.VertexCoordination==4);
    
    %% Find Vertex Neighbors
    
    Neighbors = VertexNeighbors(S,ParamSave.Scale);
    
    %S.VertexCharge(S.VertexCoordination==1) = 0;
    ScreeningCharge(i) = 0;
    DeficitCharge(i) = 0;
    for j = 1:length(Z4Vertices)
        
        if S.VertexCharge(Z4Vertices(j))==-2
            ScreeningCharge(i) = ScreeningCharge(i) + ...
                sum(S.VertexCharge(Neighbors{Z4Vertices(j)}));
        end
        if S.VertexCharge(Z4Vertices(j))==0
            DeficitCharge(i) = DeficitCharge(i) + ...
                sum(S.VertexCharge(Neighbors{Z4Vertices(j)}));
        end
    end

%     ScreeningCharge(i) = ScreeningCharge(i)/numel(Z4Vertices);
%     DeficitCharge(i) = DeficitCharge(i)/numel(Z4Vertices);

    ScreeningCharge(i) = ScreeningCharge(i)/...
        sum(S.VertexCharge(Z4Vertices)==-2);
    DeficitCharge(i) = DeficitCharge(i)/...
        sum(S.VertexCharge(Z4Vertices)==-0);
    
    NomEta = str2double(F(i).name(12:13)); 
    Decimation(i) = NomEta./(88-NomEta);

    %%
    if Display

    clf
    S
    hold on
    scatter(S.AllVertices(:,1),S.AllVertices(:,2),...
        50,S.VertexCharge,'filled')
    hold off
    drawnow
    end

end

[DecimationCluster,~,B] = unique(Decimation);

for i = 1:length(DecimationCluster)
        
    ScreeningChargeMean(i,:) = mean(ScreeningCharge(B==i,:));
    ScreeningChargeStd(i,:) = std(ScreeningCharge(B==i,:));
    ScreeningChargeNum(i,:) = sum(B==i);
    
    DeficitChargeMean(i,:) = mean(DeficitCharge(B==i,:));
    DeficitChargeStd(i,:) = std(DeficitCharge(B==i,:));
    DeficitChargeNum(i,:) = sum(B==i);

end

ScreeningChargeErr =  tinv(0.95,ScreeningChargeNum).*...
    ScreeningChargeStd./sqrt(ScreeningChargeNum);
DeficitChargeErr =  tinv(0.95,DeficitChargeNum).*...
    DeficitChargeStd./sqrt(DeficitChargeNum);
%%

Eb1 = errorbar(...
    repmat(DecimationCluster,1,2),...
    [ScreeningChargeMean,DeficitChargeMean],...
    [ScreeningChargeErr,DeficitChargeErr],...
    'LineWidth',1.5);
xlim([0,8])
xlabel('\eta')
ylabel('Screening Charge per Vertex')
legend({'Charge in neighbors of Q=-2','Charge in neighbors of Q=0'})

ScreeningDS = dataset({DecimationCluster,'Eta'},...
    {ScreeningChargeMean,'Q2NeihChrg'},...
    {ScreeningChargeErr,'Q2NeihChrgErr'},...
    {DeficitChargeMean,'Q0NeihChrg'},...
    {DeficitChargeErr,'Q0NeihChrgErr'});

export(ScreeningDS,'file','Decimation_Screening.dat','delimiter','\t')
