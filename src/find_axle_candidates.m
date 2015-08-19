function [axle_bottom, axle_sides] = find_axle_candidates(input_data, file_name = '')
	%%
	%%
	global DEBUG_ACTIVE
	axle_bottom = [];
	axle_sides = [];
	axle_widths = [];
	if (numel(input_data) < 350)
		return;
	end
	[output, offset] = han_filter(input_data);

	MIN_TYRE_WIDTH = 40;       %min tyre width in pixels
	MAX_PIXEL_VARATION = 3;    %maximum pixel variation between two neighbor minima
	MAX_LIFTED_HEIGHT = 10;    %lowest point of lifted tyre in pixels
	MIN_TYRE_RADIUS = 5;       %min lifted tyre radius 	
	MAX_EDGE_HEIGHT_RATIO = 5; %ratio between tyre left and right edge heights
	WIDTH_PERCENTAGE = 0.5;    %min percentage of real axle width in candidates

	[peaks, peaks_min, axle_candidates] = find_peaks_manual(output, offset);
	if(numel(peaks_min) == 0 || numel(peaks) == 0)
		return
	end
	#size(axle_candidates,2)
	for n = 1 : size(axle_candidates, 2)

		if(output(axle_candidates(n).lt) < output(axle_candidates(n).rt))
			#disp('moving left')
			#axle_candidates(n).loc
			while (output(axle_candidates(n).lt) < output(axle_candidates(n).rt - 1))
				axle_candidates(n).rt = axle_candidates(n).rt - 1;
				#[output(axle_candidates(n).lt), output(axle_candidates(n).rt)]
			end
		elseif(output(axle_candidates(n).lt) > output(axle_candidates(n).rt))
			#disp('moving right')
			while (output(axle_candidates(n).lt + 1) > output(axle_candidates(n).rt))
				axle_candidates(n).lt = axle_candidates(n).lt + 1;
			end
		else
			#do nothing if equal
		end
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

#		limleft = lt + (loc-lt)*0.20;
#		same_cnt = 0;
#		shift = 0;
#		for n = limleft:-1:lt
#			if (input_data(n) == input_data(n-1))
#				same_cnt = same_cnt + 1;
#				if same_cnt >= 4
#					disp('found line')
#					shift = limleft + 3 + offset;
#					break;
#				end
#			else
#				same_cnt = 0;
#			end
#		end
#		axle_candidates(n).lt = shift;
#		limright = rt - (rt-loc)*0.20;
#		same_cnt = 0;
#		for n = limright:rt
#			if (input_data(n) == input_data(n+1))
#				same_cnt = same_cnt + 1;
#				if same_cnt >= 4
#					disp('found line')
#					shift = limright-3+offset;
#					break;
#				end
#			else
#				same_cnt = 0;
#			end
#		end
#		axle_candidates(n).rt = shift;

		

		if (output(loc) < 0.5)
			#disp('zero location')
			ax_w = min(axle_candidates(n).loc - axle_candidates(n).lt, ...
					   axle_candidates(n).rt - axle_candidates(n).loc);
			axle_widths = [axle_widths ax_w];
		else
			#output(loc);
		end
	end
	#axle_widths
	
	if DEBUG_ACTIVE > 3
		figure
		plot(output)
		hold on
		plot(peaks, output(peaks), 'go');
		hold on
		plot(peaks_min, output(peaks_min), 'rx');
	end

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
	[firstw, ind1] = max(axle_widths);
	axle_widths(ind1) = 0;
	secondw = max(axle_widths);

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
		#[distyr, distyl]
		upper_edge = max([distyr distyl]);
		lower_edge = min([distyl distyr]);
		ratioo = upper_edge/lower_edge;
		if (ratioo > MAX_EDGE_HEIGHT_RATIO)
			if DEBUG_ACTIVE
				disp('to different')
			end
			continue
		end
		if (numel(axle_widths) < 2)
			if DEBUG_ACTIVE
				disp('Error! Missing axles')
			end
		else
			half_radius = min(ind_min - indl, indr - ind_min);
			checker = 0;
			if (firstw/secondw) >= 2
				disp('Big difference between two low axles')
				#first check smaller
				greater = max(half_radius, secondw);
				smaller = min(half_radius, secondw);
				if smaller > greater*WIDTH_PERCENTAGE				
					checker = checker + 1;
				end
			end
			greater = max(half_radius, firstw);
			smaller = min(half_radius, firstw);
			if smaller > greater*WIDTH_PERCENTAGE
				checker = checker + 1;
			end
			if checker == 0
				if DEBUG_ACTIVE
					disp('to thin')
					[half_radius, firstw, secondw]
				end
				continue
			end
		
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
	if DEBUG_ACTIVE > 2
		figure
		plot(output)
		hold on
		plot(maxima_locations+offset, output(maxima_locations+offset), 'go');
		hold on
		plot(minima_locations+offset, output(minima_locations+offset), 'rx');
		figure
		plot(input_data)
		hold on
		plot(maxima_locations, input_data(maxima_locations), 'go');
		hold on
		plot(minima_locations, input_data(minima_locations), 'rx');
	end
	axle_bottom = minima_locations;
	axle_sides = maxima_locations;

end