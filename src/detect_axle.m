function [axle_data] = detect_axle(input_data, minima_locations, maxima_locations, to_file)
	axle_data = double([]);
	new_maxima_locations = [];
	fig = figure;
	set(fig, "visible", "off")
	#disp('Plotting section')
	plot(input_data)
  
	for n = 1 : numel(minima_locations)
		indx = find(maxima_locations < minima_locations(n));
		last_smaller = indx(end);
		#[maxima_locations(last_smaller) minima_locations(n) maxima_locations(last_smaller + 1)]
		peakl = input_data(maxima_locations(last_smaller));
		peakr = input_data(maxima_locations(last_smaller + 1));
		if peakl < peakr
		#search right
			pos = minima_locations(n);
			while (input_data(pos) < peakl) && (pos < numel(input_data))
				pos = pos + 1;
			end
			new_maxima_locations = [new_maxima_locations maxima_locations(last_smaller) pos];
		elseif peakr < peakl
		#search left
			pos = minima_locations(n);
			while (input_data(pos) < peakr) && (pos >= 1) 
				pos = pos - 1;
			end
			new_maxima_locations = [new_maxima_locations pos maxima_locations(last_smaller+1)];
		else
			new_maxima_locations = [new_maxima_locations maxima_locations(last_smaller) maxima_locations(last_smaller+1)];
		end
    
    leftH = input_data(new_maxima_locations(end));
    rightH = input_data(new_maxima_locations(end-1));
		cntry = min([leftH rightH]);
		cntrx = minima_locations(n);
    
    min_low = input_data(cntrx);
		r = cntry - min_low;
		rb = r;
		ra = min([(new_maxima_locations(end) - cntrx) (cntrx - new_maxima_locations(end-1))]);
		S = 'g';

		if (input_data(cntrx) > 0)
			#printf("input_data %d\n", cntrx);
			ellipse_area = ra*rb*pi/2;
			start = cntrx - ra;
			stop = cntrx + ra;
			area_under = sum(input_data(start:stop));
			
			area_over = 2*ra*cntry - area_under;
			#double([ellipse_area area_over (ellipse_area./area_over)])
			ratioo = double(double(ellipse_area)/double(area_over));
			vehicle_len = numel(input_data);
      		rel_pos = double(cntrx)*100/vehicle_len;
			%% do this only for confirmed lifted axles
			if (cntry < 30) && (area_over > 300)  && (ellipse_area > 200) && (ratioo <= 1.5) && (ratioo >= 0.6) && (rel_pos > 15)
				#disp('Drawing elipse')
				axle_data = double([axle_data; [cntrx, cntry, ra, rb, min_low, leftH, ...
                     rightH, area_over, vehicle_len]]);
				hold on
				drawEllipse(cntrx, cntry, ra, rb, S);
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
end