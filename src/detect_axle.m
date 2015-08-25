function [axle_data] = detect_axle(Xcrop, input_data, minima_locations, maxima_locations, to_file)
	axle_data = double([]);
	new_maxima_locations = [];

	MAX_EDGE_HEIGHT_DIFF = 10; %difference between tyre left and right edge heights
	#figure
	#plot(input_data)
	#hold on
	#plot(minima_locations, input_data(minima_locations), 'ro');
	#hold on
	#plot(maxima_locations, input_data(maxima_locations), 'go');

	fig = figure;
	set(fig, "visible", "off")
	#disp('Plotting section')
	plot(input_data)

	[im_h, im_w] = size(Xcrop);
  	new_maxima_locations = maxima_locations;
	for n = 1 : numel(minima_locations)
		peakl = input_data(new_maxima_locations(2*n-1));
		peakr = input_data(new_maxima_locations(2*n));
		pos = minima_locations(n);
		if peakl < peakr
		#disp('search right')
			while (input_data(pos) < peakl) && (pos < numel(input_data))
				pos = pos + 1;
			end
			new_maxima_locations(2*n) = pos;
		elseif peakr < peakl
		#disp('search left')
			while (input_data(pos) < peakr) && (pos >= 1) 
				pos = pos - 1;
			end
			new_maxima_locations(2*n-1) = pos;
		else
		end
    	
    	leftH = input_data(new_maxima_locations(2*n-1));
    	rightH = input_data(new_maxima_locations(2*n));
		cntry = min([leftH rightH]);
		cntrx = minima_locations(n);
    
    	min_low = input_data(cntrx);
		r = cntry - min_low;
		rb = r;
		ra = min([(new_maxima_locations(2*n) - cntrx) (cntrx - new_maxima_locations(2*n-1))]);
		S = 'g';

		if (input_data(cntrx) > 0 && (abs(leftH-rightH) <= MAX_EDGE_HEIGHT_DIFF))
			#printf("input_data %d\n", cntrx);
			ellipse_area = ra*rb*pi/2;
			start = cntrx - ra;
			stop = cntrx + ra;
			area_under = sum(input_data(start:stop));


			area_over = 2*ra*cntry - area_under;
			#double([ellipse_area area_over (ellipse_area./area_over)])
			ratioo = double(double(ellipse_area)/double(area_over));
			vehicle_len = numel(input_data);
      		rel_pos = double(cntrx)*100/double(vehicle_len);
			%% do this only for confirmed lifted axles
			if (cntry < 30) && (ratioo <= 2.1) && (ratioo >= 0.6) && (rel_pos > 20)
				err_cnt = 0;
#				[im_h-cntry,im_h-min_low-2, start,stop]
#
#				figure
#				imshow(Xcrop(im_h-cntry:im_h-min_low, start-1:stop+1))
#				total = 0;
#				simmetry = 0;
				left_e = [];
				left_loc = [];
				right_e = [];
				right_loc = [];
     			area_over = 0;
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
						disp('to left')
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
						disp('to right')
						err_cnt = err_cnt + 1;
					end
					#[area_part2-area_part1]
					area_over = area_over + (area_part2 - area_part1 + 1);
				end
				#area_over
				#[ellipse_area, ra, rb]
				#left_loc
				#right_loc

#					
#					for n = 1:ra
#						total = total + 1;
#						if(Xcrop(m,cntrx-n) == Xcrop(m,cntrx+n))
#							simmetry = simmetry + 1;
#						else
#							simmetry = simmetry - 1;
#						end
#					end
				
#				simmetry = simmetry*100/total;
#				if simmetry < 50
#					disp('WARNING: Detected iregular shape!')
#				end
#				#Xcrop(im_h-cntry-1:im_h-min_low, start:cntrx-1)
#				#Xcrop(im_h-cntry-1:im_h-min_low, cntrx+1:stop)
#
#				drop = 0;
#				search_range = [start:start+10 stop-10:stop];
#				for n=search_range
#					tmp = abs(input_data(n)-input_data(n+1));
#					if tmp > drop
#						drop = tmp;
#					end
#				end
#				drop = drop*100/rb;
#				if drop > 60
#					drop
#					disp('WARNING: Big local change in edge!!!')
#				end
				#disp('Drawing elipse')
#				search_range = [start:stop];
#				hor_lines = [];
#				cnt_ = 0;
#				for n = search_range
#					if input_data(n) == input_data(n+1)
#						cnt_ = cnt_+1;
#					else
#						if cnt_ > 0
#							hor_lines = [hor_lines cnt_ n];
#						end
#						cnt_ = 0;
#					end
#				end
#
#				hor_lines
				ratioo = double(double(area_over)/double(ellipse_area))*100
				axle_data = double([axle_data; [cntrx, cntry, ra, rb, min_low, leftH, ...
                     rightH, ratioo, vehicle_len]]);
#				left_loc
#				left_e
#				right_loc
#				right_e
#				figure
				hold on
				drawEllipse(cntrx, cntry, ra, rb, S);
				hold on
				plot(left_loc, left_e, 'r')
				hold on
				plot(right_loc, right_e, 'r')
			else
				[cntry, area_over, ellipse_area, ratioo, rel_pos]
			end

		end

		#DrawCircle(cntrx, cntry, r, int16(r)*4, S);

	end



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