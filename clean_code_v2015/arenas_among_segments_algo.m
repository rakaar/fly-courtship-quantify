function arena_masks = arenas_among_segments_algo(sorted_all_segments_struct)
    arena_masks = struct('mask', {});
    
    for i = 1:length(sorted_all_segments_struct)-3
        matched_arena_segment_indices = [];

        if sorted_all_segments_struct(i).best_fit_circle_correlation > 0.9
            matched_arena_segment_indices = [matched_arena_segment_indices i]; 
            radius_i = sorted_all_segments_struct(i).best_fit_circle_radius;
            
            for j = i+1:length(sorted_all_segments_struct)
                if sorted_all_segments_struct(j).best_fit_circle_correlation > 0.9
                    radius_j = sorted_all_segments_struct(j).best_fit_circle_radius;
                    if radius_j > 0.9*radius_i && radius_j < 1.1*radius_i
                        % print radius and correlation of j
                        disp(['j = ' num2str(j)  ,' radius: ', num2str(radius_j), ' correlation: ', num2str(sorted_all_segments_struct(j).best_fit_circle_correlation)]);
                        matched_arena_segment_indices = [matched_arena_segment_indices, j];
                    end % if
                end % if
            end % for j

            if length(matched_arena_segment_indices) == 4
                break
            end
        end % if 
    end % for i

    
    for m = 1:length(matched_arena_segment_indices)
        arena_masks(m).mask = sorted_all_segments_struct(matched_arena_segment_indices(m)).best_fit_circle;
    end

    
end