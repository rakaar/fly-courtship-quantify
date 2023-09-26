clear;close all;

disp('########### Identify flies and mark their positions###########')
read_all_images_and_identify_flies;

disp(' ########### Mark courtship Frames ###########')
mark_courtship_all1algo;

disp(' ########## Make Video ##########')
make_video_of_courtship_and_non_courtship;