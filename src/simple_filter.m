fltr4accum = ones(5,5);
fltr4accum(2:4,2:4) = 2;
fltr4accum(3,3) = 4;
XcropInv = Xcrop;

XcropFilt = imfilter(XcropInv, fltr4accum);
Scaled = XcropFilt;
Scaled(XcropFilt > 0) = 1;
Reverse = 1-Scaled;
figure
subplot(2,1,1)
imshow(Xcrop)
subplot(2,1,2)
imshow(Scaled)

