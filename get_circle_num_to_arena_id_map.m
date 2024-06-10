function arena_map = get_circle_num_to_arena_id_map(masks)
    % Initialize the map container
    arena_map = containers.Map('KeyType', 'int32', 'ValueType', 'char');

    % Get the number of masks
    [numMasks, ~, ~] = size(masks);

    % Initialize arrays to store centroid coordinates
    centroidsX = zeros(1, numMasks);
    centroidsY = zeros(1, numMasks);

    % Calculate centroids for each mask
    for m = 1:numMasks
        currentMask = squeeze(masks(m, :, :));
        props = regionprops(currentMask, 'Centroid');
        centroidsX(m) = props.Centroid(1);
        centroidsY(m) = props.Centroid(2);
    end

    % Calculate average centroid coordinates
    avgX = mean(centroidsX);
    avgY = mean(centroidsY);

    % Determine quadrant for each mask
    for m = 1:numMasks
        if centroidsX(m) > avgX && centroidsY(m) < avgY
            arena_id = 'A';
        elseif centroidsX(m) > avgX && centroidsY(m) > avgY
            arena_id = 'B';
        elseif centroidsX(m) < avgX && centroidsY(m) > avgY
            arena_id = 'C';
        else % centroidsX(m) < avgX && centroidsY(m) < avgY
            arena_id = 'D';
        end

        % Map the mask number to the arena_id
        arena_map(m) = arena_id;
    end
end
