function [masks, centroids, areas] = find_arena_masks(first_img_gray, circleRadius)
    
    masks = zeros(4, size(first_img_gray, 1), size(first_img_gray, 2));
    centroids = zeros(4,2);
    areas = zeros(4,1);

    % Apply thresholding
    binaryImage = imbinarize(first_img_gray);

    % Find contours
    [boundaries, labeledImage] = bwboundaries(binaryImage, 'noholes');

    % Analyze each contour and calculate centroids
    stats = regionprops(labeledImage, 'Area', 'Centroid');

    maskCount = 1;
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
            % Initialize mask for this circle
            mask = zeros(size(first_img_gray));
    
            % Iterate over each pixel in the mask
            for x = 1:size(mask, 1)
                for y = 1:size(mask, 2)
                    % Check if the pixel is inside the circle
                    if (x - centroid(2))^2 + (y - centroid(1))^2 <= circleRadius^2
                        mask(x, y) = 1;
                    end
                end
            end
            masks(maskCount, :, :) = mask;
            centroids(maskCount, 1) = centroid(1); centroids(maskCount,2) = centroid(2);
            areas(maskCount) = area;
            maskCount = maskCount + 1;
            
        end
    end
   




end