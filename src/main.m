# this is main file of axle-detection project
# it loads configuration environment
# and calls appropriate functions accordingly

#Remove zombie items
close all
clear all
clc
#enable instant printing
more off

#Load packages
pkg load image
pkg load signal


#INPUT ARGUMENTS
image_dir = '../axle_images/';
output_dir = '../processed/';
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
	printf("Image %s\n", image_list{img_ind});
	fname = strsplit(image_list{img_ind}, '/');
	
	[Xorig, Xbin] = getImageMatrix(image_list{img_ind});
	# crop unnecessary parts
	Xcrop = cropImage(Xbin);
	# detect bottom contour
	bottom_edge = detect_edge(Xcrop);
	
	#convert 1D bottom contour to image
	#bottom_edge = han_filter(bottom_edge);
	image_matrix = signal2image(bottom_edge, BLUR_LEVEL);
	# analys bottom contour
	accumul = accumulator(image_matrix, RADII);
	overlap = accumul & image_matrix;
	#print -dgif image_list{img_ind}

	dest = strcat(output_dir, fname{end});
	imwrite(overlap, dest);
    #pause(1)
	continue;

	f = figure;
	set(f, "visible", "off")
	plot(y)
	print("MyPNG.png", "-dpng")

    break;
	

	# perform detection

	# write results to file

end

# for each image in list perform whole workflow



