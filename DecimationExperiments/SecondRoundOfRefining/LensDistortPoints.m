function Points = LensDistortPoints(Points,k,Center)

Norm = sqrt(Center(1)^2 + Center(2)^2);

Offset = Points-repmat(Center,size(Points,1),1);
R = sqrt(sum(Offset.^2,2))./Norm;

Points = Points - k*Offset.*[R,R].^2;