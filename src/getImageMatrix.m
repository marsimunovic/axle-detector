function [Xorig, Xbin] = getImageMatrix(image_path)
### gets matrix representation of an image
### Xorig - raw image read from file
### Xbin - binary image (0 - black, 1 - white)

Xorig = imread(image_path);
Xbin = Xorig;
Xbin(Xbin>0) = 1;

end