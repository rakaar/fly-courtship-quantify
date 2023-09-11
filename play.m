img = imread('img0025.png');
% with below four cooridaintes, construct a circle and plot in matlab
% 180, 26
% 182, 302
% 49, 171
% 310, 178

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


% masked fly image
maskedFly = img .* mask;
figure, imshow(maskedFly);


makedFly1 = uint8(img1) .* mask;
figure, imagesc(makedFly1);