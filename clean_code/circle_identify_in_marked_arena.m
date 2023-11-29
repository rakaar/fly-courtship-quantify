% FILEPATH: /home/rka/code/fly_courtship/clean_code/circle_identify_in_marked_arena.m
% BEGIN: abpxx6d04wxr
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

% Analyze each contour and calculate centroids
stats = regionprops(labeledImage, 'Area', 'Centroid');

% Radius of the circles
circleRadius = 140;

% Counter for number of masks
maskCount = 0;

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
        % Increment mask count
        maskCount = maskCount + 1;

        % Initialize mask for this circle
        mask = zeros(size(img_gray));

        % Iterate over each pixel in the mask
        for x = 1:size(mask, 1)
            for y = 1:size(mask, 2)
                % Check if the pixel is inside the circle
                if (x - centroid(2))^2 + (y - centroid(1))^2 <= circleRadius^2
                    mask(x, y) = 1;
                end
            end
        end

        % Save or display the mask
        % For example, save each mask as an image
        % imwrite(mask, sprintf('mask_%d.png', maskCount));
        % TODO - mask.*img_gray
        figure
        imagesc(mask.*double(img_gray)); % Convert img_gray to double
    end
end

% Indicate completion
fprintf('Created %d mask(s).\n', maskCount);
% END: be15d9bcejpp
