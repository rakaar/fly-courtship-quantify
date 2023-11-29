
% Save output folder
output_folder = '/home/rka/code/fly_courtship/all_frames'; save('output_folder', 'output_folder');

% Save video path taken from input_video_path
video_path = input_video_path; save('video_path', 'video_path');

% ffmpeg command
output_frames_path = fullfile(output_folder, 'frame_%04d.png');
ffmpeg_command_format = 'LD_LIBRARY_PATH="" ffmpeg -i %s %s';
ffmpeg_command = sprintf(ffmpeg_command_format, input_video_path, output_frames_path);

% TODO - IMP - REMOVE THIS COMMMENT LATER
% [status, cmdout] = system(ffmpeg_command);
if status == 0
    disp('Frames extracted successfully.');
else
    disp('Error extracting frames.');
    disp(cmdout);  % Display the error message
end

% Convert to grayscale if the image is RGB
files = dir([output_folder '/*.png']);

img = imread(strcat(output_folder, '/', files(1).name));
if size(img, 3) == 3
    img = rgb2gray(img);
end

% Convert to binary image if not already (optional: you might need to adjust the threshold)
bw_img = imbinarize(img, 0.5);  % 0.5 is the threshold, adjust as necessary
[rows, cols] = size(bw_img);
mid_row = round(rows / 2);
non_zero_cols = find(bw_img(mid_row, :));

if ~isempty(non_zero_cols)
    % Find left and right midpoints
    left_midpoint = [mid_row, non_zero_cols(1)];
    right_midpoint = [mid_row, non_zero_cols(end)];
else
    error('No non-zero elements found in the middle row. Adjust the threshold or check the image.');
end

disp(['Left midpoint: ', mat2str(left_midpoint)]);
disp(['Right midpoint: ', mat2str(right_midpoint)]);

x1 = left_midpoint(1); y1 = left_midpoint(2); x2 = right_midpoint(1); y2 = right_midpoint(2);

% circle's center
x_center = (x1 + x2) / 2;
y_center = (y1 + y2) / 2;

% Calculate the radius of the circle
radius = sqrt((x2 - x1)^2 + (y2 - y1)^2) / 2;
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
    img = imread(strcat(output_folder,'/', file.name));
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
        error(['No FLIES detected ' file.name ]) 
    end % if

    counter = counter + 1;
    
end % file

save('dist_over_time.mat', 'dist_over_time')
save('fly_1_coords_over_time.mat', 'fly_1_coords_over_time')
save('fly_2_coords_over_time.mat', 'fly_2_coords_over_time')
save('frames_to_see', 'frames_to_see')
save('cos_theta_over_time', 'cos_theta_over_time')
save('is_intersecting_over_time', 'is_intersecting_over_time')

disp('End of saving')





