clear;clc;close all;

dist_over_time = load('dist_over_time').dist_over_time;
fly_1_coords_over_time = load('fly_1_coords_over_time').fly_1_coords_over_time;
fly_2_coords_over_time = load('fly_2_coords_over_time').fly_2_coords_over_time;

files = dir('all_frames/*.png');
counter = 0;

for file = files'
    counter = counter + 1; % if one by one

    % if mod(counter, 15) == 0

        disp(['Processing file ' file.name])
        % read image
        img = imread(strcat('all_frames/', file.name));

        % dist over time copy
        subplot(1,2,1)
        bar(1:counter,dist_over_time(1:counter)) % frame by frame
        % bar(counter+1:counter+15,dist_over_time(counter+1:counter+15)) % 15 frames at once    
        
        title([ 'distance over time - counter ' num2str(counter) ' to ' num2str(counter+15) ])

        subplot(1,2,2)
        imshow(img)
        hold on
        % Coordinates for the two flies at time counter+1
        coords_fly1 = fly_1_coords_over_time(counter,:);
        coords_fly2 = fly_2_coords_over_time(counter,:);

        % Marking the coordinates with text
        text(coords_fly1(1), coords_fly1(2), '1', 'Color', 'r', 'FontSize', 20, 'FontWeight', 'bold');
        text(coords_fly2(1), coords_fly2(2), '2', 'Color', 'b', 'FontSize', 20, 'FontWeight', 'bold');
        hold off

        title([ 'frame ' file.name])

        pause
        clf;
        
    % end
    
    
end