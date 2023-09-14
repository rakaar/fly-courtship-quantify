clc;close all;clear;




% Define the coordinates of the circle's center
x_center = (182 + 180) / 2;
y_center = (302 + 26) / 2;

% Calculate the radius of the circle
radius = sqrt((182 - 180)^2 + (302 - 26)^2) / 2;

% Define the angle range for the circle
theta = linspace(0, 2*pi, 1000);

% Calculate the x and y coordinates of the circle
x = radius*cos(theta) + x_center;
y = radius*sin(theta) + y_center;

% basic params
circle_area = pi*(radius^2);
fly_min_area_percent = 0.01;
fly_max_area_percet = 2;
thresold_for_fly_color = 80;
dist_over_time = [];
fly_1_coords_over_time = [];
fly_2_coords_over_time = [];

num_of_flies_over_time = [];
files = dir('all_frames/*.png');
img = imread(strcat('all_frames/', files(1).name));

% Now make a mask out of cirle, basically ones inside circle, zeros outside circle
[columnsInImage, rowsInImage] = meshgrid(1:size(img, 2), 1:size(img, 1));
circlePixels = (rowsInImage - y_center).^2 + (columnsInImage - x_center).^2 <= radius.^2;
mask = uint8(circlePixels);

% iterate through all png files in "all_frames" folder
counter = 1;
for file = files'

    disp(['Processing file ' file.name])
    % read image
    img = imread(strcat('all_frames/', file.name));
    img1 = squeeze(mean(img,3));

    % apply mask
    maskedFly1 = uint8(img1) .* mask;

    % threshold for fly color
    flies_logical = maskedFly1 < thresold_for_fly_color;

    % images processing by matlab to identify blobs
    cc = bwconncomp(flies_logical);  % 'binaryImage' is the thresholded image
    stats = regionprops(cc, 'Area', 'Centroid', 'BoundingBox');
    
    % get fly indices based on area of blobs
    fly_indices  = [];
    for i = 1:length(stats)
        if 100*(stats(i).Area/circle_area) > fly_min_area_percent && 100*(stats(i).Area/circle_area) < fly_max_area_percet
            fly_indices = [fly_indices i];
        end
    end

    
    % ########################################
    % This code is to plot the case when detected flies are more than 2
    % ######################################## 
    % fly_coords = zeros(2,2);
    % if length(fly_indices) == 2
    %     fly_coords(1,:) = stats(fly_indices(1)).Centroid;
    %     fly_coords(2,:) = stats(fly_indices(2)).Centroid;

    %     dist = pdist(fly_coords);
    %     disp(dist)
    %     dist_over_time = [dist_over_time dist];
    %     % figure,
    %     % imagesc(maskedFly1);  % Replace 'yourImage' with your image matrix name
    %     % % Plot centroids
    %     % hold on;
    %     % plot(fly_coords(:,1), fly_coords(:,2), 'r*', 'MarkerSize', 10);
    %     % hold off

    % else
    %     disp(['Num of flies ' num2str(length(fly_indices))])
    %     all_fly_coords = zeros(length(fly_indices), 2);
    %     for f = 1:length(fly_indices)
    %         all_fly_coords(f,:) = stats(fly_indices(f)).Centroid;
    %     end

    %     imagesc(maskedFly1);  % Replace 'yourImage' with your image matrix name
    %     % Plot centroids
    %     hold on;
    %     plot(all_fly_coords(:,1), all_fly_coords(:,2), 'r*', 'MarkerSize', 10);
    %     hold off

    %     pause
    %     dist_over_time = [dist_over_time 0];
    %     close all;
    % end


    % if num of flies is 2, then calculate distance between them
    % if num of flies is 1, then distance is zero
    % if number of flies is > 2, take the distance that is maximum
    num_of_flies_over_time = [num_of_flies_over_time length(fly_indices)];
    if length(fly_indices) == 2

        fly_coords(1,:) = stats(fly_indices(1)).Centroid;
        fly_coords(2,:) = stats(fly_indices(2)).Centroid;

        % assumption that, first 2 frames are correct.
        
        if counter > 2
            new1_prev_1_vec = fly_coords(1,:) - fly_1_coords_over_time(counter-1,:);
            new2_prev_1_vec = fly_coords(2,:) - fly_1_coords_over_time(counter-1,:);
            
            old1_vec = fly_1_coords_over_time(counter-1,:) - fly_2_coords_over_time(counter-2,:);
            
            if dot(new1_prev_1_vec, old1_vec) > dot(new2_prev_1_vec, old1_vec)
                fly_1_coords_over_time = [fly_1_coords_over_time; fly_coords(1,:)];
                fly_2_coords_over_time = [fly_2_coords_over_time; fly_coords(2,:)];
            else
                fly_1_coords_over_time = [fly_1_coords_over_time; fly_coords(2,:)];
                fly_2_coords_over_time = [fly_2_coords_over_time; fly_coords(1,:)];
            end
        else
            fly_1_coords_over_time = [fly_1_coords_over_time; fly_coords(1,:)];
            fly_2_coords_over_time = [fly_2_coords_over_time; fly_coords(2,:)];
        end
        
        dist = pdist(fly_coords);
       
        dist_over_time = [dist_over_time dist];

    elseif length(fly_indices) == 1
            dist_over_time = [dist_over_time 0];
            fly_1_coords_over_time = [fly_1_coords_over_time; stats(fly_indices(1)).Centroid];
            fly_2_coords_over_time = [fly_2_coords_over_time; stats(fly_indices(1)).Centroid];
    else
        all_fly_coords = zeros(length(fly_indices), 2);
        dot_with_old1 = zeros(length(fly_indices), 1);
        dot_with_old2 = zeros(length(fly_indices), 1);

        old1_vec = fly_1_coords_over_time(counter-1,:) - fly_2_coords_over_time(counter-2,:);
        old2_vec = fly_2_coords_over_time(counter-1,:) - fly_2_coords_over_time(counter-2,:);

        for f = 1:length(fly_indices)
            all_fly_coords(f,:) = stats(fly_indices(f)).Centroid;
            if counter > 2
                dot_with_old1(f) = dot(old1_vec, all_fly_coords(f,:) - fly_1_coords_over_time(counter-1,:));
                dot_with_old2(f) = dot(old2_vec, all_fly_coords(f,:) - fly_2_coords_over_time(counter-1,:));
            end
        end

       [max_dot1_val, max_dot1_ind] = max(dot_with_old1);
        [max_dot2_val, max_dot2_ind] = max(dot_with_old2);

        fly_1_coords_over_time = [fly_1_coords_over_time; all_fly_coords(max_dot1_ind,:)];
        fly_2_coords_over_time = [fly_2_coords_over_time; all_fly_coords(max_dot2_ind,:)];

        dist_over_time = [dist_over_time pdist([all_fly_coords(max_dot1_ind,:); all_fly_coords(max_dot2_ind,:)])];
       
        

        
    end % if

    counter = counter + 1;
    
