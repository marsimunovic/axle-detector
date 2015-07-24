# this is main file of axle-detection project
# it loads configuration environment
# and calls appropriate functions accordingly

#Remove zombie items
close all
clear all
clc
#Load packages
pkg load image
pkg load signal


#INPUT ARGUMENTS
image_dir = '../axle_images/';


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
	[Xorig, Xbin] = getImageMatrix(image_list{img_ind});
	# crop unnecessary parts
	Xcrop = cropImage(Xbin);
	# filter bottom contour
	bottom_edge = detect_edge(Xcrop);
	break;
	# analys bottom contour

	# perform detection

	# write results to file

end

# for each image in list perform whole workflow



