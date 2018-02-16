%% Average and Plot Vertices
close all
clc
clear

%% 
Directory = 'Dataset/';

F = dir(Directory);
F(arrayfun(@(X)isempty(strfind(X.name,'.bmp')),F))=[];

load('Stats.mat')

for i = 1:length(F)
    
    Stats(i).NomEta = str2double(F(i).name(12:13)); %#ok<SAGROW>
    
end

%% 

NomEta = cat(2,Stats.NomEta);

[NomEta,A,B] = unique(NomEta);

NomEta = NomEta./(88-NomEta);

QFrac4Mean = NaN(size(NomEta,1),5);
QFrac4Std = NaN(size(NomEta,1),5);
QFrac4Num = NaN(size(NomEta,1),5);
QFrac4 = cat(1,Stats.Charge4)./repmat(cat(1,Stats.Coord4),[1,5]);

QFrac3Mean = NaN(size(NomEta,1),4);
QFrac3Std = NaN(size(NomEta,1),4);
QFrac3Num = NaN(size(NomEta,1),4);
QFrac3 = cat(1,Stats.Charge3)./repmat(cat(1,Stats.Coord3),[1,4]);

Q4Mean = NaN(size(NomEta,1),1);
Q4Std = NaN(size(NomEta,1),1);
Q4Num = NaN(size(NomEta,1),1);
Q4 = sum(QFrac4.*repmat([-4,-2,0,2,4],size(Stats,1),1),2);

for i = 1:length(NomEta)
        
    QFrac4Mean(i,:) = mean(QFrac4(B==i,:));
    QFrac4Std(i,:) = std(QFrac4(B==i,:));
    QFrac4Num(i,:) = sum(B==i);
    
    QFrac3Mean(i,:) = mean(QFrac3(B==i,:));
    QFrac3Std(i,:) = std(QFrac3(B==i,:));
    QFrac3Num(i,:) = sum(B==i);
    
    Q4Mean(i) = mean(Q4(B==i,:));
    Q4Std(i) = std(Q4(B==i,:));
    Q4Num(i) = sum(B==i);
    
end

%% 


Q4Err = tinv(0.95,Q4Num).*Q4Std./sqrt(Q4Num);
QFrac3Err =  tinv(0.95,QFrac3Num).*QFrac3Std./sqrt(QFrac3Num);
QFrac4Err =  tinv(0.95,QFrac4Num).*QFrac4Std./sqrt(QFrac4Num);

figure(1)

subplot(3,1,1)

Eb0 = errorbar(NomEta',Q4Mean,Q4Err,...
    'LineWidth',1.5);
legend({'Q_{z=4}'})
title('Average Charge per Vertex for Z=4')
xlim([0,8])

xlabel('\eta')
ylabel('Charge')

subplot(3,1,2)
Eb1 = errorbar(...
    repmat(NomEta',1,4),QFrac3Mean,QFrac3Err,...
    'LineWidth',1.5);
set(Eb1(1),'Color',[1 0 0]);
set(Eb1(2),'Color',[1 .85 0.0]*0.9);
set(Eb1(3),'Color',[0 0 1]);
set(Eb1(4),'Color',[0 0.5 0]);

legend({'N_q=-3','N_q=-1','N_q=1','N_q=3'})
xlim([0,max(NomEta)])
ylim([0,1])
xlim([0,8])

title('Vertex Fraction of Z = 3 Vertices')

xlabel('\eta')
ylabel('Fraction')

subplot(3,1,3)
Eb2=errorbar(repmat(NomEta',1,5),QFrac4Mean,QFrac4Err,...
    'LineWidth',1.5);
legend({'N_q=-4','N_q=-2','N_q=0','N_q=2','N_q=4'})
xlim([0,max(NomEta)])
ylim([0,1])
set(Eb2(1),'Color',[1 0 0]);
set(Eb2(2),'Color',[0 0.5 0]);
set(Eb2(3),'Color',[0 0 1]);
set(Eb2(4),'Color',[1 .85 0.0]*0.9);
set(Eb2(5),'Color',[0.7 0 1]);
title('Vertex Fraction of Z = 4 Vertices')
xlim([0,8])

xlabel('\eta')
ylabel('Fraction')

%% Export Data

Dat = dataset({NomEta','Eta'},...
    {Q4Mean','Q4Mean'},{Q4Err','Q4Err'},...
    {QFrac3Mean,'Z3Pqm3','Z3Pqm1','Z3Pqp1','Z3Pqp3'},...
    {QFrac3Err,'Z3Pqm3Err','Z3Pqm1Err','Z3Pqp1Err','Z3Pqp3Err'},...
    {QFrac4Mean,'Z4Pqm4','Z4Pqm2','Z4Pq0','Z4Pqp2','Z4Pqp4'},...
    {QFrac4Err,'Z4Pqm4Err','Z4Pqm2Err','Z4Pq0Err','Z4Pqp2Err','Z4Pqp4Err'});

Q4Dat = dataset({NomEta','Eta'},...
    {Q4Mean','Z4MeanQ'},{Q4Err','Z4MeanQErr'});

Z3Dat = dataset({NomEta','Eta'},...
    {QFrac3Mean,'Z3Pqm3','Z3Pqm1','Z3Pqp1','Z3Pqp3'},...
    {QFrac3Err,'Z3Pqm3Err','Z3Pqm1Err','Z3Pqp1Err','Z3Pqp3Err'});

Z4Dat = dataset({NomEta','Eta'},...
    {QFrac4Mean,'Z4Pqm4','Z4Pqm2','Z4Pq0','Z4Pqp2','Z4Pqp4'},...
    {QFrac4Err,'Z4Pqm4Err','Z4Pqm2Err','Z4Pq0Err','Z4Pqp2Err','Z4Pqp4Err'});

export(Q4Dat,'file','Decimation_Z4MeanQ.dat','delimiter','\t')
export(Z3Dat,'file','Decimation_Z3VertexFrac.dat','delimiter','\t')
export(Z4Dat,'file','Decimation_Z4VertexFrac.dat','delimiter','\t')
