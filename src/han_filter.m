function [output] = han_filter(input, window_len = 20) 
#performs low pass filtering in time domain with
#Han window of length window_len

N = window_len;
n = 0:N-1;
b = 0.5*(1 - cos(2*pi*n/(N-1)));
a = sum(b);
b = b/a;
a = 1;
output = filter(b,a, input);
output = int8(output);
#plot(y)

end