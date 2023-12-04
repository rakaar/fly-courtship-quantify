function newBinaryArray = make_circle_proper(binaryArray)
% Assuming 'binaryArray' is your input binary array

% Find all y,x coordinates where the array value is 1
[y, x] = find(binaryArray);

% Find the leftmost and rightmost points
leftmost = min(x);
rightmost = max(x);

% Find y-coordinates corresponding to the leftmost and rightmost x-coordinates
leftmostY = y(x == leftmost);
rightmostY = y(x == rightmost);

% Calculate the vertical center
centerY = mean([leftmostY; rightmostY]);

% Calculate the center and radius
centerX = (leftmost + rightmost) / 2;
radius = (rightmost - leftmost) / 2 + 10; % 10 is offset; 

% Create a new binary array with a perfect circle
newBinaryArray = false(size(binaryArray));
[rows, cols] = size(binaryArray);
for i = 1:rows
    for j = 1:cols
        if sqrt((j - centerX)^2 + (i - centerY)^2) <= radius
            newBinaryArray(i, j) = 1;
        end
    end
end

% newBinaryArray now contains the circle


% newBinaryArray now contains the circle



end