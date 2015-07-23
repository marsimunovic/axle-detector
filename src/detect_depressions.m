function [depresion_ind] = detect_depressions(input_signal, depression_pp)
%% detect areas of signal swing greater than depression_dpp
%% 
Data = input_signal;
[Maxima,MaxIdx] = findpeaks(Data);
DataInv = 1.000001*max(Data) - Data;
[Minima,MinIdx] = findpeaks(DataInv);
Minima = Data(MinIdx)
Maxima

triplets = [];
for mx = 2 : size(MaxIdx,2)
	leftMax = MaxIdx(mx-1);
	rightMax = MaxIdx(mx);
	indices = find((MinIdx > leftMax) & (MinIdx < rightMax));
	if(size(indices, 2) == 0)
		continue;
	end
	depths = input_signal(MinIdx(indices));
	valley = min(depths(:))
	leftPeak = input_signal(leftMax)
	rightPeak = input_signal(rightMax)
	if(min([leftPeak rightPeak]) > (valley + depression_pp))
		%add this points to list of 
		disp('add point')
		triplets(end+1, :) = [leftMax rightMax valley];
	end
end

depresion_ind = triplets;