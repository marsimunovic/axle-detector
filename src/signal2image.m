function [image_matrix] = signal2image(signal, blur = 0)
# converts 1D signal to binary image 
# signal amplitudes are converted to y coordinates
# with amplitude 0 (black) and background is 1
# -blur adds blur up and left to contour
global LOWER_PART;

IMAGE_HEIGHT = LOWER_PART;


height = max(signal(:));
if  height < IMAGE_HEIGHT
	height = IMAGE_HEIGHT;
end

width = size(signal, 2);

image_matrix = ones(height, width);
for n = 2 : width - 1
	image_matrix(height - signal(n), n) = 0;
	if blur > 0
		#blur up
		image_matrix(height - signal(n) - 1, n ) = 0;
	end
	if blur > 1
		#blur right
		image_matrix(height - signal(n), n + 1) = 0;
	end
	if blur > 2
		#blur left
		image_matrix(height - signal(n), n - 1) = 0;
	end
end

end