function arena_masks = arenas_among_segments_algo(sorted_all_segments_struct)
    arena_masks = struct('mask', {});
    matched_arena_segment_indices = [];
    found_arenas = false;
    for i = 1:length(sorted_all_segments_struct)-3
        if found_arenas
            break; % Exit outer loop if 4 matching segments have been found
        end
        

        if sorted_all_segments_struct(i).best_fit_circle_correlation > 0.9
            if ~ismember(i, matched_arena_segment_indices)
                matched_arena_segment_indices = [matched_arena_segment_indices, i];
            end
            % matched_arena_segment_indices = [matched_arena_segment_indices i]; 
            radius_i = sorted_all_segments_struct(i).best_fit_circle_radius;
            
            for j = i+1:length(sorted_all_segments_struct)
                if sorted_all_segments_struct(j).best_fit_circle_correlation > 0.9
                    radius_j = sorted_all_segments_struct(j).best_fit_circle_radius;
                    if radius_j > 0.9*radius_i && radius_j < 1.1*radius_i
                        if ~ismember(j, matched_arena_segment_indices)
                            matched_arena_segment_indices = [matched_arena_segment_indices, j];
                        end


                        if length(matched_arena_segment_indices) == 4
                            found_arenas = true; % Set flag to true to indicate 4 segments have been found
                            break % Exit inner loop
                        end
                    end % if
                end % if
            end % for j


        end % if 
    end % for i

    for m = 1:length(matched_arena_segment_indices)
        arena_masks(m).mask = sorted_all_segments_struct(matched_arena_segment_indices(m)).best_fit_circle;
    end

    
end