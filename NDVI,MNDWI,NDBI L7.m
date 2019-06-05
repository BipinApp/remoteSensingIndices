clc
clear 
close all

% subsetting the image
mapx = [330047,339175,330047,339175];
mapy = [3074602, 3074602,3054285,3054285];


% reading the band 6 of landsat to convert into surface temperature reflectance
 Thermaldirectory = 'Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\temp_2007_01_10';
[imageThermal,RT] =  geotiffread(Thermaldirectory);
[rowT, colT] = map2pix(RT,mapx,mapy);
rowT = single(rowT);
colT = single(colT);
imageThermal = imageThermal(rowT(1):rowT(3),colT(1):colT(2));

% saving the thermal Image
[xlimits,ylimits] = intrinsicToWorld(RT,[colT(1),colT(2)],[rowT(1),rowT(3)]);
subR = RT;
subR.RasterSize  =size(imageThermal);
subR.XWorldLimits = sort(double(xlimits));
subR.YWorldLimits = sort(double(ylimits));
geoInfo = geotiffinfo(Thermaldirectory);
geoTags = geoInfo.GeoTIFFTags.GeoKeyDirectoryTag;
geotiffwrite('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\ThermalC_2007_01_10.tif',imageThermal,subR,'GeoKeyDirectoryTag',geoTags)
figure
imagesc(imageThermal)
colorbar

% working with other bands
[imageNIR,~] = geotiffread('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\LE07_L1TP_141041_20070110_20170105_01_T1_sr_band4.tif');
[imageRed,~] = geotiffread('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\LE07_L1TP_141041_20070110_20170105_01_T1_sr_band3.tif');
[imageGreen,~] = geotiffread('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\LE07_L1TP_141041_20070110_20170105_01_T1_sr_band2.tif');
[imageSwir,R] = geotiffread('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\LE07_L1TP_141041_20070110_20170105_01_T1_sr_band5.tif');
[imageBaq,~] = geotiffread('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\LE07_L1TP_141041_20070110_20170105_01_T1_sr_cloud_qa');
imageBaq(imageBaq > 0) = NaN;
imageBaq(imageBaq  == 0) = 1;

% converting the image to reflectance using the scale factor
scaleFactor = 0.0001;
imageNirReflectance = (double(imageNIR)*scaleFactor) .* double(imageBaq);
imageRedReflectance = (double(imageRed)*scaleFactor).* double(imageBaq);
imageGreenReflectance = (double(imageGreen)*scaleFactor).* double(imageBaq);
imageSwirReflectance = (double(imageSwir)*scaleFactor).* double(imageBaq);


[row, col] = map2pix(R,mapx,mapy);
row = single(row);
col = single(col);
imageNirReflectance = imageNirReflectance(row(1):row(3),col(1):col(2));
imageRedReflectance = imageRedReflectance(row(1):row(3),col(1):col(2));
imageGreenReflectance = imageGreenReflectance(row(1):row(3),col(1):col(2));
imageSwirReflectance = imageSwirReflectance(row(1):row(3),col(1):col(2));


% calculating the NDVI 
NDVI = (imageNirReflectance - imageRedReflectance)./(imageNirReflectance + imageRedReflectance);
% NDWI = (imageNirReflectance - imageSwirReflectance)./(imageNirReflectance + imageSwirReflectance);
% NDWI = (imageGreenReflectance - imageNirReflectance)./(imageGreenReflectance + imageNirReflectance);
MNDWI = (imageGreenReflectance - imageSwirReflectance)./(imageGreenReflectance + imageSwirReflectance);
% % bulit up area
NDBI = double(imageSwir-imageNIR)./double(imageSwir+imageNIR);
NDBI = NDBI(row(1):row(3),col(1):col(2));

% barness index
% NDbaI = (imageSwirReflectance-imageThermal) ./ (imageSwirReflectance+imageThermal);

% EBBI = (imageSwirReflectance-imageNirReflectance)./(10*sqrt(imageSwirReflectance+imageNirReflectance));

figure
imshow(NDBI)
% changing the Xlimits and Ylimits of image
[xlimits,ylimits] = intrinsicToWorld(R,[col(1),col(2)],[row(1),row(3)]);
subR = R;
subR.RasterSize  =size(imageNirReflectance);
subR.XWorldLimits = sort(double(xlimits));
subR.YWorldLimits = sort(double(ylimits));
geoInfo = geotiffinfo('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\LE07_L1TP_141041_20070110_20170105_01_T1_sr_band4.tif');
geoTags = geoInfo.GeoTIFFTags.GeoKeyDirectoryTag;
% 
% % writing NDVI file
geotiffwrite('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\NDVI_2007_01_10.tif',NDVI,subR,'GeoKeyDirectoryTag',geoTags)
% geotiffwrite('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\NDWI_2007_01_10.tif',NDWI,subR,'GeoKeyDirectoryTag',geoTags)
geotiffwrite('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\MNDWI_2007_01_10.tif',MNDWI,subR,'GeoKeyDirectoryTag',geoTags)
geotiffwrite('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\NDBI_2007_01_10.tif',NDBI,subR,'GeoKeyDirectoryTag',geoTags)
% geotiffwrite('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\NDBaI_2007_01_10.tif',NDbaI,subR,'GeoKeyDirectoryTag',geoTags)
% geotiffwrite('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\EBBI_2007_01_10.tif',EBBI,subR,'GeoKeyDirectoryTag',geoTags)

% creating Mask for the water
waterMask = MNDWI > 0;
% Counting the water Pixel
waterPixelCount = sum(waterMask(:)==1);
geotiffwrite('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\waterMask_2007_01_10.tif',waterMask,subR,'GeoKeyDirectoryTag',geoTags)


%Vegetation Identification
vegId1 = (imageNirReflectance - imageSwirReflectance);
vegId2 = (imageNirReflectance - imageRedReflectance);
vegContd1 = vegId1 > 0.1;
vegContd2 = vegId2 > 0;
vegtationPixel = and(logical(vegContd1),logical(vegContd2));
tempMask = vegtationPixel & waterMask;
% removing the water Pixel 
vegetationMask = vegtationPixel-tempMask; 
%counting the vegetation PIXEL 
vegetationPixelCount = sum(vegetationMask(:) == 1);

geotiffwrite('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\vegMask_2007_01_10.tif',vegetationMask,subR,'GeoKeyDirectoryTag',geoTags)

figure 
imshow(vegtationPixel)


% BuiltUp Mask
builtLandMask = NDBI;
builtLandMask(builtLandMask > 0 & builtLandMask <=0.075025) = 1;
builtLandPixelCount = sum(builtLandMask(:) == 1);

geotiffwrite('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\BulitAreaMask_2007_01_10.tif',builtLandMask,subR,'GeoKeyDirectoryTag',geoTags)

barenLandMask = NDBI;
barenLandMask(barenLandMask >0.075025 & barenLandMask < 0.277498) = 1;
barenLandPixelCount = sum(barenLandMask(:) == 1);
geotiffwrite('Z:\SpecialNeeds\BIPIN RAUT\Lan\New folder\LE071410412007011001T1-SC20181017175104.tar\LE071410412007011001T1-SC20181017175104\BarenLandMask_2007_01_10.tif',barenLandMask,subR,'GeoKeyDirectoryTag',geoTags)

save('2007infor.mat','barenLandPixelCount','builtLandPixelCount','vegetationPixelCount','waterPixelCount');




