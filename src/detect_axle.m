function [axle_data] = detect_axle(Xcrop, CropCount, input_data, axle_candidates, to_file)
%%perform detection on selected candidates
%%draw detections in gif file with bottom contour

	global DEBUG_ACTIVE
	global SAVING_ON


	axle_data = double([]);
	MIN_AXLE_HEIGHT = 7;
	MAX_EDGE_HEIGHT_DIFF = 20; %difference between tyre left and right edge heights
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
		%%centering minima
		min_eq = sum(input_data(aa.loc-5:aa.loc+5) == input_data(aa.loc));
		if (min_eq > 6)
			flat_min = find(input_data(aa.lt+1:aa.rt-1) == input_data(aa.loc));
			new_flat_min = (numel(flat_min) + 1) / 2;
			aa.loc = aa.lt + flat_min(int16(new_flat_min));
		end

		peakl = input_data(aa.lt);
		peakr = input_data(aa.rt);

		#disp('equal')
		leftw = aa.loc - aa.lt;
		rightw = aa.rt - aa.loc;
		req_min = input_data(aa.loc) + MIN_AXLE_HEIGHT;
		if (leftw > rightw)
			#disp('left is farther')
			cntr = 0;
			prev = input_data(aa.loc-rightw + 2);
			ind2 = 0;
			ind3 = 0;
			for lw = aa.loc - rightw + 1: -1: aa.lt
				if(input_data(lw) == prev)
					cntr = cntr + 1;
				else
					cntr = 0;
				end
				prev = input_data(lw);
				if (ind2 == 0) && (abs(input_data(lw)-peakl) == 2)
					ind2 = lw;
				end
				if (ind3 == 0) && (abs(input_data(lw)-peakl) == 3)
					ind3 = lw;
				end
				if (input_data(lw) >= peakl) || ((cntr >= 3) && (input_data(lw) > req_min)) 
					if (aa.lt == lw)
						if (ind3 != 0) && (ind3 - lw > 10) && (input_data(ind3) > req_min)
							lw = ind3;
						end
						if (ind2 != 0) && (ind2 - lw > 5) && (input_data(ind2) > req_min)
							lw = ind2;
							disp('Fixing 1')
						end
					end
					aa.lt = lw;
					break;
				end
			end

			while(input_data(aa.lt) <= input_data(aa.rt - 1))
				aa.rt = aa.rt - 1;
			end
		elseif (rightw > leftw)
			#disp('right is farther')
			cntr = 0;
			prev = input_data(aa.loc+leftw - 2);
			ind2 = 0;
			for rw = aa.loc + leftw - 1: aa.rt
				if(input_data(rw) == prev)
					cntr = cntr + 1;
				else
					cntr = 0;
				end
				prev = input_data(rw);
				if (ind2 == 0) && (abs(input_data(rw)-peakr) == 2)
					ind2 = rw;
				end
				if (input_data(rw) >= peakr) || ((cntr >= 3) && (input_data(rw) > req_min))
					if (aa.rt == rw)
						if (ind2 != 0) && (rw-ind2 > 5) && (input_data(ind2) > req_min)
							rw = ind2;
							disp('Fixing 2')
						end
					end
					aa.rt = rw;
					break;
				end
			end
			while(input_data(aa.lt + 1) >= input_data(aa.rt))
				aa.lt = aa.lt + 1;
			end
		else
		#do nothing
		end

		if DEBUG_ACTIVE > 3
			#disp('printing')
			#pause(3)
			aa_min = [];
			aa_max = [];
			for cand = axle_candidates
				aa_min = [aa_min cand.loc];
				aa_max = [aa_max cand.lt cand.rt];
			end
			fig2 = figure(randi([10000 100000]));
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

		left_set = [];
     	right_set = [];

	
		vehicle_len = numel(input_data);
		#calculate relative position of the candidate
      	rel_pos = double(cntrx)*100/double(vehicle_len);
     
		#elimination steps
		disp('Test')
		if ((input_data(cntrx) > 0) (abs(leftH-rightH) <= MAX_EDGE_HEIGHT_DIFF) && ra > 10 && rb >= MIN_AXLE_HEIGHT && ax_ratio < 200)
			if DEBUG_ACTIVE > 0
				disp('First elimination')
			end
			if(cntry < 34) && ((rel_pos > 20) || (cntrx > 350))
				if DEBUG_ACTIVE > 0
					disp('Second elimination')
				end
				left_e = [];
				left_loc = [];
				right_e = [];
				right_loc = [];
     			area_over = 0;
     			if (DEBUG_ACTIVE > 3)
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
					if (isempty(find(left_set == area_part1)))
						left_set = [left_set area_part1];
					end
					if (isempty(find(right_set == area_part2)))
						right_set = [right_set area_part2];
					end
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
				#rb
				ellipse_area = 0.5*(ra-0.5)*rb*pi;
				ratioo = double(double(area_over)/double(ellipse_area))*100;
				#rel_error = 100.0*double(abs(area_over-ellipse_area))/...
				#				  double(max([area_over ellipse_area]));
				RS = numel(right_set);
				LS = numel(left_set);
				side_var = double(min([RS LS]));
				if ((min_low + CropCount) > 8)
					if (100.0*double(side_var)/double(rb)) < 50
						disp('Square angle')
						(100.0*double(side_var)/double(rb))
						continue;
					end
				else
#					disp('8 or smaller')
#					100.0*double(side_var)/double(rb)
#					if (100.0*double(side_var)/double(rb)) < 40
#						sf = [im_h-min_low:-1:im_h-cntry]; %%search field
#						el_cnt = 0;
#						if (RS < LS)
#							disp('check dynamic right')
#							%%check dynamic
#							for el = sf
#								if (sum(find(input_data(stop+1:-1:start-1) == el)) > 0)
#									el_cnt = el_cnt + 1
#								end
#							end
#
#						elseif (LS < RS)
#							disp('check dynamic left')
#							for el = sf
#								if (sum(find(input_data(start-1:stop+1) == el)) > 0)
#									el_cnt = el_cnt + 1
#								end
#							end
#						else
#							disp('RS == LS')						
#						end
#					end
				end
				if (ratioo >= 85) && (ratioo <= 130) && (realW1 > 85) && (realW2 > 85)
					if DEBUG_ACTIVE > 0
						disp('Third elimination')
					end
					
					

					axle_data = double([axle_data; [cntrx, cntry + CropCount, ra, rb, ax_ratio, min_low + CropCount,...
								 leftH + CropCount, rightH + CropCount, ratioo, vehicle_len, realW1, realW2, RS, LS]]);
					if SAVING_ON
						hold on
						grid on
						hold on
						drawEllipse(cntrx, cntry, ra, rb, S);
						hold on
						plot(left_loc, left_e, 'r')
						hold on
						plot(right_loc, right_e, 'r')
						minima_locations = [minima_locations aa.loc];
						new_maxima_locations = [new_maxima_locations aa.lt aa.rt];
					end
				else
				end
			else
				disp('Relative position!')
				[rel_pos cntrx cntry]
			end
#		else
#			if DEBUG_ACTIVE > 0
#				[input_data(cntrx), leftH, rightH, ra, ax_ratio]
#			end
		end
	end

	if SAVING_ON
		%% plot detected bottoms and edges of tyres on image
		#hold on
		#plot(minima_locations, input_data(minima_locations), 'ro');
		hold on
		plot(new_maxima_locations, input_data(new_maxima_locations), 'go');
		printf("Saving %s\n", to_file );
		hold on
		print(fig, to_file,'-dgif')
		close(fig)
	end
end