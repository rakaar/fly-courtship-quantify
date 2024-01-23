all_segments_struct = struct('segment', {}, 'area', {}, 'best_fit_circle_correlation', {}, 'best_fit_circle_radius', {}, 'best_fit_circle', {});

% Pattern to match files starting with 'c' and ending with '.mat'
filePattern = 'c*.mat';

% Get a list of files that match the pattern
files = dir(filePattern);

% Count the number of files
numFiles = numel(files);

all_radius = zeros(numFiles, 1);
all_corrs = zeros(numFiles, 1);

% Display the number of files
disp(['Number of files: ', num2str(numFiles)]);
for i = 1:numFiles
    

    fname = strcat('c', num2str(i), '.mat');
    seg = load(fname).segment;
    area = load(fname).area;

    all_segments_struct(i).segment = seg;
    all_segments_struct(i).area = area;

    % Find centroid of segmented areas
    [centroidX, centroidY] = calculate_centroid(seg);
    
    radius_range = 100:2:150;
    corr_vals = zeros(length(radius_range), 1);
    c = 1;
    for r = radius_range
        circle_img = generate_circle(centroidX, centroidY, r, size(seg, 1), size(seg, 2));
        corr_vals(c) = corr2(seg, circle_img);
        c = c + 1;
    end

    [max_corr, max_idx] = max(corr_vals);
    all_radius(i) = radius_range(max_idx);
    all_corrs(i) = max_corr;

    all_segments_struct(i).best_fit_circle_correlation = max_corr;
    all_segments_struct(i).best_fit_circle_radius = radius_range(max_idx);
    all_segments_struct(i).best_fit_circle = generate_circle(centroidX, centroidY, radius_range(max_idx)+10, size(seg, 1), size(seg, 2));

end
sorted_all_segments_struct = arrange_masks_area_desc_order(all_segments_struct);  


disp('find arena masks')

arena_masks = arenas_among_segments_algo(sorted_all_segments_struct);
if length(arena_masks) ~= 4
    error('Could not find 4 arena masks');
end

for i = 1:4
    mat = arena_masks(i).mask;
    save(strcat('ARENA', num2str(i), '.mat'), 'mat');
end
