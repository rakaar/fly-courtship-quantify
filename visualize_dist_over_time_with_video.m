clear;clc;close all;

dist_over_time = load('dist_over_time').dist_over_time;
files = dir('all_frames/*.png');
counter = 0;

for file = files'

    if mod(counter, 15) == 0

        disp(['Processing file ' file.name])
        % read image
        img = imread(strcat('all_frames/', file.name));

        % dist over time copy
        subplot(1,2,1)
        % bar(1:counter,dist_over_time(1:counter))
        bar(counter+1:counter+15,dist_over_time(counter+1:counter+15))
        
        title([ 'distance over time - counter ' num2str(counter) ' to ' num2str(counter+15) ])

        subplot(1,2,2)
        imshow(img)
        title([ 'frame ' file.name])

        pause
        clf;
        
    end
    
    counter = counter + 1;
end