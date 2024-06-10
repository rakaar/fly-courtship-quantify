function filtered_segments_struct = remove_overlapping_segments(all_segments_struct)
    % Initialize a logical index vector to keep track of segments to keep
    keep_indices = true(1, length(all_segments_struct));
    
    % Iterate through pairs of segments
    for i = 1:length(all_segments_struct)-1
        for j = i+1:length(all_segments_struct)
            % Calculate overlap percentage between segment i and j
            overlap_percentage = calculate_overlap_percent(all_segments_struct(i).segment, all_segments_struct(j).segment);
            
            % If overlap exceeds 95%, mark one (or both) for removal
            if overlap_percentage > 95
                % Example strategy: mark the segment with the lower correlation for removal
                if all_segments_struct(i).best_fit_circle_correlation < all_segments_struct(j).best_fit_circle_correlation
                    keep_indices(i) = false;
                else
                    keep_indices(j) = false;
                end
            end
        end
    end
    
    % Filter out the segments marked for removal
    filtered_segments_struct = all_segments_struct(keep_indices);
end
