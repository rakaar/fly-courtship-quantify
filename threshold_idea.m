clc;close all;clear;


img = imread('all_frames/frame_0052.png');
img1 = squeeze(mean(img, 3));


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

% Plot the circle
% plot(x, y);

% Now make a mask out of cirle, basically ones inside circle, zeros outside circle
[columnsInImage, rowsInImage] = meshgrid(1:size(img, 2), 1:size(img, 1));
circlePixels = (rowsInImage - y_center).^2 + (columnsInImage - x_center).^2 <= radius.^2;
mask = uint8(circlePixels);


maskedFly1 = uint8(img1) .* mask;
figure, imagesc(maskedFly1);


flies_logical = maskedFly1 < 80;
figure, imagesc(flies_logical);

cc = bwconncomp(flies_logical);  % 'binaryImage' is the thresholded image
labeledImage = labelmatrix(cc);
figure, imshow(labeledImage, []); colormap(jet);  % Apply jet colormap for better visualization

stats = regionprops(cc, 'Area', 'Centroid', 'BoundingBox');



circle_area = pi*(radius^2);
fly_min_area_percent = 0.01;
fly_max_area_percet = 2;
fly_indices  = [];
for i = 1:length(stats)
    if 100*(stats(i).Area/circle_area) > fly_min_area_percent && 100*(stats(i).Area/circle_area) < fly_max_area_percet
        fly_indices = [fly_indices i];
    end
end

fly_coords = zeros(2,2);
if length(fly_indices) == 2
    fly_coords(1,:) = stats(fly_indices(1)).Centroid;
    fly_coords(2,:) = stats(fly_indices(2)).Centroid;

    dist = pdist(fly_coords);
    disp(dist)
    figure,
    imagesc(maskedFly1);  % Replace 'yourImage' with your image matrix name
    % Plot centroids
    hold on;
    plot(fly_coords(:,1), fly_coords(:,2), 'r*', 'MarkerSize', 10);
    hold off

else
    disp('Only 1 Fly')
end

