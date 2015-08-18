function [peaks, peaks_min, axle_candidates] = find_peaks_manual(input_data)
%%find local maxima in input signal
%%input_data - smooth input signal
%%peaks - location indices of maxima values
	peaks = [];
	peaks_min = [];
	axle_candidates = [];
	ind = 1;
	max_cand = input_data(1);
	N = size(input_data,2);
	n = 2;
	while n <= N
		if (max_cand > input_data(n))
			peaks = [peaks ind];
			#find next max_cand
			while (input_data(n-1) > input_data(n)) && (n < N)
				#do nothing
				n = n + 1;
			end
			max_cand = input_data(n);
			ind = n;
		else
			max_cand = input_data(n);
			ind = n;
		end
		n = n + 1;
	end
	M = numel(peaks);
	for n = 2:M
		[M,I] = min(input_data(peaks(n-1):peaks(n)));
		loc = I + peaks(n-1);
		offset = 1;
		while(loc+offset < peaks(n))
			if(input_data(loc) == input_data(loc+offset))
				offset = offset + 1;
			else
				break;
			end
		end
		offset = int16(offset/2);
		loc = loc + offset;
		peaks_min = [peaks_min loc];

		%%compresses peak values in candidates structures
		%%each structure has three points, tyre lowest point and
		%%left and right tyre edges
		new_candidate.lt = peaks(n-1);
		new_candidate.rt = peaks(n);
		new_candidate.loc = loc;
		axle_candidates = [axle_candidates new_candidate];
	end
end