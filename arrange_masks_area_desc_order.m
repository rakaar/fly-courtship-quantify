function [arena_struct_with_areas_desc_order] = arrange_masks_area_desc_order(all_segments_struct)

    existingFieldNames = fieldnames(all_segments_struct);
    arena_struct_with_areas_desc_order = cell2struct(cell(size(existingFieldNames)), existingFieldNames);

    areas = zeros(length(all_segments_struct), 1);
    for i = 1:length(all_segments_struct)
        areas(i) = all_segments_struct(i).area;
    end
    [~, idx] = sort(areas, 'descend');

    for i = 1:length(all_segments_struct)
        arena_struct_with_areas_desc_order(i) = all_segments_struct(idx(i));
    end
end