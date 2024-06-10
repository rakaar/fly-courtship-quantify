function circle_img = generate_circle(centroidX, centroidY, radius, rows, cols)
    % Initialize the image as a matrix of zeros
    circle_img = zeros(rows, cols);

    % Iterate over each pixel in the image
    for r = 1:rows
        for c = 1:cols
            % If the pixel is inside the circle, set it to 1
            if (r - centroidY)^2 + (c - centroidX)^2 <= radius^2
                circle_img(r, c) = 1;
            end
        end
    end
end