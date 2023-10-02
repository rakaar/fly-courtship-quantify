close all;clear;
dist_over_time = load('dist_over_time').dist_over_time;
fly_1_coords_over_time = load('fly_1_coords_over_time').fly_1_coords_over_time;
fly_2_coords_over_time = load('fly_2_coords_over_time').fly_2_coords_over_time;

is_intersecting_over_time = load('is_intersecting_over_time').is_intersecting_over_time;
cos_theta_over_time = load('cos_theta_over_time').cos_theta_over_time;



% --------------- just checking derivative ------------------------
smooth_dist = dist_over_time;

% Run all_params to get "frames_to_see" and "step_size"
all_params;
window_length = frames_to_see;

num_points = length(smooth_dist);

% Determine the number of windows
num_windows = floor((num_points - window_length) / step_size) + 1;



mark_courtship = zeros(length(smooth_dist),1);
mark_courtship_zero_dist_max = zeros(length(smooth_dist),1);

% -- Using stats to check if fit is signficant ----
all_similarities = [];
thresold_pixel_distance = 50;
alpha = 0.01; % significance level
for k = 1:num_windows
    
    % Define start and end indices for the current window
    start_idx = 1 + (k-1)*step_size;
    end_idx = start_idx + window_length - 1;

    if cos_theta_over_time(k) > 0 && is_intersecting_over_time(k) == 1
        mark_courtship(start_idx:end_idx) = 1;
    elseif sum(dist_over_time(start_idx:end_idx) < thresold_pixel_distance) == round(window_length) 
    % elseif sum(dist_over_time(start_idx:end_idx) < thresold_pixel_distance) >= round(window_length/2) 

        mark_courtship(start_idx:end_idx) = 1;
        mark_courtship_zero_dist_max(start_idx:end_idx) = 1;
    end

end

% less than threshold pixels for 15 seconds, then remove courtship
window_length = window_limit_for_dist_condition; % 15/10 seconds, each second is 5 frames
num_windows = floor((num_points - window_length) / step_size) + 1;
for k = 1:num_windows
    
    % Define start and end indices for the current window
    start_idx = 1 + (k-1)*step_size;
    end_idx = start_idx + window_length - 1;

    if sum(mark_courtship_zero_dist_max(start_idx:end_idx)) == window_length
        % disp(['k for testin ' num2str(k)])
        fly_1_dx = diff(fly_1_coords_over_time(start_idx:end_idx,1));
        fly_2_dx = diff(fly_2_coords_over_time(start_idx:end_idx,1));

        if sum(fly_1_dx < 1) == length(fly_1_dx) && sum(fly_2_dx < 1) == length(fly_2_dx)
            disp('))))))))))))))))) REMOVED COURTSHIP ((((((((((((((((((()))))))))))))))))))')
            mark_courtship(start_idx:end_idx) = 0;
            mark_courtship_zero_dist_max(start_idx:end_idx) = 0;
        end
    end

end

disp(['frame of courtsip ' num2str(0.2*sum(mark_courtship)) ' Index = ' num2str(0.2*sum(mark_courtship)/600) ])

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
