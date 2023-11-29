clear;close all;clc;
% Read the image
img = imread('/home/rka/code/fly_courtship/all_frames/frame_0001.png');

% Convert to grayscale
if size(img, 3) == 3
    img_gray = rgb2gray(img);
else
    img_gray = img;
end

% Apply thresholding
binaryImage = imbinarize(img_gray);

% Find contours
[boundaries, labeledImage] = bwboundaries(binaryImage, 'noholes');

% Display the original image
imshow(img);
hold on;

% Analyze each contour and calculate centroids
stats = regionprops(labeledImage, 'Area', 'Centroid');

for k = 1:length(boundaries)
    % Get area and centroid
    area = stats(k).Area;
    centroid = stats(k).Centroid;

    % Calculate perimeter and circularity
    boundary = boundaries{k};
    delta_sq = diff(boundary).^2;
    perimeter = sum(sqrt(sum(delta_sq,2)));
    circularity = 4*pi*area/perimeter^2;

    % Check if circularity and area are within desired thresholds
    if circularity > 0.5 && area/1e3 > 45 && area/1e3 < 55
        % Highlight the circular region
        plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
        % Draw a circle of radius 260 around the centroid
        viscircles(centroid, 140, 'EdgeColor', 'r');
    end
end
hold off;
