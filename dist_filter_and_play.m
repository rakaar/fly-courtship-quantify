close all;clear;
dist_over_time = load('dist_over_time').dist_over_time;

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
frame_len_for_sg_filter = 1001;
smooth_dist = sgolayfilt(dist_over_time,3,frame_len_for_sg_filter);
% d_smooth_dist = diff(smooth_dist);
% figure
%     plot(smooth_dist, 'b', 'LineWidth', 2)
%     hold on
%     plot(d_smooth_dist, 'r', 'LineWidth', 2)
%     hold off
%     legend('Smoothed Signal','Derivative of Smoothed Signal')
%     title('Just see derivative')


% Assuming smooth_dist is already defined
window_length = 75;
step_size = 5;
num_points = length(smooth_dist);

% Determine the number of windows
num_windows = floor((num_points - window_length) / step_size) + 1;

% Initialize a vector to store slopes
slopes = zeros(1, num_windows);
alphas = zeros(1, num_windows);
windows_with_courtship = zeros(1, num_windows);

mark_courtship = zeros(length(smooth_dist),1);
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
alpha = 0.3; % significance level
for k = 1:num_windows
    % Define start and end indices for the current window
    start_idx = 1 + (k-1)*step_size;
    end_idx = start_idx + window_length - 1;

    % Extract data for the current window
    window_data = smooth_dist(start_idx:end_idx);

    x = 1:length(window_data); 
    y = window_data;

    X = [ones(length(x), 1) x'];
    
    % Compute the coefficients (beta)
    beta = (X' * X) \ X' * y';
    slope_of_fit = beta(2);

    % Compute residuals
    y_fit = X * beta;
    residuals = y - y_fit';
    
    % Compute standard error of the residuals
    stderr_residuals = std(residuals);

   % Compute standard error of the slope
    stderr_slope = stderr_residuals / sqrt(sum((x - mean(x)).^2));

    % Compute t-statistic for the slope
    t_slope = beta(2) / stderr_slope;

    % Compute p-value for the t-statistic
    df = length(x) - 2; % degrees of freedom
    pValue_slope = 2 * (1 - tcdf(abs(t_slope), df));

    alphas(k) = pValue_slope;
    % Compare p-value to significance level
    if slope_of_fit < 0 && pValue_slope < alpha
        mark_courtship(start_idx:end_idx) = 1;
        windows_with_courtship(k) = 1;
    end
end
disp(['frame of courtsip ' num2str(0.2*sum(mark_courtship)) ' Index = ' num2str(0.2*sum(mark_courtship)/600) ' for sg filter len ' num2str(frame_len_for_sg_filter)])
% Now, 'slopes' contains the slope of the line fit to each window

figure;
plot(smooth_dist, '-');    % Plot the smooth line
hold on;                   % Hold the plot to overlay the next elements
indices = find(mark_courtship == 1);       % Find the indices where mark_courtship is 1
plot(indices, smooth_dist(indices), '*');  % Mark '*' at those points
xlabel('X-axis label');
ylabel('Y-axis label');
title('Smooth Dist with Courtship Marks');
legend('Smooth Dist', 'Courtship Marks');

save('mark_courtship', 'mark_courtship')