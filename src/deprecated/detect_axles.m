function [num, positions] = detect_axles(bottom_edge)
#detect axles touching ground
AXLE_PIX_MIN = 10;
WINDOW = 20;
width = numel(bottom_edge);
count_zeros = numel(find(bottom_edge(1, 1:WINDOW) == 0));
num = 0;

#figure
#plot(bottom_edge)
for n = WINDOW + 1 : width
	if(count_zeros > AXLE_PIX_MIN)
		num = num + 1; # found axle at the beginning
		count_zeros = 0;
		n = n + WINDOW;
		count_zeros = numel(find(bottom_edge(1, n - WINDOW + 1:n) == 0));
		disp('found axle')
		continue;
	end	
	if(bottom_edge(n) == 0)
		count_zeros = count_zeros + 1;
	end
	if((bottom_edge(n-WINDOW) == 0) && (count_zeros > 0))
		count_zeros = count_zeros - 1;
	end

end


##blur
#blur = 2
#for m = 2:4
#	for n = 2 : width - 1
#		if(image_matrix(height - 4 + m, n) ~= 0)
#			if blur > 0
#				#blur up
#				track(m - 1, n ) = 1;
#			end
#			if blur > 1
#				#blur right
#				track(m, n + 1) = 1;
#			end
#			if blur > 2
#				#blur left
#				track(m, n - 1) = 1;
#			end
#		end
#	end
#end
#figure
#imshow(track)


end
