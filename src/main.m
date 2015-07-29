# this is main file of axle-detection project
# it loads configuration environment
# and calls appropriate functions accordingly

#Remove zombie items
close all
clear all
clc
#enable instant printing
more off
#enable printing to file support
graphics_toolkit("gnuplot")

#Load packages
pkg load image
pkg load signal
pkg load geometry


#INPUT ARGUMENTS
#image_dir = '../axle_images/';
image_dir = '../i250_images/';
output_dir = '../processed_images/';
output_dir2 = '../filtered_images/';
global LOWER_PART = 100;
BLUR_LEVEL = 3; # 0 - no blur, 1 - blur up, 2 - blur up and left, 3 - blur up, left and right
RADII = [40 80];

# load configuration environment

# get image list
disp("Loading files. This might take a while...\n");
pause(1);
# TODO: implement search with file extension filter

image_list = getAllFiles(image_dir);

sz = size(image_list);
printf("Loaded %d images\n", sz(1));

for img_ind = 1 : sz(1)
	# open image
	#if img_ind > 1
	#	break
	#end
	printf("Image %s\n", image_list{img_ind});
	fname = strsplit(image_list{img_ind}, '/');
	
	[Xorig, Xbin] = getImageMatrix(image_list{img_ind});


	# crop unnecessary parts
	Xcrop = cropImage(Xbin);

	# detect bottom contour
	bottom_edge = detect_edge(Xcrop);
	#detect_axles(bottom_edge);
	dest = strcat(output_dir2, fname{end});
	han_filter(bottom_edge, 40, dest);
	
	#convert 1D bottom contour to image
	#bottom_edge = han_filter(bottom_edge);
	image_matrix = signal2image(bottom_edge, BLUR_LEVEL);
	# analys bottom contour
	[accumul, accumul_bin] = accumulator(image_matrix, RADII);
	#disp('analys accumul')
	#[max_matrix, max_matrix_bin] = rect_area_max(accumul);

	overlap = accumul_bin & image_matrix;
		#print -dgif image_list{img_ind}

	dest = strcat(output_dir, fname{end});
	imwrite(overlap, dest);
    #pause(1)
    
	continue;

	#f = figure;
	#set(f, "visible", "off")
	#plot(y)
	#print("MyPNG.png", "-dpng")

    break;
	

	# perform detection

	# write results to file

end

# for each image in list perform whole workflow



