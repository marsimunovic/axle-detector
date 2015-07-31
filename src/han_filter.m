function [output, offset] = han_filter(input_data) 
%%  performs low pass filtering in time domain with
%%  Han window of length window_len
%%	input_data - bottom vehicle contour
%%  output - filtered contour
%%  offset - shift introduced by filter

	window_len = 40;
	if (numel(input_data) < 500)
		window_len = numel(input_data)*0.05;
	end
	if(window_len < 3)
		window_len = 3;
	end
	offset = int16(floor(window_len/2));
	N = window_len;
	n = 0:N-1;
	b = 0.5*(1 - cos(2*pi*n/(N-1)));
	a = sum(b);
	b = b/a;
	output = filter(b, 1, input_data);

end