function [centroidX, centroidY] = calculate_centroid(img)
    % Assume 'img' is your binary image
    [rows, cols] = size(img);
    
    % Initialize accumulators
    sumX = 0;
    sumY = 0;
    count = 0;
    
    % Iterate over each pixel
    for r = 1:rows
        for c = 1:cols
            % If the pixel is part of the object
            if img(r, c) == 1
                % Add its coordinates to the accumulators
                sumX = sumX + c;
                sumY = sumY + r;
                count = count + 1;
            end
        end
    end
    
    % Calculate the centroid
    centroidX = sumX / count;
    centroidY = sumY / count;
end