end % file


frames_to_see_for_coords = 1:15;

figure

subplot(1,2,1)
% Plot the paths
plot(fly_1_coords_over_time(frames_to_see_for_coords,1), fly_1_coords_over_time(frames_to_see_for_coords,2))
hold on
    plot(fly_2_coords_over_time(frames_to_see_for_coords,1), fly_2_coords_over_time(frames_to_see_for_coords,2));

    % Plot the starting points of fly 1 and fly 2
    plot(fly_1_coords_over_time(frames_to_see_for_coords(1),1), fly_1_coords_over_time(frames_to_see_for_coords(1),2), 'ro', 'MarkerSize', 10, 'DisplayName', 'Fly 1 Start');
    plot(fly_2_coords_over_time(frames_to_see_for_coords(1),1), fly_2_coords_over_time(frames_to_see_for_coords(1),2), 'bo', 'MarkerSize', 10, 'DisplayName', 'Fly 2 Start');
hold off
title('Coordinates of flies over time')

subplot(1,2,2)
plot(dist_over_time(frames_to_see_for_coords))
title('dist over time')

save('dist_over_time.mat', 'dist_over_time')
save('fly_1_coords_over_time.mat', 'fly_1_coords_over_time')
save('fly_2_coords_over_time.mat', 'fly_2_coords_over_time')









