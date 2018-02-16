%% Load Image and Params from previous analysis.

i = round(get(ImIndex,'value'));

Name = [Directory,F(i).name(1:end-4)];
I = imread([Name,'.bmp']);

load([Name,'.mat']);

if ~isfield(ParamSave,'AddArray')
    ParamSave.AddArray = [];
end
if ~isfield(ParamSave,'RemoveArray')
    ParamSave.RemoveArray = [];
end

if ~isfield(ParamSave,'AddArray2')
    ParamSave.AddArray2 = [];
end
if ~isfield(ParamSave,'RemoveArray2')
    ParamSave.RemoveArray2 = [];
end

if ~isfield(ParamSave,'Rotate')
    ParamSave.Rotate = 0;
end
if ~isfield(ParamSave,'Thresh') 
    ParamSave.Thresh = get(ImThresh,'Value');
end

if isnan(ParamSave.Thresh)
    ParamSave.Thresh = 0.8;
end

set(ImThresh,'Value',ParamSave.Thresh)
set(Angle,'Value',ParamSave.Rotate)

OriginalImage = I; %% RecalculatePositions require this 

%% Display Undistorted Image
% The weird colormap is so that the spin lines are clearly visible, and so
% that we can plot dots that represent the coordination.

k = -0.04;
ParamSave.k = k;
I = lensdistort(I,k);
I = imrotate(I,ParamSave.Rotate*180/pi);
imagesc(I/2+128,'Parent',imax), axis(imax,'equal','off')
caxis([0,255])
colormap([jet(2);gray(254)])


%% Recalculate and Refine Positions 

[Positions,SOldApprox] = RecalculateAndRefine(OriginalImage,ParamSave);

SOldApprox = ColloidsToSpins(Positions,SOldApprox);

if ~isfield(ParamSave,'Center')
    
    [S,Center,Scale] = CreateNewSpinIceForColloids(Positions,SOldApprox);
    ParamSave.Center = Center;
    ParamSave.Scale = Scale;
    save([Name,'.mat'],'ParamSave');

    
else
    
    S = Spins();
    S = CreateSquareSpinIce(S,[10,7],'BoundaryType','Vertex');
    S = ScaleSpinSystem(S,ParamSave.Scale);
    S = TranslateSpinSystem(S,ParamSave.Center);
    
end

if ~isempty(ParamSave.AddArray2)
Positions = [Positions;ParamSave.AddArray2];
end
if ~isempty(ParamSave.RemoveArray2)
Positions(ismember(Positions,ParamSave.RemoveArray2,'rows'),:)=[];
end

%% Make Spin System

% This ensures that the spins have the same ordering as the colloids

S = ColloidsToSpins(Positions,S,'Decimated',true);

CountVertices 
% This has to be done because for some reason, the unitary Su has different
% center as the original Spin system
S = TranslateSpinSystem(Su,-[5.5,4]);
S = ScaleSpinSystem(S,ParamSave.Scale);
S = TranslateSpinSystem(S,ParamSave.Center);

%% Display Colloid Positions, and Spins

display(S)
line(Positions(:,1),Positions(:,2),...
    'color','r','Marker','+','LineStyle','none')
axis ij
hold on
scatter(S.AllVertices(:,1),S.AllVertices(:,2),...
    100,(VertexCoordination-3),'filled')
hold off

save([Name,'_Spins.mat'],'S');
save([Name,'_Positions.dat'],'Positions','-ascii');

f=getframe(imax);
imwrite(f.cdata,[Name,'_Overlay.jpg'],'jpeg');

ParamSave
