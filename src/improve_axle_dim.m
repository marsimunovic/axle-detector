function [real_axle_candidates, aux_axle_candidates] = improve_axle_dim(input_data, filtered, offset, ra_cand, aa_cand)
%%improve axle candidate identificator positions
	real_axle_candidates = [];
	for ra = ra_cand
		left = ra.lt - offset;
		right = ra.rt - offset;
		middle = ra.loc - offset;
		lm = find(input_data(left:middle) >= input_data(left));
		last_left = left + lm(end) - 1;
		rm = find(input_data(right:-1:middle) >= input_data(right));
		last_right = right - rm(end) + 1;
		ra.lt = last_left + offset;
		ra.rt = last_right + offset;
		real_axle_candidates = [real_axle_candidates ra];
	end

	aux_axle_candidates = [];
	for ra = aa_cand
		left = ra.lt - offset;
		right = ra.rt - offset;
		middle = ra.loc-offset;
		lm = find(input_data(left:middle) >= input_data(left));
		last_left = left + lm(end) - 1;
		#input_data(right:-1:middle)
		#input_data(right)
		#[middle right]
		rm = find(input_data(right:-1:middle) >= input_data(right));
		last_right = right - rm(end) + 1;
		ra.lt = last_left + offset;
		ra.rt = last_right + offset;
		aux_axle_candidates = [aux_axle_candidates ra];
	end

end