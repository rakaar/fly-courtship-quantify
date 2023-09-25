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

% sample c
% x1 = 9;
% y1 = 161;
% x2 = 281;
% y2 = 161;

% sample_b
x1 = 47; y1 = 160; x2 = 316; y2 = 160;

% SAMPLE
% x1 = 6; y1 = 149; x2 = 280; y2 = 149;
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

frames_to_see = 3;

num_of_flies_over_time = [];
files = dir('all_frames/*.png');
img = imread(strcat('all_frames/', files(1).name));

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
        % error(['No FLIES detected ' file.name ]) 
        frame_zero_counter = frame_zero_counter + 1;   
        disp('++++++++++++++++00000000000000000000000000000++++++++++++++++++++===')
        fly_1_coords_over_time = [fly_1_coords_over_time; fly_1_coords_over_time(end,:)];
        fly_2_coords_over_time = [fly_2_coords_over_time; fly_2_coords_over_time(end,:)];
        dist_over_time = [dist_over_time dist_over_time(end)];

    end % if

    counter = counter + 1;
    
end % file


% calculate intersection of 2 vectors and angle between them
disp('#################### Calculating angle between 2 vectors and intersection of 2 vectors ####################')
counter = 0;
for f = 1:3:length(files')-3
    file = files(f);

   
        disp(['Processing file ' file.name ' Counter = ' num2str(counter)])
        
            % vectors
            % Calculate the dx and dy for both flies
            dx1 = fly_1_coords_over_time(f+frames_to_see-1,1) - fly_1_coords_over_time(f,1);
            dy1 = fly_1_coords_over_time(f+frames_to_see-1,2) - fly_1_coords_over_time(f,2);

            dx2 = fly_2_coords_over_time(f+frames_to_see-1,1) - fly_2_coords_over_time(f,1);
            dy2 = fly_2_coords_over_time(f+frames_to_see-1,2) - fly_2_coords_over_time(f,2);

            
            % -----------1. Angle between them is acute,  dot product is positive
            % Calculate dot product
            dotProduct = dx1 * dx2 + dy1 * dy2;

            % Calculate magnitudes
            mag1 = sqrt(dx1^2 + dy1^2);
            mag2 = sqrt(dx2^2 + dy2^2);

            % Find cosine of angle
            cosTheta = dotProduct / (mag1 * mag2); % positive for acute, negative for obtuse

            % -------------2. Intersection of 2 vectors ----------------------
            % Define the vectors and points
            P1 = [fly_1_coords_over_time(f+frames_to_see-1,1), fly_1_coords_over_time(f,2)];
            P2 = [fly_2_coords_over_time(f+frames_to_see-1,1), fly_2_coords_over_time(f,2)];

            v1 = [dx1, dy1];
            v2 = [dx2, dy2];

            % Determine intersection
            A = [v1', -v2'];
            b = P2 - P1;
            
            is_intersecting = 0;
            if rank(A) < 2
                disp('Lines are parallel or coincident.');
            else
                ts = A\b';
                
                % t and s are ts(1) and ts(2) respectively
                if 0 <= ts(1) && ts(1) <= 1 && 0 <= ts(2) && ts(2) <= 1
                    is_intersecting = 1;
                    % intersectionPoint = P1 + ts(1) * v1;
                    % disp(['The lines intersect at point (', num2str(intersectionPoint(1)), ', ', num2str(intersectionPoint(2)), ').']);
                end
            end


            % --- Check both above conditions---
            cos_theta_over_time = [cos_theta_over_time cosTheta];
            is_intersecting_over_time = [is_intersecting_over_time is_intersecting];
         
end

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







