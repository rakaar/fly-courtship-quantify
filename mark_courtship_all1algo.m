close all;clear;
dist_over_time = load('dist_over_time').dist_over_time;
fly_1_coords_over_time = load('fly_1_coords_over_time').fly_1_coords_over_time;
fly_2_coords_over_time = load('fly_2_coords_over_time').fly_2_coords_over_time;

is_intersecting_over_time = load('is_intersecting_over_time').is_intersecting_over_time;
cos_theta_over_time = load('cos_theta_over_time').cos_theta_over_time;

% ---------------- just checking sg filter ------------------------
% order = 3;
% frame_len = 11;
% sg_dist_over_time = sgolayfilt(dist_over_time,order,frame_len);

% figure
%     plot(dist_over_time, 'b', 'LineWidth', 2)
%     hold on
%     plot(sgolayfilt(dist_over_time,3,11), 'LineWidth', 2)
%     plot(sgolayfilt(dist_over_time,3,15), 'LineWidth', 2)
%     hold off
%     % legend('Original Signal','Filtered Signal')


% --------------- just checking derivative ------------------------
frame_len_for_sg_filter = 15;
% smooth_dist = sgolayfilt(dist_over_time,3,frame_len_for_sg_filter);
smooth_dist = dist_over_time;
% d_smooth_dist = diff(smooth_dist);
% figure
%     plot(smooth_dist, 'b', 'LineWidth', 2)
%     hold on
%     plot(d_smooth_dist, 'r', 'LineWidth', 2)
%     hold off
%     legend('Smoothed Signal','Derivative of Smoothed Signal')
%     title('Just see derivative')


% Assuming smooth_dist is already defined
% This comes from read_all_images_and_identify_flies.m
window_length = load('frames_to_see').frames_to_see;
step_size = 3;
num_points = length(smooth_dist);

% Determine the number of windows
num_windows = floor((num_points - window_length) / step_size) + 1;


mark_courtship = zeros(length(smooth_dist),1);
mark_courtship_zero_dist_max = zeros(length(smooth_dist),1);

% -- Raw way, just checking the slope of line fit to each window --
% for k = 1:num_windows
%     % Define start and end indices for the current window
%     start_idx = 1 + (k-1)*step_size;
%     end_idx = start_idx + window_length - 1;

%     % Extract data for the current window
%     window_data = smooth_dist(start_idx:end_idx);

%     % Fit a line (1st order polynomial) to the window data
%     [p,~] = polyfit(1:length(window_data), window_data, 1);
    
%     % The slope of the line is the first coefficient
%     slopes(k) = p(1);
%     if p(1) < 0 
%         mark_courtship(start_idx:end_idx) = 1;
%     end
% end
% --- End of raw way ---

% -- Using stats to check if fit is signficant ----
all_similarities = [];
alpha = 0.01; % significance level
for k = 1:num_windows
    
    % Define start and end indices for the current window
    start_idx = 1 + (k-1)*step_size;
    end_idx = start_idx + window_length - 1;

    if cos_theta_over_time(k) > 0 && is_intersecting_over_time(k) == 1
        mark_courtship(start_idx:end_idx) = 1;
    elseif sum(dist_over_time(start_idx:end_idx) < 50) >= round(window_length/2) 
        mark_courtship(start_idx:end_idx) = 1;
        mark_courtship_zero_dist_max(start_idx:end_idx) = 1;
    end

end

disp(['frame of courtsip ' num2str(0.2*sum(mark_courtship)) ' Index = ' num2str(0.2*sum(mark_courtship)/600) ' for sg filter len ' num2str(frame_len_for_sg_filter)])
% Now, 'slopes' contains the slope of the line fit to each window

figure;
plot(smooth_dist, '-');    % Plot the smooth line
hold on;                   % Hold the plot to overlay the next elements
indices = find(mark_courtship == 0);       % Find the indices where mark_courtship is 1
plot(indices, smooth_dist(indices), '*');  % Mark '*' at those points
xlabel('X-axis label');
ylabel('Y-axis label');
title('Smooth Dist with Courtship Marks');
legend('Smooth Dist', 'Courtship Marks');

save('mark_courtship', 'mark_courtship')
save('mark_courtship_zero_dist_max', 'mark_courtship_zero_dist_max')
