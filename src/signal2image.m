function [image_matrix] = signal2image(signal)
# converts 1D signal to binary image 
# signal amplitudes are converted to y coordinates
# with amplitude 0 (black) and background is 1

IMAGE_HEIGHT = 70;


height = max(signal(:));
if  height < IMAGE_HEIGHT
	height = IMAGE_HEIGHT;
end

width = size(signal, 2);

image_matrix = ones(height, width);
for n = 1 : width
	image_matrix(height - signal(n), n) = 0;
end

end