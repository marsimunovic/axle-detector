function [Xcrop] = cropImage(image_matrix_binary)
# crops image in following way:
# first column with black pixel becomes first column of an image
# last column with black pixel becomes last column of an image
# only 70 lower pixel rows of an image are preserved

LOWER_PART = 70;
MIN_PIX_REPETITION = 30; 

#first split image in half



[height, width] = size(image_matrix_binary);
if(height > LOWER_PART)
	Xcrop = image_matrix_binary(height-LOWER_PART+1: height, :);
end

firstCol = 1;
countFront = 0;
for n = 1:width
	blacks = sum(Xcrop(:, n) == 0);
	if (blacks)
		countFront = countFront + 1;
	else
		countFront = 0;
	end
	if countFront > MIN_PIX_REPETITION
		firstCol = n - MIN_PIX_REPETITION;
		break;
	end
end
lastCol = firstCol;
for n = width:-1:firstCol
	blacks = sum(Xcrop(:, n) == 0);
	if (blacks)
		countFront = countFront + 1;
	else
		countFront = 0;
	end
	if countFront > MIN_PIX_REPETITION
		lastCol = n + MIN_PIX_REPETITION;
		break;
	end
end

Xcrop = Xcrop(:, firstCol:lastCol);

end