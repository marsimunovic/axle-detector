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
%%  tyre_area - area of detected tyre (only lower half)
%%  ratio - ratio of tyre_area and ellipse area where
%%  ra and rb are semi-major and semi-minor axes
%%  rel_pos - position of axle in relation to vehicle
%%  lenght given in percentage units

	global OUTPUT_FILE_PATH;
	persistent output_file = '../reports/report.xlsx';
  if exist('../reports', 'dir') ~= 7
    mkdir('../reports');
  end
	persistent row = 2;
  
  if(size(axle_data, 1) == 0)
    return;
  end
     
	if row == 2
		%%new file
    
	end
  xls = xlsopen(output_file, 1); %open with RW access
	sheet = 'Sheet1';
	num_axles = size(axle_data, 1);
  offset = 64; %ascii value before first column
  

  rowStr = num2str(row);
  rowStrEnd = num2str(row+num_axles-1);
  firstCell  = strcat(char(offset+1), rowStr);
	secondCell = strcat(char(offset+2), rowStr);
  startCell  = strcat(char(offset+3), rowStr);
  endCell    = strcat(char(offset+3+size(axle_data,2)-1), rowStrEnd);
  xlRange    = strcat(startCell, ':', endCell);
  
  xls = oct2xls(cellstr(img_name), xls, 'Sheet1', firstCell);
  xls = oct2xls(num_axles, xls,'Sheet1', secondCell);
  xls = oct2xls(axle_data, xls, 'Sheet1', xlRange);
  
  %xlswrite(output_file, cellstr(img_name), 'Sheet1', firstCell);
  %xlswrite(output_file, num_axles, 'Sheet1', secondCell);
  %xlswrite(output_file, axle_data, 'Sheet1', xlRange);
        
  row = row + num_axles;
  xlsclose(xls)
end
