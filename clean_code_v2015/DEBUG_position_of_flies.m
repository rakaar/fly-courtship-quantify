clear;

fly_1_coords_over_time = load('fly_1_coords_over_time').fly_1_coords_over_time;
fly_2_coords_over_time = load('fly_2_coords_over_time').fly_2_coords_over_time;

files = dir('../all_frames/*.png');

for f = 1:length(files')
    file = files(f);
    disp(['Processing file ' file.name])
    % read image
    img = imread(strcat('../all_frames/', file.name));
    imshow(img)
    hold on
    % Coordinates for the two flies at time counter+1
    coords_fly1 = fly_1_coords_over_time(f,:);
    coords_fly2 = fly_2_coords_over_time(f,:);

    % Marking the coordinates with text
    text(coords_fly1(1), coords_fly1(2), '1', 'Color', 'b', 'FontSize', 20, 'FontWeight', 'bold');
    text(coords_fly2(1), coords_fly2(2), '2', 'Color', 'r', 'FontSize', 20, 'FontWeight', 'bold');
    hold off

    title([ 'frame ' file.name])

    pause
    
end