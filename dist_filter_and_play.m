close all;clear;clc;
dist_over_time = load('dist_over_time').dist_over_time;

order = 3;
frame_len = 11;
sg_dist_over_time = sgolayfilt(dist_over_time,order,frame_len);

figure
    plot(dist_over_time, 'b', 'LineWidth', 2)
    hold on
    plot(sgolayfilt(dist_over_time,3,11), 'LineWidth', 2)
    plot(sgolayfilt(dist_over_time,3,15), 'LineWidth', 2)
    hold off
    % legend('Original Signal','Filtered Signal')