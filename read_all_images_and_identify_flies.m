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
num_of_flies_over_time = [];
files = dir('all_frames/*.png');
img = imread(strcat('all_frames/', files(1).name));

% Now make a mask out of cirle, basically ones inside circle, zeros outside circle
[columnsInImage, rowsInImage] = meshgrid(1:size(img, 2), 1:size(img, 1));
circlePixels = (rowsInImage - y_center).^2 + (columnsInImage - x_center).^2 <= radius.^2;
mask = uint8(circlePixels);

% iterate through all png files in "all_frames" folder

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

        dist = pdist(fly_coords);
       
        dist_over_time = [dist_over_time dist];

    elseif length(fly_indices) == 1
            dist_over_time = [dist_over_time 0];
    else
        all_fly_coords = zeros(length(fly_indices), 2);
        for f = 1:length(fly_indices)
            all_fly_coords(f,:) = stats(fly_indices(f)).Centroid;
        end

       all_possible_dist = [];
       for f1 = 1:length(all_fly_coords)-1
           for f2 = f1+1:length(all_fly_coords)
               all_possible_dist = [all_possible_dist pdist([all_fly_coords(f1,:); all_fly_coords(f2,:)])];
           end
        end

        dist_over_time = [dist_over_time max(all_possible_dist)];

    end % if
    
end % file











