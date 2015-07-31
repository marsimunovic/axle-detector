function [Xcrop] = cropImage(image_matrix_binary)
%% crops image in following way:
%% first column with black pixel becomes first column of an image
%% last column with black pixel becomes last column of an image
%% only LOWER_PART (global variable) lower pixel rows of an image are preserved

%% image_matrix_binary - matrix represantation of an image
%% Xcrop - cropped image (remove before and after vehicle and pixels over LOWER_PART)

	global LOWER_PART; %% determines how many lower pixels of an image are preserved
	MIN_PIX_REPETITION = 30; %%improves vehicle detection filtering sporadic pixels

	%% first split image
	[height, width] = size(image_matrix_binary);
	if(height > LOWER_PART)
		Xcrop = image_matrix_binary(height-LOWER_PART+1: height, :);
	end

	%% Find front and back side of the vehicle
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
	countFront = 0;
	for n = width:-1:firstCol
		blacks = sum(Xcrop(:, n) == 0);
		if (blacks)
			countFront = countFront + 1;
		else
			countFront = 0;
		end
		if countFront > MIN_PIX_REPETITION
			lastCol = n + MIN_PIX_REPETITION-1;
			break;
		end
	end
	%% crop image (leave only detected vehicle)
	Xcrop = Xcrop(:, firstCol:lastCol);

end