% This is main file of axle-detection project
% it loads configuration environment
% and calls appropriate functions accordingly

%Remove zombie items
close all
clear all
clc

disp("Initalizing environment...")
%enable instant printing and printing to file support
more off
graphics_toolkit("gnuplot")

%Load package prerequisites
pkg load io 		%enables writing statistics files (.xls)
pkg load image  	%enable operation on image files
pkg load signal 	%signal processing functionality
pkg load geometry	%enables plotting geometrical shapes (e.g. ellipse)

% setup environment %
warning("off", "Octave:GraphicsMagic-Quantum-Depth");

% INPUT ARGUMENTS
% image_dir - top directory with vehicle profile images
% output_dir - top directory for output files (reports, images, etc.)
% output_subdir1 - directory for plots withcd  detected axles

top_dir_name = '710000_images';

image_dir = strcat('..', filesep(), top_dir_name);
%create output dirs and subdirs if not existing
output_dir = strcat('..', filesep(), 'reports');
if (exist(output_dir, 'dir') ~= 7)
	mkdir(output_dir);
end
output_subdir1 = strcat(output_dir, filesep(), 'plotting', filesep(), top_dir_name);
if (exist(output_subdir1, 'dir') ~= 7)
	mkdir(output_subdir1);
end
output_subdir2 = strcat(output_dir, filesep(), 'selected', filesep(), top_dir_name);
if (exist(output_subdir2, 'dir') ~= 7)
	mkdir(output_subdir2);
end

output_xlsx = strcat(output_dir, filesep(), top_dir_name, '.xlsx');
if (exist(output_xlsx, 'file') == 2)
	delete(output_xlsx);
end
output_selected = strcat(output_dir, filesep, top_dir_name, '_sel', '.txt');

% GLOBAL VARIABLES

global DEBUG_ACTIVE = 0;
global DEBUG_LEVEL = 0;
global DEBUG_COUNT_IMAGES = 1;
global LOWER_PART = 80; %determines how many lower pixels of vehicle image will be used

 

%get image list
disp("Loading files. This might take a while...");


image_list = getAllFiles(image_dir);
image_count = size(image_list, 1);

printf("Loaded %d images\n\n", image_count);

if image_count == 0
  return;
end

xls = xlsopen(output_xlsx, 1); %open with RW access
txt_list = fopen(output_selected, 'w');
%% for each image in list perform workflow

for img_ind = 1 : image_count
	if DEBUG_ACTIVE
		#open image
		if img_ind > DEBUG_COUNT_IMAGES
			break;
		end
	end
	printf("Image %s\n", image_list{img_ind});
	

	% first LOAD image to matrix
	[Xorig, Xbin] = getImageMatrix(image_list{img_ind});
	
	% CROP unnecessary part of the image
	Xcrop = cropImage(Xbin);

	% detect vehicle CONTOUR
	bottom_edge = detect_edge(Xcrop);

	% find AXLE CANDIDATES
	[axle_bottom, axle_sides] = find_axle_candidates(bottom_edge, image_list{img_ind});

	if numel(axle_bottom) < 1 || numel(axle_sides) < 2
		continue;
	end
	% DETECT lifted axles 
	fname = strsplit(image_list{img_ind}, filesep());
	fname = fname {end};
	plot_output_path = strcat(output_subdir1, filesep(), fname);
	[axle_data] = detect_axle(bottom_edge, axle_bottom, axle_sides, plot_output_path);

	% FINALIZE
	if size(axle_data, 1) > 0
		fprintf(txt_list, "%s\n", image_list{img_ind});
	end
	xls = write_vehicle_metadata(fname, axle_data, xls);

end	
xlsclose(xls);
fclose(txt_list);

python_command = cstrcat("python extract_images.py", " ", output_selected, " ", ...
					    	output_subdir1, " ", output_subdir2);
ot = system(python_command, 1);

%%  HOUGH TRANSFOR CODE : DEPRECATED
%%  BLUR_LEVEL = 3; # 0 - no blur, 1 - blur up, 
%%  2 - blur up and left, 3 - blur up, left and right
%%	RADII = [40 80];
%%	image_matrix = signal2image(bottom_edge, BLUR_LEVEL);
%%	# analys bottom contour
%%	[accumul, accumul_bin] = accumulator(image_matrix, RADII);
%%	#disp('analys accumul')
%%	#[max_matrix, max_matrix_bin] = rect_area_max(accumul);
%%
%%	overlap = accumul_bin & image_matrix;
%%		#print -dgif image_list{img_ind}
%%
%%	dest = strcat(output_dir, filesep(), fname);
%%	imwrite(overlap, dest);