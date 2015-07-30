function [success] = write_vehicle_metadata(img_name, axle_data)
%% img_name - string with file name
%% axle_data - array containing following elements which
%% describe axle (cx, cy, ra, rb, min_point, left_edge, right_edge
%% tyre_area, ratio, rel_pos)
%% success - write status

%% 	AXLE PROPERTIES
%% 	cx - x coordinate of axle center
%%  cy - y coordinate of axle center
%%	ra - horizontal tyre radius
%%  rb - vertical tyre radius 
%%  min_point - distance from bottom to tyre
%%  left_edge - detected left edge height
%%  right_edge - detected right edge height
%%  

	global OUTPUT_FILE_PATH;
	persistent output_file = 'axle_data.xlsx';
	persistent row = 2;
	if row == 2
		%%new file

	end

	sheet = 1;
	entry = [num_axles axle_data position];
	N = numel(entry);
	rowStr = num2str(row);
	firstCell = strcat('A', rowStr);
	secondCell = 
	startCell = strcat('C', rowStr, ':');
	cell_pos = 66 + N;
	endCell   = strcat(char(cell_pos), rowStr);
	xlRange = strcat(startCell, endCell)
	#xlswrite(output_file, img_name, sheet, firstCell);
	xlswrite(output_file, entry, sheet, xlRange);


	row = row+1;
end
