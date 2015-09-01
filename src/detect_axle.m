function [axle_data] = detect_axle(Xcrop, input_data, axle_candidates, to_file)
%%perform detection on selected candidates
%%draw detections in gif file with bottom contour

	global DEBUG_ACTIVE
	global SAVING_ON

	axle_data = double([]);
	MAX_EDGE_HEIGHT_DIFF = 15; %difference between tyre left and right edge heights
	S = 'g'; #draw ellipse with green color
	fig = 1;
	if SAVING_ON
		fig = figure(1);
		set(fig, "visible", "off")
		#disp('Plotting section')
		plot(input_data)
	end

	[im_h, im_w] = size(Xcrop);

	minima_locations = [];
	new_maxima_locations = [];
	axle_candidates;

	for aa = axle_candidates
		peakl = input_data(aa.lt);
		better_cand = find(input_data(aa.lt+1:aa.lt+8) >= peakl);
		if(numel(better_cand) > 0)
			disp('Fixing left')
			[aa.lt aa.lt + better_cand(end) peakl input_data(aa.lt + better_cand(end))]
			aa.lt = aa.lt + better_cand(end);
			peakl = input_data(aa.lt);
		end
		peakr = input_data(aa.rt);

		better_cand = find(input_data(aa.rt-8:aa.rt-1) >= peakr);
		if(numel(better_cand) > 0)
			disp('Fixing right')
			[aa.rt aa.rt-(9-better_cand(1)) peakr input_data(aa.rt-(9-better_cand(1)))]
			aa.rt = aa.rt-(9-better_cand(1));
			peakr = input_data(aa.rt);
		end

		pos = aa.loc;

		if peakl < peakr
			while (input_data(pos) < peakl) && (pos < numel(input_data))
				pos = pos + 1;
			end
			#disp('search right')
			aa.rt = pos;
		elseif peakr < peakl
			while (input_data(pos) < peakr) && (pos >= 1) 
				pos = pos - 1;
			end
			#disp('search left')
			aa.lt = pos;
		else
			#do nothing
		end
		if DEBUG_ACTIVE > 0
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

		leftH = input_data(aa.lt);
    	rightH = input_data(aa.rt);
		cntry = min([leftH rightH]);
		cntrx = aa.loc;
		min_low = input_data(cntrx);
		ra = min([(aa.rt - cntrx) (cntrx - aa.lt)]); # axle width
		ra2 = max([(aa.rt - cntrx) (cntrx - aa.lt)]); #bigger width, data for stat. inference
		ax_ratio = double(ra2*100)/double(ra);
		rb = cntry - min_low; #axle height
		start = cntrx - ra;
		stop = cntrx + ra;
		realW1 = 100;
		realW2 = 100;


		if(min_low >=8)
			%%there is big probability this is not axle
			%%perform additional checking
			NUM = 2;
		    ENDD = 6;
		    bottom_edge = input_data(start:stop);
		    for ptr = 1 : numel(bottom_edge) - ENDD
		        if(sum(bottom_edge(ptr+1:ptr+NUM) == bottom_edge(ptr)) == NUM)
		            %% found small straight line
		        	%%check next couple of pixels
		            found = 0;
		            for ptr2 = ptr + NUM + 1: ptr + ENDD
		                if bottom_edge(ptr) == bottom_edge(ptr2)
		                    found = ptr2;
		                end
		            end
		            if found
		                bottom_edge(ptr:found) = bottom_edge(ptr)*ones(1, found-ptr+1);
		                ptr = found-NUM;
		            end
		        end
		    end
		    input_data(start:stop) = bottom_edge;
#		    fig2 = figure(randi([10000 100000]))
#		    plot(input_data(start:stop), 'b')
#		    hold on
#			plot(bottom_edge, 'r')
		end
		
		vehicle_len = numel(input_data);
		#calculate relative position of the candidate
      	rel_pos = double(cntrx)*100/double(vehicle_len);

		#elimination steps
		if (input_data(cntrx) > 0 && (abs(leftH-rightH) <= MAX_EDGE_HEIGHT_DIFF) && ra > 10 && rb > 6 && ax_ratio < 400)
			if DEBUG_ACTIVE > 0
				disp('First elimination')
			end
			if(cntry < 30) && ((rel_pos > 20) || (cntrx > 350))
				if DEBUG_ACTIVE > 0
					disp('Second elimination')
				end
				left_e = [];
				left_loc = [];
				right_e = [];
				right_loc = [];
     			area_over = 0;
     			if (DEBUG_ACTIVE > 0)
     				disp('Calculating area')
     				fig2 = figure(randi([10000 100000]))
     				imshow(Xcrop(im_h-cntry:im_h-min_low, start-1:stop+1))
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
					if (m == im_h-cntry)
						sum1 = sum(Xcrop(m, area_part1 : area_part2) == 0);
						realW1 = [sum1*50/ra];
					end
					if (m == im_h - cntry + 1)
						sum1 = sum(Xcrop(m, area_part1 : area_part2) == 0);
						realW2 = [sum1*50/ra];
					end
				end
				if err_cnt > 0
					disp('Found empty row in axle')
					max_err_pixels = 2*ra;
					black_pix = im_w - sum(Xcrop(m, :))
					if black_pix > max_err_pixels
						#this is not noisy line and axle cannot have empty line
						continue;
					end
				end
				ellipse_area = 0.5*ra*rb*pi;
				ratioo = double(double(area_over)/double(ellipse_area))*100;
				#rel_error = 100.0*double(abs(area_over-ellipse_area))/...
				#				  double(max([area_over ellipse_area]));
				if (ratioo > 80) && (ratioo < 130)
					if DEBUG_ACTIVE > 0
						disp('Third elimination')
					end
					if (ratioo < 90) && (ax_ratio > 260)
						##irregular shape
						continue;
					end
					

					axle_data = double([axle_data; [cntrx, cntry, ra, rb, ax_ratio, min_low,...
								 leftH, rightH, ratioo, vehicle_len, realW1, realW2]]);
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
#		else
#			if DEBUG_ACTIVE > 0
#				[input_data(cntrx), peakl, peakr, leftH, rightH, ra, ax_ratio]
#			end
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