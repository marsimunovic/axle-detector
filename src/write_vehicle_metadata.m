function [success] = write_vehicle_metadata(img_name, axle_data)
	%%
	%%
	global OUTPUT_FILE_PATH;
	persistent output_file = 'axle_data.xlsx';
	persistent row = 2;
	if row == 2
		#new file
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
	#xlswrite(OUTPUT_FILE_PATH, img_name, sheet, firstCell);
	xlswrite(OUTPUT_FILE_PATH, entry, sheet, xlRange);


	row = row+1;
end
