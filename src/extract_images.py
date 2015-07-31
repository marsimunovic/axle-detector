#!/usr/bin/python
import sys
import shutil
import os

if __name__ == '__main__':
	assert (len(sys.argv) == 4), "Wrong input argument number!!!"
	file_list = sys.argv[1]
	plot_dir = sys.argv[2]
	dest = sys.argv[3]
	with open(file_list, "r") as myfile:
		for line in myfile:
			src = line.rstrip('\r\n')
			path_split = src.split(os.sep)[-1]
			plot_dest = dest + os.sep + (path_split.split('.gif'))[0] + '_.gif'
			shutil.copy2(src, dest)
			shutil.copy2(plot_dir + os.sep + path_split, plot_dest)