output_folder = '/home/rka/code/fly_courtship/all_frames';
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


[columnsInImage, rowsInImage] = meshgrid(1:size(img, 2), 1:size(img, 1));
circlePixels = (rowsInImage - y_center).^2 + (columnsInImage - x_center).^2 <= radius.^2;
mask = uint8(circlePixels);

% Plot the circle
img1 = squeeze(mean(img,3));

% apply mask
maskedFly1 = uint8(img1) .* mask;

%% _____________________________-- circle iteratively
% Read the image

% Define the center and initial radius of the circle
img1_a = img1;
% You might need to adjust these values
centerX = size(img1_a, 2) / 2;
centerY = size(img1_a, 1) / 2;
initialRadius = min(centerX, centerY);  % Start with the largest possible circle
ringThickness = 5;
% Prepare a matrix for correlation values
correlationValues = [];
all_radius = initialRadius:-2:100;
% Loop to decrease the radius and draw circles
for radius = all_radius  % Decrease radius in steps of 5 pixels down to a minimum of 20
    % Create a blank image
    circleImg = zeros(size(img1_a));
    
    % Draw a circle
    % [X, Y] = meshgrid(1:size(circleImg, 2), 1:size(circleImg, 1));
    % circleImg((X - centerX).^2 + (Y - centerY).^2 <= radius.^2) = 1;

    % strip
    [X, Y] = meshgrid(1:size(circleImg, 2), 1:size(circleImg, 1));
    distanceFromCenter = (X - centerX).^2 + (Y - centerY).^2;
    circleImg(distanceFromCenter <= radius.^2 & distanceFromCenter >= (radius - ringThickness).^2) = 1;
    
    
    % Calculate the correlation
    corrValue = corr2(img1_a, circleImg);
    correlationValues = [correlationValues;  corrValue];
end

% Find the radius with the maximum correlation
[~, maxIndex] = max(correlationValues);
bestRadius = all_radius(maxIndex);
bestRadius = bestRadius + 5;
% Display the original image with the best circle overlaid
[X, Y] = meshgrid(1:size(circleImg, 2), 1:size(circleImg, 1));
circleImg((X - centerX).^2 + (Y - centerY).^2 <= bestRadius.^2) = 1;
mask = uint8(circleImg);


% apply mask
maskedFly1 = uint8(img1_a) .* mask;
imagesc(maskedFly1)

%% ---- BLOBS --------
% Assuming img1_a is your input image
% Convert to binary image if it's not already
cc = bwconncomp(img1_a);  % 'binaryImage' is the thresholded image
stats = regionprops(cc, 'Area', 'Centroid', 'BoundingBox');
for k = 1:numObjects
    % Create an image for this object only
    singleObjectImage = false(size(bw));  % Initialize with a blank image
    singleObjectImage(objectProperties(k).PixelIdxList) = true;

    % Display the image
    figure;
    imshow(singleObjectImage);
    title(['Object ', num2str(k)]);
end
