clc;close all;clear;




% ffmpeg -i ../sample_c.avi frame_%04d.png  
% 
% x1 =  15;  
% y1 =  172;
% x2 =  283;
% y2 = 186;

% x1 = 14;
% y1 = 175;
% x2 = 310;
% y2 = 179;
files = dir('all_frames/*.png');
img = imread(strcat('all_frames/', files(1).name));

% calculate mid point
% Load the image (replace this with your actual image loading code)
% Example: img = imread('your_image.png');

% Convert to grayscale if the image is RGB
if size(img, 3) == 3
    img = rgb2gray(img);
end

% Convert to binary image if not already (optional: you might need to adjust the threshold)
bw_img = imbinarize(img, 0.5);  % 0.5 is the threshold, adjust as necessary

% Get the image size
[rows, cols] = size(bw_img);

% Find the middle row
mid_row = round(rows / 2);

% Get the non-zero elements in the middle row
non_zero_cols = find(bw_img(mid_row, :));

% Check if there are non-zero elements
if ~isempty(non_zero_cols)
    % Find left and right midpoints
    left_midpoint = [mid_row, non_zero_cols(1)];
    right_midpoint = [mid_row, non_zero_cols(end)];
else
    error('No non-zero elements found in the middle row. Adjust the threshold or check the image.');
end

% Display the results
disp(['Left midpoint: ', mat2str(left_midpoint)]);
disp(['Right midpoint: ', mat2str(right_midpoint)]);

x1 = left_midpoint(1); y1 = left_midpoint(2); x2 = right_midpoint(1); y2 = right_midpoint(2);

% SAMPLE D
% x1 = 5; y1 = 161; x2 = 281; y2 = 161;
% sample c
% x1 = 13; y1 = 182; x2 = 288; y2 = 182;

% sample_b
% x1 = 37; y1 = 185; x2 = 316; y2 = 185;

% Define the coordinates of the circle's center
x_center = (x1 + x2) / 2;
y_center = (y1 + y2) / 2;

% Calculate the radius of the circle
radius = sqrt((x2 - x1)^2 + (y2 - y1)^2) / 2;

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
cos_theta_over_time = [];
is_intersecting_over_time = [];

% Load all params - step size and window size
all_params;

num_of_flies_over_time = [];


frame_zero_counter = 0;
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
    cc = bwconncomp(uint8(flies_logical).*mask);  % 'binaryImage' is the thresholded image
    stats = regionprops(cc, 'Area', 'Centroid', 'BoundingBox');
    
    % get fly indices based on area of blobs
    fly_indices  = [];
    for i = 1:length(stats)
        if 100*(stats(i).Area/circle_area) > fly_min_area_percent && 100*(stats(i).Area/circle_area) < fly_max_area_percet
            fly_indices = [fly_indices i];
        end
    end
    
    % if More than 2 flies are detected, choose the ones with biggest area, the smallest may be due to noise
    if length(fly_indices)  > 2
        max_area1 = -1;
        max_area2 = -1;
        max_area1_ind = 0;
        max_area2_ind = 0;
        for f_ind = 1:length(fly_indices)
            if stats(fly_indices(f_ind)).Area > max_area1
                % Update max_area2 with old max_area1 before updating max_area1
                max_area2 = max_area1;
                max_area2_ind = max_area1_ind;

                % Now update max_area1
                max_area1 = stats(fly_indices(f_ind)).Area;
                max_area1_ind = fly_indices(f_ind);
            elseif stats(fly_indices(f_ind)).Area > max_area2
                max_area2 = stats(fly_indices(f_ind)).Area;
                max_area2_ind = fly_indices(f_ind);
            end
        end % for
        
        fly_indices = [max_area1_ind max_area2_ind];
    end % if
    % TODO - Clean code, because now number of flies is atmost 2

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
    elseif length(fly_indices) > 2
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
       
    else
        error(['No FLIES detected ' file.name ]) 
        frame_zero_counter = frame_zero_counter + 1;   
        disp('++++++++++++++++00000000000000000000000000000++++++++++++++++++++===')
        fly_1_coords_over_time = [fly_1_coords_over_time; fly_1_coords_over_time(end,:)];
        fly_2_coords_over_time = [fly_2_coords_over_time; fly_2_coords_over_time(end,:)];
        dist_over_time = [dist_over_time dist_over_time(end)];

    end % if

    counter = counter + 1;
    
end % file


% ----- A figure to just visualize
% frames_to_see_for_coords = 1:15;
% figure
% subplot(1,2,1)
% % Plot the paths
% plot(fly_1_coords_over_time(frames_to_see_for_coords,1), fly_1_coords_over_time(frames_to_see_for_coords,2))
% hold on
%     plot(fly_2_coords_over_time(frames_to_see_for_coords,1), fly_2_coords_over_time(frames_to_see_for_coords,2));

%     % Plot the starting points of fly 1 and fly 2
%     plot(fly_1_coords_over_time(frames_to_see_for_coords(1),1), fly_1_coords_over_time(frames_to_see_for_coords(1),2), 'ro', 'MarkerSize', 10, 'DisplayName', 'Fly 1 Start');
%     plot(fly_2_coords_over_time(frames_to_see_for_coords(1),1), fly_2_coords_over_time(frames_to_see_for_coords(1),2), 'bo', 'MarkerSize', 10, 'DisplayName', 'Fly 2 Start');
% hold off
% title('Coordinates of flies over time')

% subplot(1,2,2)
% plot(dist_over_time(frames_to_see_for_coords))
% title('dist over time')

save('dist_over_time.mat', 'dist_over_time')
save('fly_1_coords_over_time.mat', 'fly_1_coords_over_time')
save('fly_2_coords_over_time.mat', 'fly_2_coords_over_time')
save('frames_to_see', 'frames_to_see')
save('cos_theta_over_time', 'cos_theta_over_time')
save('is_intersecting_over_time', 'is_intersecting_over_time')







