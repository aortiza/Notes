%% Show Image with High Decimation

clear

Directory = 'Dataset/';
File = 'Decimation_74_1';
Name = [Directory,File];

I = imread([Name,'.bmp']);
load([Name,'.mat'])
It = imrotate(lensdistort(I,ParamSave.k),ParamSave.Rotate*180/pi);

imshow(It)
imwrite(It,[File,'_Figure1.bmp'],'bmp')