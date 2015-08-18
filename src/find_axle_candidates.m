function [axle_bottom, axle_sides] = find_axle_candidates(input_data, file_name = '')
	%%
	%%
	global DEBUG_ACTIVE
	axle_bottom = [];
	axle_sides = [];
	if (numel(input_data) < 300)
		return;
	end
	[output, offset] = han_filter(input_data);

	MIN_TYRE_WIDTH = 50;       %min tyre width in pixels
	MAX_PIXEL_VARATION = 3;    %maximum pixel variation between two neighbor minima
	MAX_LIFTED_HEIGHT = 10;    %lowest point of lifted tyre in pixels
	MIN_TYRE_RADIUS = 5;       %min lifted tyre radius 	
	MAX_EDGE_HEIGHT_RATIO = 5; %ratio between tyre left and right edge heights

	[peaks, peaks_min, axle_candidates] = find_peaks_manual(output, offset);
	if(numel(peaks_min) == 0 || numel(peaks) == 0)
		return
	end

	for n = 1 : size(axle_candidates, 2)
		lt = axle_candidates(n).lt - offset;
		rt = axle_candidates(n).rt - offset;
		loc = axle_candidates(n).loc;
		while(lt < loc) && (input_data(lt) == input_data(lt+1))
			lt = lt+1;
			axle_candidates(n).lt = axle_candidates(n).lt + 1;
		end
		while(rt > loc) && (input_data(rt) == input_data(rt-1))
			rt = rt-1;
			axle_candidates(n).rt = axle_candidates(n).rt - 1;
		end
	end


#	figure
#	plot(input_data)
#	hold on
#	plot(peaks-offset, input_data(peaks-offset), 'go');
#	hold on
#	plot(peaks_min-offset, input_data(peaks_min-offset), 'rx');
#	figure
#	plot(output)
#	hold on
#	plot(peaks, output(peaks), 'go');
#	hold on
#	plot(peaks_min, output(peaks_min), 'rx');

	#%find local extremes in bottom contour
	#% LOCAL MAXIMA (indices and amplitudes)
	#[pks, locs] = findpeaks(output);
	#[locsSortex, SortedIndex] = sort(locs);
	#pksSorted = pks(SortedIndex); 
	#reverse = (max(output(:)) + 1) - output;
	#% LOCAL MINIMA (indices and amplitudes)
	#[pksr, locsr] = findpeaks(reverse); 
	#locsrSorted = sort(locsr);
	#pksr = output(locsrSorted);
#
#	#if(numel(locsSortex) == 0 || numel(locsrSorted) == 0)
#	#	return
#	#end
#
#	#%if last minima after last maxima add new
#	#% maxima to the end of the vehicle contour
#	#last_min = locsrSorted(end);
#	#amp_min = output(last_min);
#	#last_max = last_min;
#
#	#if (last_min > locsSortex(end))
#	#	#minima is last, find maxima
#	#	for n = last_min + 1: numel(input_data)
#	#		if output(n) >=	amp_min
#	#			amp_min = output(n);
#	#			last_max = n;
#	#		end
#	#	end
#	#	locsSortex = [locsSortex last_max];
#	#	pks = [pks output(last_max)];
	#end

	minima_locations = int16([]);
	maxima_locations = int16([]);

	#merge double minima



	#create candidate structures

#	locsSortex = peaks;
#	locsrSorted = peaks_min;

	for n = 1 : size(axle_candidates, 2)
		indl = axle_candidates(n).lt;
		indr = axle_candidates(n).rt;
		ind_min = axle_candidates(n).loc;
		if DEBUG_ACTIVE
			axle_candidates(n)
		end
		distx = indr - indl; # distance in pixels between two maxima
		if distx < MIN_TYRE_WIDTH
			#[distx, indl, indr]
			if DEBUG_ACTIVE
				disp('to narrow')
			end
			continue;
		end

		if(output(ind_min) > MAX_LIFTED_HEIGHT)
			if DEBUG_ACTIVE
				disp('to high')
			end
			continue
		end

		distyl = output(indl) - output(ind_min);
		distyr = output(indr) - output(ind_min);

		if (distyl < MIN_TYRE_RADIUS) || (distyr < MIN_TYRE_RADIUS)
			if DEBUG_ACTIVE
				disp('to short')
			end
			continue
		end
		upper_edge = max([distyr distyl]);
		lower_edge = min([distyl distyr]);
		ratioo = upper_edge/lower_edge;
		if (ratioo > MAX_EDGE_HEIGHT_RATIO)
			if DEBUG_ACTIVE
				disp('to different')
			end
			continue
		end
		minima_locations = [minima_locations int16(ind_min-offset)];
		maxima_locations = [maxima_locations int16(indl-offset) int16(indr-offset)];
	end

#{
	for n = 2:length(locsSortex)
		indl = locsSortex(n-1);
		indr = locsSortex(n);
		distx = indr - indl; # distance in pixels between two maxima
		if distx < MIN_TYRE_WIDTH
			#[distx, indl, indr]
			if DEBUG_ACTIVE
				disp('to narrow')
			end
			continue;
		end
		min_loc = locsrSorted(find((locsrSorted > indl) & (locsrSorted < indr)));
		if(numel(min_loc) < 1)
			#[indl, indr]
			if DEBUG_ACTIVE
				disp('no minima')
			end
			#locsrSorted
			continue
		end
		ind_min = min_loc(1);
		if(numel(min_loc) > 1)
			if DEBUG_ACTIVE
				disp('recalculating min')
			end
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
			if DEBUG_ACTIVE
				disp('to high')
			end
			continue
		end

		distyl = output(indl) - output(ind_min);
		distyr = output(indr) - output(ind_min);



		if (distyl < MIN_TYRE_RADIUS) || (distyr < MIN_TYRE_RADIUS)
			if DEBUG_ACTIVE
				disp('to short')
			end
			continue
		end
		ratioo = max([distyr distyl])/min([distyl distyr]);
		if (ratioo > MAX_EDGE_HEIGHT_RATIO)
			if DEBUG_ACTIVE
				disp('to different')
			end
			continue
		end

		minima_locations = [minima_locations int16(ind_min)];
		maxima_locations = [maxima_locations int16(indl) int16(indr)];


	end
#}

	axle_bottom = minima_locations;
	axle_sides = maxima_locations;

end