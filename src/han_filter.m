function [output] = han_filter(input, window_len = 40, to_file = 'MySavedPlot') 
#performs low pass filtering in time domain with
#Han window of length window_len
#disp('han_filter')


if (numel(input) < 500)
	window_len = numel(input)*0.15;
end
N = window_len;
n = 0:N-1;
b = 0.5*(1 - cos(2*pi*n/(N-1)));
a = sum(b);
b = b/a;
a = 1;
output = filter(b,a, input);
#output = int8(output);
#output
#figure
#plot(output)
#pause(3)
[pks, locs] = findpeaks(output);
[locsSortex, SortedIndex] = sort(locs);
pksSorted = pks(SortedIndex);
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
maxima_locations = int16([]);

last_min = locsrSorted(end);
amp_min = output(last_min);
last_max = last_min;
if (last_min > locsSortex(end))
	#minima is last, find maxima
	#disp('adding minima')
	for n = last_min + 1: numel(input)
		if output(n) >=	amp_min
			amp_min = output(n);
			last_max = n;
		end
	end
	locsSortex = [locsSortex last_max];
	pks = [pks output(last_max)];
	#disp('minima added')
end


for n = 2:length(locsSortex)
	indl = locsSortex(n-1);
	indr = locsSortex(n);
	distx = indr - indl; # distance in pixels between two maxima
	if distx < 60
		#[distx, indl, indr]
		#disp('to narrow')
		continue;
	end
	min_loc = locsrSorted(find((locsrSorted > indl) & (locsrSorted < indr)));
	if(numel(min_loc) < 1)
		#[indl, indr]
		#disp('no minima')
		#locsrSorted
		continue
	end
	ind_min = min_loc(1);
	if(numel(min_loc) > 1)
		#disp('recalculating min')
		start = min_loc(1);
		stop = min_loc(end);
		if(abs(output(start) - output(stop)) < 3)
			avg = int16(sum(output(start:stop)) / (stop + 1 - start));
			if (abs(avg - output(start) < 3 && abs(avg - output(stop) < 3)))
				ind_min = int16((start+stop)/2);
			end
		end
	end
	
	if(output(ind_min) > 12)
		#disp('to high')
		continue
	end

	distyl = output(indl) - output(ind_min);
	distyr = output(indr) - output(ind_min);



	if (distyl < 5) || (distyr < 5)
		#disp('to short')
		continue
	end
	ratioo = max([distyr distyl])/min([distyl distyr]);
	if (ratioo > 5)
		#disp('to different')
		continue
	end


	

	minima_locations = [minima_locations int16(ind_min)];
	maxima_locations = [maxima_locations int16(indl) int16(indr)];

	#ratioo
	#distx
	#distyl
	#distyr
end




#plot(output)
#hold on
#plot(minima_locations, output(minima_locations), 'ro');
#hold on
#plot(maxima_locations, output(maxima_locations), 'go');

offset = int16(floor(window_len/2));
for n = 1 : numel(minima_locations)
	minima_locations(n) = minima_locations(n) - offset;
end
for n = 1 : numel(maxima_locations)
	maxima_locations(n) = maxima_locations(n) - offset;
end

new_maxima_locations = [];
fig = figure;
set(fig, "visible", "off")
#disp('Plotting section')
plot(input)

for n = 1 : numel(minima_locations)
	indx = find(maxima_locations < minima_locations(n));
	last_smaller = indx(end);
	#[maxima_locations(last_smaller) minima_locations(n) maxima_locations(last_smaller + 1)]
	peakl = input(maxima_locations(last_smaller));
	peakr = input(maxima_locations(last_smaller + 1));
	if peakl < peakr
	#search right
		pos = minima_locations(n);
		while input(pos) < peakl
			pos = pos + 1;
		end
		new_maxima_locations = [new_maxima_locations maxima_locations(last_smaller) pos];
	elseif peakr < peakl
	#search left
		pos = minima_locations(n);
		while input(pos) < peakr
			pos = pos - 1;
		end
		new_maxima_locations = [new_maxima_locations pos maxima_locations(last_smaller+1)];
	else
		new_maxima_locations = [new_maxima_locations maxima_locations(last_smaller) maxima_locations(last_smaller+1)];
	end
	centery = min([input(new_maxima_locations(end)) input(new_maxima_locations(end-1))]);
	centerx = minima_locations(n);
	r = centery - input(centerx);
	rb = r;
	ra = min([(new_maxima_locations(end) - centerx) (centerx - new_maxima_locations(end-1))]);
	S = 'g';
	if (input(centerx) > 0)
		#printf("Input %d\n", centerx);
		ellipse_area = ra*rb*pi/2;
		start = centerx - ra;
		stop = centerx + ra;
		area_under = sum(input(start:stop));
		
		area_over = 2*ra*centery - area_under;
		#double([ellipse_area area_over (ellipse_area./area_over)])
		ratioo = double(double(ellipse_area)/double(area_over))
		if (area_over > 0) && (ellipse_area > 200) && (ratioo <= 1.5) && (ratioo >= 0.6)
			#disp('Drawing elipse')
			#[ra, rb, centerx, centery]
			hold on
			drawEllipse(centerx, centery, ra, rb, S)
		end

	end

	#DrawCircle(centerx, centery, r, int16(r)*4, S);

end



hold on
plot(minima_locations, input(minima_locations), 'ro');
hold on
plot(new_maxima_locations, input(new_maxima_locations), 'go');
printf("Saving %s\n", to_file );
hold on
print -depsc test.eps
print(fig, to_file,'-dgif')

output = int8(output);
end