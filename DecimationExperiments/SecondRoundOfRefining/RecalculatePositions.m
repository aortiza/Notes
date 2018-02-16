function [Positions,S] = RecalculatePositions(I,ParamSave)

%% Rotate the image
I = imrotate(I,ParamSave.Rotate*180/pi);

%% Extract the structural element 

SmpUpLeft = round(ParamSave.SmpCenter-ParamSave.SmpWidth/2);
SmpLwRght = round(ParamSave.SmpCenter+ParamSave.SmpWidth/2);
Smp = I(SmpUpLeft(2):SmpLwRght(2),SmpUpLeft(1):SmpLwRght(1));

%% Calculate the correlation function

%%% We shift the image before so that its mean is zero.
Ish = double(I)-mean(I(:));
If = imfilter(double(Ish),double(Smp)-mean(Smp(:)));

%%% Then we normalize it and improve contrast
If = imadjust(If./max(If(:)));

%% Perform Tracking
Positions = pkfnd(padarray(If,[50,50],0),ParamSave.Thresh,21)-50;

%% Make Corrections
if ~isempty(ParamSave.AddArray)
Positions = [Positions;ParamSave.AddArray];
end
if ~isempty(ParamSave.RemoveArray)
Positions(ismember(Positions,ParamSave.RemoveArray,'rows'),:)=[];
end

%% Calculate Spins

Width = ParamSave.UpRght(1)-ParamSave.UpLeft(1);
Height = Width/10*7;
Center = ParamSave.UpLeft+[Width,Height]/2;

S = Spins();
S = CreateSquareSpinIce(S,[10,7],'BoundaryType','Vertex');
S = ScaleSpinSystem(S,Width/10);
S = TranslateSpinSystem(S,Center);
S = ColloidsToSpins(Positions,S,'Decimated',true);

