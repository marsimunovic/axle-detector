function [xls_fptr] = write_vehicle_metadata(img_name, axle_data, xls)
%% img_name - string with file name
%% axle_data - array containing following elements which
%% describe axle (cx, cy, ra, rb, min_point, left_edge, right_edge
%% tyre_area, drop, rel_pos)
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
%%  drop - biggest local change in edge
%%  ra and rb are semi-major and semi-minor axes
%%  rel_pos - position of axle in relation to vehicle
%%  lenght given in percentage units

	global OUTPUT_FILE_PATH;
	persistent row = 3;
  xls_fptr = xls;
  num_axles = size(axle_data, 1);
  data_size = size(axle_data, 2);
  if num_axles == 0
    return;
  end
     


	sheet = 'Sheet1';
	offset = 64; %ascii value before first column
  if row == 3
    %%new file
    col_names = {'Name', 'AxlCnt', 'CX', 'CY', 'RA', 'RB', ...
                'MinPoint', 'Left', 'Right', 'Ratio', 'VehicleLen'};
    assert((numel(col_names) == (data_size + 2))); %if something is wrong
    xlRange = strcat(char(offset+1),'1',':',char(offset+numel(col_names)),'1');
    xls = oct2xls(cellstr(col_names), xls, sheet,  xlRange);            
	end
 
  

  rowStr = num2str(row);
  rowStrEnd = num2str(row+num_axles-1);
  firstCell  = strcat(char(offset+1), rowStr);
	secondCell = strcat(char(offset+2), rowStr);
  startCell  = strcat(char(offset+3), rowStr);
  endCell    = strcat(char(offset+3+data_size-1), rowStrEnd);
  xlRange    = strcat(startCell, ':', endCell);
  
  xls = oct2xls(cellstr(img_name), xls, sheet, firstCell);
  xls = oct2xls(num_axles, xls, sheet, secondCell);
  xls = oct2xls(axle_data, xls, sheet, xlRange);
  
  %xlswrite(output_file, cellstr(img_name), 'Sheet1', firstCell);
  %xlswrite(output_file, num_axles, 'Sheet1', secondCell);
  %xlswrite(output_file, axle_data, 'Sheet1', xlRange);
        
  row = row + num_axles;
  %xlsclose(xls);
  xls_fptr = xls;
end
