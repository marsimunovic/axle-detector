function [lifted_axles, compare_axles] = find_axle_candidates(input_data, file_name = '')
	%%find real axes and lifted axes candidates

	global DEBUG_ACTIVE #print definitions
	global MIN_ACCEPTED_LENGTH
	compare_axles = [];
	lifted_axles = [];

	if(numel(input_data) < MIN_ACCEPTED_LENGTH)
		return;
	end

	#first smoothen vehicle bottom contour values
	#offset - han filter length is not fixed
	[output, offset] = han_filter(input_data);

	#some constants used in candidate elimination process
	MIN_TYRE_WIDTH = 20;       %min tyre width in pixels
	MAX_PIXEL_VARATION = 3;    %maximum pixel variation between two neighbor minima
	MAX_LIFTED_HEIGHT = 10;    %lowest point of lifted tyre in pixels
	MIN_TYRE_RADIUS = 5;       %min lifted tyre radius 	
	MAX_EDGE_HEIGHT_RATIO = 4; %ratio between tyre left and right edge heights
	WIDTH_PERCENTAGE = 0.5;    %min percentage of real axle width in candidates
	MAIN_AXLE_RATIO = 1.2;     

	[ra_cand, aa_cand] = find_peaks_manual(output);
	if DEBUG_ACTIVE > 3
		ra_min = [];
		ra_max = [];
		for cand = ra_cand
			ra_min = [ra_min cand.loc];
			ra_max = [ra_max cand.lt cand.rt];
		end
		ra_min = ra_min - offset;
		ra_max = ra_max - offset;
		aa_min = [];
		aa_max = [];
		for cand = aa_cand
			aa_min = [aa_min cand.loc];
			aa_max = [aa_max cand.lt cand.rt];
		end
		

#		figure
#		plot(output)
#		hold on
#		plot(aa_min, output(aa_min), 'rx');
#		hold on
#		plot(aa_max, output(aa_max), 'go');
#		hold on
#		plot(ra_min, output(ra_min), 'rx');
#		hold on
#		plot(ra_max, output(ra_max), 'go');
	end

	[ra_cand, aa_cand] = improve_axle_dim(input_data, output, offset, ra_cand, aa_cand);
#	#ra_cand_ = ra_cand;
#	#aa_cand_ = aa_cand;
#		ra_min = [];
#		ra_max = [];
#		offs = offset;
#		for cand = ra_cand_
#			ra_min = [ra_min (cand.loc-offs)];
#			ra_max = [ra_max (cand.lt-offs) (cand.rt-offs)];
#		end
#		aa_min = [];
#		aa_max = [];
#		for cand = aa_cand_
#			aa_min = [aa_min (cand.loc-offs)];
#			aa_max = [aa_max (cand.lt-offs) (cand.rt-offs)];
#		end
#
#
#		figure
#		plot(input_data)
#		hold on
#		plot(aa_min, input_data(aa_min), 'rx');
#		hold on
#		plot(aa_max, input_data(aa_max), 'go');
#		hold on
#		plot(ra_min, input_data(ra_min), 'rx');
#		hold on
#		plot(ra_max, input_data(ra_max), 'go');

#		figure
#		plot(output)
#		hold on
#		plot(aa_min, output(aa_min), 'rx');
#		hold on
#		plot(aa_max, output(aa_max), 'go');
#		hold on
#		plot(ra_min, output(ra_min), 'rx');
#		hold on
#		plot(ra_max, output(ra_max), 'go');
#	pause(60)

	#
	#if necessary, perform small correction on candidate left and right edge locations
	#this is done if there is a same value of the contour in the neighborhood of that 
	#edge nearer to candidate center
	#additonaly, calculate axle widths
	Nra = numel(ra_cand); 
	if Nra < 2
		if DEBUG_ACTIVE
			disp('Error! Missing axles')
		end
		return
	end
	raxle_halfw = zeros(1, Nra); #half widths in real axle candidates
	for n = 1 : Nra
		raxle_halfw(n) = min(ra_cand(n).loc - ra_cand(n).lt,...
						 ra_cand(n).rt - ra_cand(n).loc);
	end
	#find two widest candidates
	[firstw, ind1] = max(raxle_halfw);
	raxle_halfw(ind1) = 0;
	[secondw, ind2] = max(raxle_halfw);

	compare_axles = [ra_cand(ind1) ra_cand(ind2)];


	for n = 1:numel(aa_cand)
		aa = aa_cand(n);
		indl = aa.lt;
		indr = aa.rt;
		ind_min = aa.loc;

		distx = indr - indl; # distance in pixels between two edges
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

		half_radius = min(ind_min - indl, indr - ind_min);
		checker = 0;
		axle_ratio = double(1.0*firstw)./double(secondw);
		if axle_ratio >= MAIN_AXLE_RATIO
			#disp('Big difference between two low axles')
			#first check smaller
			greater = max(half_radius, secondw);
			smaller = min(half_radius, secondw);
			if smaller > greater*WIDTH_PERCENTAGE				
				checker = checker + 1;
			end
		end
		#check with bigger
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
		aa.loc = ind_min - offset;
		aa.lt = indl - offset;
		aa.rt = indr - offset;
		lifted_axles = [lifted_axles aa];
	end
	

	if DEBUG_ACTIVE > 3
		#disp('printing')
		#pause(3)
		aa_min = [];
		aa_max = [];
		for cand = lifted_axles
			aa_min = [aa_min cand.loc];
			aa_max = [aa_max cand.lt cand.rt];
		end
		figure
		plot(input_data)
		hold on
		plot(aa_min, input_data(aa_min), 'rx');
		hold on
		plot(aa_max, input_data(aa_max), 'go');
	end

end