function [S, Center, Scale] = CreateNewSpinIceForColloids(Positions,SOld)

%% Create a new Spin Ice 
% First find the mean y position of the colloids that correspond to the
% spins in the top horizontal row.

% Horizontal spins
Hor = SOld.Direction(:,2)==0;

% Top Row
TopRow = (abs(SOld.Center(:,2)-max(SOld.Center(Hor,2)))<1);
TopRowMean = mean(Positions(TopRow,2));

% Bottom Row
BottomRow = (abs(SOld.Center(:,2)-min(SOld.Center(Hor,2)))<1);
BottomRowMean = mean(Positions(BottomRow,2));

% Vertical spins
Ver = SOld.Direction(:,1)==0;

% Right Col
RightCol = (abs(SOld.Center(:,1)-max(SOld.Center(Ver,1)))<1);
RightColMean = mean(Positions(RightCol,1));

% Left Col
LeftCol = (abs(SOld.Center(:,1)-min(SOld.Center(Ver,1)))<1);
LeftColMean = mean(Positions(LeftCol,1));

Scale = abs(TopRowMean-BottomRowMean)/7;

Center = [(LeftColMean+RightColMean)/2,(TopRowMean+BottomRowMean)/2];

S = Spins();
S = CreateSquareSpinIce(S,[10,7],'BoundaryType','Vertex');
S = ScaleSpinSystem(S,Scale);
S = TranslateSpinSystem(S,Center);