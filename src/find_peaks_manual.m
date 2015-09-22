function [real_axle_candidates, aux_axle_candidates] = find_peaks_manual(input_data)
%%find local maxima in input signal
%%input_data - smooth input signal
%%peaks - location indices of maxima values
	peaks = [];
	peaks_min = [];
	real_axle_candidates = [];
	aux_axle_candidates = [];
	ind = 1;
	max_cand = input_data(1);
	N = size(input_data,2);
	n = 2;
	#find maxima
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
	#figure
	#plot(input_data)

	#find minima
	for n = 2:M
		[M,I] = min(input_data(peaks(n-1)+1:peaks(n)));
		loc = I + peaks(n-1);
		#if more than one minimum
		offset = 1;
		#input_data(loc:loc+5);
		while(loc+offset < peaks(n))
			if(input_data(loc) == input_data(loc+offset))
				#[input_data(loc) input_data(loc+offset)]
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
		#[peaks(n-1) loc peaks(n)]#

		#hold on
		#ind123 = [new_candidate.lt loc new_candidate.rt];
		#plot(ind123, input_data(ind123), 'rx');
		
		#if right peak is higher than left
		if (input_data(new_candidate.lt) < input_data(new_candidate.rt))
			#search smaller value on the right side of the "valley"
			while(input_data(new_candidate.lt) < input_data(new_candidate.rt)-1)
				new_candidate.rt = new_candidate.rt - 1;
			end
		#if left peak is higher than right
		elseif (input_data(new_candidate.lt) > input_data(new_candidate.rt))
			#search smaller value on the left side of the "valley"
			while(input_data(new_candidate.lt + 1) > input_data(new_candidate.rt))
				new_candidate.lt = new_candidate.lt + 1;
			end
		#if both are equal
		else
			#do nothing
		end

		#hold on
		#ind123 = [new_candidate.lt loc new_candidate.rt];
		#plot(ind123, input_data(ind123), 'co');
	
		if(input_data(loc) > 0.5)
			aux_axle_candidates = [aux_axle_candidates new_candidate];
		else
			real_axle_candidates = [real_axle_candidates new_candidate];
		end
	end

						
end