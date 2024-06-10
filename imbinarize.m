function binaryImage = imbinarize(grayImage, threshold)
    % If no threshold is provided, use Otsu's method to calculate it
    if nargin < 2
        threshold = graythresh(grayImage); % Otsu's method
    end
    
    % Ensure the image is in the range [0, 1] for thresholding
    if isinteger(grayImage)
        grayImage = double(grayImage) / 255;
    end

    % Apply the threshold to binarize the image
    binaryImage = grayImage > threshold;
    
    % Convert the logical array to uint8 if necessary
    binaryImage = uint8(binaryImage) * 255;
end
