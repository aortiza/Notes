%% Second round of Refining.
%
% There seems to be some cases in which the conversion from colloids to
% spins is not completely accurate. This is due to two things:
% - The found colloid position seems shifted to the left from the actual
% colloid position. 
% - The barrel distortion of the image causes the spin system to be
% smaller in the edges, which is not correctly interpreted.
%
% I will use the data that I have to go through the system with a minimum
% of manual configuration. Especially, since there should already be
% correspondence from spin_i to colloid_i, and it is only a matter of
% refining the representation of single spins to single colloids. 

clc
clear
clf
%% To test the script, I will use i=10
% This should later be changed to a loop,
% or maybe to a GUI with a slider

i = 1;

%% Load Data
Directory = 'Dataset/';
F = dir(Directory); F(arrayfun(@(X)isempty(strfind(X.name,'.bmp')),F))=[];
Name = [Directory,F(i).name(1:end-4)];

I = imread([Name,'.bmp']);
load([Name,'.mat']);
load([Name,'_Spins.mat']);

%% Display image

figure(1)
imax = gca;
%Id = lensdistort(I,-0.05);
imagesc(I,'Parent',imax), axis(imax,'equal','off')
colormap gray

%% Recalculate and Refine Positions 

Pad = 100;
Ipad = padarray(I,Pad*[1,1],0,'both');

[Positions,S] = RecalculatePositions(I,ParamSave);
line(Positions(:,1),Positions(:,2),'Marker','+','LineStyle','none')

PositionsCtrd = cntrd(double(Ipad),Positions+Pad,15);
PositionsCtrd = PositionsCtrd-Pad;
PositionsCtrd = PositionsCtrd(:,1:2);

line(PositionsCtrd(:,1),PositionsCtrd(:,2),...
    'color','r','Marker','+','LineStyle','none')

%% Correct Barrel Distortion of both Image and Found Positions

k = -0.04;

Id = lensdistort(I,k);
Id = imrotate(Id,ParamSave.Rotate*180/pi,'bilinear');
imagesc(Id,'Parent',imax), axis(imax,'equal','off')

[M, N]=size(I); Center = [round(N/2), round(M/2)];
PosCorr = LensDistortPoints(PositionsCtrd,k,Center);

line(PositionsCtrd(:,1),PositionsCtrd(:,2),...
    'color','r','Marker','+','LineStyle','none')

line(PosCorr(:,1),PosCorr(:,2),...
    'color','b','Marker','+','LineStyle','none')

S = ColloidsToSpins(PosCorr,S);

%% Create a new Spin Ice 
% First find the mean y position of the colloids that correspond to the
% spins in the top horizontal row.

% Horizontal spins
Hor = S.Direction(:,2)==0;

% Top Row
TopRow = (abs(S.Center(:,2)-max(S.Center(Hor,2)))<1);
TopRowMean = mean(PosCorr(TopRow,2));

% Bottom Row
BottomRow = (abs(S.Center(:,2)-min(S.Center(Hor,2)))<1);
BottomRowMean = mean(PosCorr(BottomRow,2));

% Vertical spins
Ver = S.Direction(:,1)==0;

% Right Col
RightCol = (abs(S.Center(:,1)-max(S.Center(Ver,1)))<1);
RightColMean = mean(PosCorr(RightCol,1));

% Left Col
LeftCol = (abs(S.Center(:,1)-min(S.Center(Ver,1)))<1);
LeftColMean = mean(PosCorr(LeftCol,1));

Scale = abs(TopRowMean-BottomRowMean)/7;

Center = [(LeftColMean+RightColMean)/2,(TopRowMean+BottomRowMean)/2];

%%
SNew = Spins();
SNew = CreateSquareSpinIce(SNew,[10,7],'BoundaryType','Vertex');
SNew = ScaleSpinSystem(SNew,Scale);
SNew = TranslateSpinSystem(SNew,Center);
SNew = ColloidsToSpins(PosCorr,SNew,'Decimated',true);

cla
%imagesc(Id,'Parent',imax), axis(imax,'equal','off')
S = SNew;
CountVertices
S = TranslateSpinSystem(Su,-[5.5,4]);
S = ScaleSpinSystem(S,Scale);
S = TranslateSpinSystem(S,Center);

line(PosCorr(:,1),PosCorr(:,2),...
    'color','r','Marker','+','LineStyle','none')
colormap jet
axis ij
hold on
scatter(S.AllVertices(:,1),S.AllVertices(:,2),...
    100,(VertexCoordination-3)*(255-3),'filled')
hold off

line([PosCorr(:,1),SNew.Center(:,1)]',[PosCorr(:,2),SNew.Center(:,2)]',...
    'color','c')