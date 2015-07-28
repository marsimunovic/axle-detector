function [output, binary_out] = rect_area_max(input_matrix, window_dim = [21 21])
#calculates sum of intensities in window with dimensions window_dim
#sets central pixel of window to sum
output = zeros(size(input_matrix));


ywin = (window_dim(1) + 1) / 2;
xwin = (window_dim(2) + 1) / 2;

for n = xwin : size(input_matrix, 2) - xwin + 1
	for m = ywin : size(input_matrix, 1) - ywin + 1
		y1 = m - ywin + 1;
		y2 = m + ywin - 1;
		x1 = n - xwin + 1;
		x2 = n + xwin - 1;
		output(m, n) = sum(sum(input_matrix(y1 : y2, x1 : x2)));
	end
end
M = unique(output)(end-300);
binary_out = output;
binary_out(output <= M) = 1;
binary_out(output > M) = 0;

end