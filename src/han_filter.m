function [output, offset] = han_filter(input_data) 
%%  performs low pass filtering in time domain with
%%  Han window of length window_len
%%	input_data - bottom vehicle contour
%%  output - filtered contour
%%  offset - shift introduced by filter
	N = numel(input_data);
	window_len = 40;
	if (N < 700)
		window_len = 30;
	end
	if (N < 500)
		window_len = 20;
	end
	if (N < 250)
		window_len = 10;
	end
	if(window_len < 3)
		window_len = 3;
	end
	offset = int16(floor(window_len/2))-1;
	N = window_len;
	n = 0:N-1;
	b = 0.5*(1 - cos(2*pi*n/(N-1)));
	a = sum(b);
	b = b/a;
	output = filter(b, 1, input_data);

end