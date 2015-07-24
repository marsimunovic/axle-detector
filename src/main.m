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
	printf("Image %s\n", image_list{img_ind});
	fname = strsplit(image_list{img_ind}, '/');
	
	[Xorig, Xbin] = getImageMatrix(image_list{img_ind});
	# crop unnecessary parts
	Xcrop = cropImage(Xbin);
	# filter bottom contour
	bottom_edge = detect_edge(Xcrop);
	N = 20;
	n = 0:N-1;
	b = 0.5*(1 - cos(2*pi*n/(N-1)));
	a = sum(b);
	b = b/a;
	a = 1;
	y = filter(b,a, bottom_edge);
	#figure
	#plot(y)
	#print -dgif image_list{img_ind}
	image_matrix = signal2image(bottom_edge);
	imwrite(image_matrix, fname{end});
    pause(1)
	continue;

	f = figure;
	set(f, "visible", "off")
	plot(y)
	print("MyPNG.png", "-dpng")

    break;
	# analys bottom contour

	# perform detection

	# write results to file

end

# for each image in list perform whole workflow



