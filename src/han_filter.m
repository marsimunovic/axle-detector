function [output] = han_filter(input, window_len = 40, to_file = 'MySavedPlot') 
#performs low pass filtering in time domain with
#Han window of length window_len
#disp('han_filter')


window_len = numel(input)/25;
N = window_len;
n = 0:N-1;
b = 0.5*(1 - cos(2*pi*n/(N-1)));
a = sum(b);
b = b/a;
a = 1;
output = filter(b,a, input);
#output = int8(output);
#plot(y)
[pks, locs] = findpeaks(output);
[locsSortex, SortedIndex] = sort(locs);
pksSorted = pks(SortedIndex);
dist = diff(locsSortex);
reverse = (max(output(:)) + 1) - output;
[pksr, locsr] = findpeaks(reverse);
locsrSorted = sort(locsr);
pksr = output(locsrSorted);
#figure
#plot(1:numel(output), output)
#hold on
#plot(locsSortex, pksSorted, 'ro')
#hold on
#plot(locsrSorted, pksr, 'rx')

minima_locations = int16([]);

last_min = locsrSorted(end);
amp_min = output(last_min);
last_max = last_min;
if (last_min > locsSortex(end))
	#minima is last, find maxima
	disp('adding minima')
	for n = last_min + 1: numel(input)
		if output(n) >=	amp_min
			amp_min = output(n);
			last_max = n;
		end
	end
	locsSortex = [locsSortex last_max];
	pks = [pks output(last_max)];
	disp('minima added')
end


for n = 2:length(locsSortex)
	indl = locsSortex(n-1);
	indr = locsSortex(n);
	distx = indr - indl; # distance in pixels between two maxima
	if distx < 15
		continue;
	end
	min_loc = locsrSorted(find((locsrSorted > indl) & (locsrSorted < indr)));
	if(numel(min_loc) < 1)
		continue
	end
	ind_min = min_loc(1);
	distyl = output(indl) - output(ind_min);
	distyr = output(indr) - output(ind_min);



	if (distyl < 4) || (distyr < 4)
		continue
	end
	ratioo = max([distyr distyl])/min([distyl distyr]);
	if (ratioo > 5)
		continue
	end
	

	minima_locations = [minima_locations int16(ind_min)];
	

	#ratioo
	#distx
	#distyl
	#distyr
end



fig = figure;
set(fig, "visible", "off")

#plot(output)
#hold on
#plot(minima_locations, output(minima_locations), 'ro');

offset = int16(floor(window_len/2));
for n = 1 : numel(minima_locations)
	minima_locations(n) = minima_locations(n) - offset;
end
plot(input)
hold on
plot(minima_locations, input(minima_locations), 'ro');
print(fig, to_file,'-dgif')

output = int8(output);
end