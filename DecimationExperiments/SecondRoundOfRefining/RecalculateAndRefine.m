function [PosCorr,S] = RecalculateAndRefine(I,ParamSave)

Pad = 100;
Ipad = padarray(I,Pad*[1,1],0,'both');

[Positions,S] = RecalculatePositions(I,ParamSave);

PositionsCtrd = cntrd(double(Ipad),Positions+Pad,15);
PositionsCtrd = PositionsCtrd-Pad;
PositionsCtrd = PositionsCtrd(:,1:2);

[M, N]=size(I); Center = [round(N/2), round(M/2)];
PosCorr = LensDistortPoints(PositionsCtrd,ParamSave.k,Center);