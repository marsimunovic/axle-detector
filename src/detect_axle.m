function [axle_data] = detect_axle_tmp(Xcrop, input_data, axle_candidates, to_file)
%%perform detection on selected candidates
%%draw detections in gif file with bottom contour

	global DEBUG_ACTIVE
	global SAVING_ON

	axle_data = double([]);
	MAX_EDGE_HEIGHT_DIFF = 10; %difference between tyre left and right edge heights
	S = 'g'; #draw ellipse with green color

	if SAVING_ON
		fig = figure;
		set(fig, "visible", "off")
		#disp('Plotting section')
		plot(input_data)
	end

	[im_h, im_w] = size(Xcrop);

	minima_locations = [];
	new_maxima_locations = [];
	axle_candidates;

	if DEBUG_ACTIVE > 5
		#disp('printing')
		#pause(3)
		aa_min = [];
		aa_max = [];
		for cand = axle_candidates
			aa_min = [aa_min cand.loc];
			aa_max = [aa_max cand.lt cand.rt];
		end
		fig2 = figure(randi([10000 100000]))
		plot(input_data)
		hold on
		plot(aa_min, input_data(aa_min), 'rx');
		hold on
		plot(aa_max, input_data(aa_max), 'go');
	end
	
	for aa = axle_candidates
		peakl = input_data(aa.lt);
		peakr = input_data(aa.rt);
		pos = aa.loc;

		if peakl < peakr
			#disp('search right')
			while (input_data(pos) < peakl) && (pos < numel(input_data))
				pos = pos + 1;
			end
			aa.rt = pos;
		elseif peakr < peakl
			#disp('search left')
			while (input_data(pos) < peakr) && (pos >= 1) 
				pos = pos - 1;
			end
			aa.lt = pos;
		else
			#do nothing
		end

		leftH = input_data(aa.lt);
    	rightH = input_data(aa.rt);
		cntry = min([leftH rightH]);
		cntrx = aa.loc;
		min_low = input_data(cntrx);
		ra = min([(aa.rt - cntrx) (cntrx - aa.lt)]); # axle width
		rb = cntry - min_low; #axle height
		start = cntrx - ra;
		stop = cntrx + ra;
		
		vehicle_len = numel(input_data);
		#calculate relative position of the candidate
      	rel_pos = double(cntrx)*100/double(vehicle_len);

		#elimination steps
		if (input_data(cntrx) > 0 && (abs(leftH-rightH) <= MAX_EDGE_HEIGHT_DIFF))
			if(cntry < 30) && (rel_pos > 20)
				left_e = [];
				left_loc = [];
				right_e = [];
				right_loc = [];
     			area_over = 0;
     			if (DEBUG_ACTIVE > 0)
     				disp('Calculating area')
     				#fig2 = figure(randi([10000 100000]))
     				#imshow(Xcrop(im_h-cntry:im_h-min_low, start-1:stop+1))
     			end
     			err_cnt = 0;
				for m = im_h-min_low:-1:im_h-cntry
					empty = 0;
					area_part1 = cntrx;
					for nn = start-1:stop+1
						if Xcrop(m,nn) == 0
							#disp('found most left position')
							left_loc = [left_loc nn];
							left_e = [left_e (im_h - m)];
							area_part1 = nn;
							empty = empty + 1;
							break;
						end
					end
					if empty == 0
						#disp('to left')
						err_cnt = err_cnt + 1;
					end
					empty = 0;
					area_part2 = cntrx;
					for nn = stop+1:-1:start-1
						if Xcrop(m,nn) == 0
							#disp('found most right position')
							right_loc = [right_loc nn];
							right_e = [right_e (im_h - m)];
							area_part2 = nn;
							empty = empty + 1;
							break;
						end
					end
					if empty  == 0
						#disp('to right')
						err_cnt = err_cnt + 1;
					end
					#[area_part2-area_part1]
					area_over = area_over + (area_part2 - area_part1 + 1);
				end
				if err_cnt > 0
					disp('Found empty row in axle')
				end
				ellipse_area = 0.5*ra*rb*pi;
				ratioo = double(double(area_over)/double(ellipse_area))*100;
				#rel_error = 100.0*double(abs(area_over-ellipse_area))/...
				#				  double(max([area_over ellipse_area]));
				if (ratioo > 80) && (ratioo < 130)
					axle_data = double([axle_data; [cntrx, cntry, ra, rb, min_low,...
								 leftH, rightH, ratioo, vehicle_len]]);
					if SAVING_ON
						hold on
						drawEllipse(cntrx, cntry, ra, rb, S);
						hold on
						plot(left_loc, left_e, 'r')
						hold on
						plot(right_loc, right_e, 'r')
						minima_locations = [minima_locations aa.loc];
						new_maxima_locations = [new_maxima_locations aa.lt aa.rt];
					end
				end
			end
		end
	end

	if SAVING_ON
		%% plot detected bottoms and edges of tyres on image
		hold on
		plot(minima_locations, input_data(minima_locations), 'ro');
		hold on
		plot(new_maxima_locations, input_data(new_maxima_locations), 'go');
		printf("Saving %s\n", to_file );
		hold on
		print(fig, to_file,'-dgif')
		close(fig)
	end
end