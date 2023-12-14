function [courtship_index, courtship_frame_num, mark_courtship, mark_courtship_zero_dist_max] = courtship_algo(fly_1_coords_over_time, fly_2_coords_over_time, dist_over_time, output_folder, window_length, window_limit_for_dist_condition, step_size)
    % WINDOWS
    if strcmp(computer, 'GLNXA64')
        files = dir([output_folder '/*.png']);
    else
        files = dir([output_folder '\*.png']);
    end

mark_courtship = zeros(length(dist_over_time),1);
mark_courtship_zero_dist_max = zeros(length(dist_over_time),1);

thresold_pixel_distance = 50;
window_num = 0;
total_num_windows = length(1:step_size:length(files')-window_length);

progress_bar = waitbar(0,'Starting courtship algorithm - I...');
for f = 1:step_size:length(files')-window_length

    window_num = window_num + 1;
    waitbar(window_num/total_num_windows, progress_bar, sprintf('Find Courtship Frames: %d %%', floor(window_num/total_num_windows*100)));

    start_idx = 1 + (window_num - 1)*step_size;
    end_idx = start_idx + window_length - 1;

    % ---- 1. Dot Product ---------
    dx1 = fly_1_coords_over_time(f+window_length-1,1) - fly_1_coords_over_time(f,1);
    dy1 = fly_1_coords_over_time(f+window_length-1,2) - fly_1_coords_over_time(f,2);

    dx2 = fly_2_coords_over_time(f+window_length-1,1) - fly_2_coords_over_time(f,1);
    dy2 = fly_2_coords_over_time(f+window_length-1,2) - fly_2_coords_over_time(f,2);

    dotProduct = dx1 * dx2 + dy1 * dy2;

    mag1 = sqrt(dx1^2 + dy1^2);
    mag2 = sqrt(dx2^2 + dy2^2);

    cosTheta = dotProduct / (mag1 * mag2); % positive for acute, negative for obtuse

    % -------------2. Intersection of 2 vectors ----------------------
    % Define the vectors and points
    P1 = [fly_1_coords_over_time(f,1), fly_1_coords_over_time(f,2)];
    P2 = [fly_2_coords_over_time(f,1), fly_2_coords_over_time(f,2)];

    v1 = [dx1, dy1];
    v2 = [dx2, dy2];

    % Determine intersection
    A = [v1', -v2'];
    b = P2 - P1;
    
    is_intersecting = 0;
    % if rank(A) < 2
    %     disp('Lines are parallel or coincident.');
    % else
    if rank(A) >= 2
        ts = A\b';
        
        % t and s are ts(1) and ts(2) respectively
        if 0 <= ts(1) && ts(1) <= 1 && 0 <= ts(2) && ts(2) <= 1
            is_intersecting = 1;
            % intersectionPoint = P1 + ts(1) * v1;
            % disp(['The lines intersect at point (', num2str(intersectionPoint(1)), ', ', num2str(intersectionPoint(2)), ').']);
        end
    end


    if cosTheta > 0 && is_intersecting == 1
        mark_courtship(start_idx:end_idx) = 1;
    elseif sum(dist_over_time(start_idx:end_idx) < thresold_pixel_distance) == length(dist_over_time(start_idx:end_idx))
        mark_courtship(start_idx:end_idx) = 1;
        mark_courtship_zero_dist_max(start_idx:end_idx) = 1;
    end

    
end

close(progress_bar)

progress_bar1 = waitbar(0,'Starting courtship algorithm - II...');
% less than threshold pixels for 15 seconds, then remove courtship
window_length = window_limit_for_dist_condition; % 15/10 seconds, each second is 5 frames
window_num = 0;
for f = 1:step_size:length(files')-window_length
    window_num = window_num + 1;
    waitbar(window_num/total_num_windows, progress_bar1, sprintf('Remove windows where flies stay still for long: %d %%', floor(window_num/total_num_windows*100)));

    start_idx = 1 + (window_num - 1)*step_size;
    end_idx = start_idx + window_length - 1;
    
    
    if sum(mark_courtship_zero_dist_max(start_idx:end_idx)) == length(mark_courtship_zero_dist_max(start_idx:end_idx))
        % disp(['Removed window_num is ' num2str(window_num)])
        fly1_start_pt = fly_1_coords_over_time(start_idx, :);
        fly1_end_pt = fly_1_coords_over_time(end_idx, :);
        fly1_dist_travelled = pdist([fly1_start_pt; fly1_end_pt]);

        fly2_start_pt = fly_2_coords_over_time(start_idx, :);
        fly2_end_pt = fly_2_coords_over_time(end_idx, :);
        fly2_dist_travelled = pdist([fly2_start_pt; fly2_end_pt]);

        if fly1_dist_travelled < thresold_pixel_distance &&  fly2_dist_travelled < thresold_pixel_distance
            mark_courtship(start_idx:end_idx) = 0;
            mark_courtship_zero_dist_max(start_idx:end_idx) = 0;
        end
        
    end

end

close(progress_bar1)

courtship_index = num2str(0.2*sum(mark_courtship)/600);
courtship_frame_num = num2str(0.2*sum(mark_courtship));
disp(['frame of courtsip ' courtship_frame_num ' Index = ' courtship_index ])

end