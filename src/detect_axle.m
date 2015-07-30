function [axle_data] = detect_axle(input_data, minima_locations, maxima_locations, to_file)
	axle_data = [];
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
			while input_data(pos) < peakl
				pos = pos + 1;
			end
			new_maxima_locations = [new_maxima_locations maxima_locations(last_smaller) pos];
		elseif peakr < peakl
		#search left
			pos = minima_locations(n);
			while input_data(pos) < peakr
				pos = pos - 1;
			end
			new_maxima_locations = [new_maxima_locations pos maxima_locations(last_smaller+1)];
		else
			new_maxima_locations = [new_maxima_locations maxima_locations(last_smaller) maxima_locations(last_smaller+1)];
		end
		centery = min([input_data(new_maxima_locations(end)) input_data(new_maxima_locations(end-1))]);
		centerx = minima_locations(n);
		r = centery - input_data(centerx);
		rb = r;
		ra = min([(new_maxima_locations(end) - centerx) (centerx - new_maxima_locations(end-1))]);
		S = 'g';
		if (input_data(centerx) > 0)
			#printf("input_data %d\n", centerx);
			ellipse_area = ra*rb*pi/2;
			start = centerx - ra;
			stop = centerx + ra;
			area_under = sum(input_data(start:stop));
			
			area_over = 2*ra*centery - area_under;
			#double([ellipse_area area_over (ellipse_area./area_over)])
			ratioo = double(double(ellipse_area)/double(area_over));

			%% do this only for confirmed lifted axles
			if (area_over > 0) && (ellipse_area > 200) && (ratioo <= 1.5) && (ratioo >= 0.6)
				#disp('Drawing elipse')
				axle_data = [axle_data; [centerx, centery, ra, rb, area_over, ratioo]];
				hold on
				drawEllipse(centerx, centery, ra, rb, S);
			end

		end

		#DrawCircle(centerx, centery, r, int16(r)*4, S);

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