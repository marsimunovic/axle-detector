function [axle_bottom, axle_sides] = find_axle_candidates(input_data, file_name = '')
	%%
	%%
	axle_bottom = [];
	axle_sides = [];
	[output, offset] = han_filter(input_data);

	MIN_TYRE_WIDTH = 60;       %min tyre width in pixels
	MAX_PIXEL_VARATION = 3;    %maximum pixel variation between two neighbor minima
	MAX_LIFTED_HEIGHT = 12;    %lowest point of lifted tyre in pixels
	MIN_TYRE_RADIUS = 5;       %min lifted tyre radius 	
	MAX_EDGE_HEIGHT_RATIO = 5; %ration between tyre left and right edge heights

	%find local extremes in bottom contour
	% LOCAL MAXIMA (indices and amplitudes)
	[pks, locs] = findpeaks(output);
	[locsSortex, SortedIndex] = sort(locs);
	pksSorted = pks(SortedIndex); 
	reverse = (max(output(:)) + 1) - output;
	% LOCAL MINIMA (indices and amplitudes)
	[pksr, locsr] = findpeaks(reverse); 
	locsrSorted = sort(locsr);
	pksr = output(locsrSorted);

	%if last minima after last maxima add new
	% maxima to the end of the vehicle contour
	last_min = locsrSorted(end);
	amp_min = output(last_min);
	last_max = last_min;
	if (last_min > locsSortex(end))
		#minima is last, find maxima
		for n = last_min + 1: numel(input_data)
			if output(n) >=	amp_min
				amp_min = output(n);
				last_max = n;
			end
		end
		locsSortex = [locsSortex last_max];
		pks = [pks output(last_max)];
	end

	minima_locations = int16([]);
	maxima_locations = int16([]);


	for n = 2:length(locsSortex)
		indl = locsSortex(n-1);
		indr = locsSortex(n);
		distx = indr - indl; # distance in pixels between two maxima
		if distx < MIN_TYRE_WIDTH
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
			if(abs(output(start) - output(stop)) < MAX_PIXEL_VARATION)
				avg = int16(sum(output(start:stop)) / (stop + 1 - start));
				if (abs(avg - output(start) < MAX_PIXEL_VARATION && abs(avg - output(stop) < MAX_PIXEL_VARATION)))
					ind_min = int16((start+stop)/2);
				end
			end
		end
		
		if(output(ind_min) > MAX_LIFTED_HEIGHT)
			#disp('to high')
			continue
		end

		distyl = output(indl) - output(ind_min);
		distyr = output(indr) - output(ind_min);



		if (distyl < MIN_TYRE_RADIUS) || (distyr < MIN_TYRE_RADIUS)
			#disp('to short')
			continue
		end
		ratioo = max([distyr distyl])/min([distyl distyr]);
		if (ratioo > MAX_EDGE_HEIGHT_RATIO)
			#disp('to different')
			continue
		end

		minima_locations = [minima_locations int16(ind_min)];
		maxima_locations = [maxima_locations int16(indl) int16(indr)];


	end

	for n = 1 : numel(minima_locations)
		minima_locations(n) = minima_locations(n) - offset;
	end
	for n = 1 : numel(maxima_locations)
		maxima_locations(n) = maxima_locations(n) - offset;
	end

	axle_bottom = minima_locations;
	axle_sides = maxima_locations;

end