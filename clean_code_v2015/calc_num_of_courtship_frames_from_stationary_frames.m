function [courtship_stationary_frames, new_courtship_frame_num] = calc_num_of_courtship_frames_from_stationary_frames(stationary_frames, output_folder, indiv_mask, window_len_for_stationary_parts, range_pixels_for_wing_song)
	
	courtship_stationary_frames = zeros(length(stationary_frames), 1);

	% wing identification is btn 150 and 180
	min_pixel_value_for_wing = 150; max_pixel_value_for_wing = 180;

	stationary_frames_1 = find(stationary_frames == 1);
	first_1 = stationary_frames_1(1);

	window_begin_frames = stationary_frames_1(1:2:end);

	for w = 1:length(window_begin_frames)
		start_frame = window_begin_frames(w);
		end_frame = min(start_frame +  window_len_for_stationary_parts - 1, length(stationary_frames));

		num_pixels_in_wing_song_range = nan(length(start_frame:end_frame),1);
		
		p_idx = 1;
		for pic_no = start_frame:end_frame		

				if ~strcmp(computer, 'GLNXA64')
					filename = sprintf('%s\frame_%04d.png', output_folder, pic_no);
				else
					filename = sprintf('%s/frame_%04d.png', output_folder, pic_no);
				end

		
				img = imread(filename);
				img1 = rgb2gray(img);
				masked_pic = double(indiv_mask).*double(img1);

				logical = (masked_pic > min_pixel_value_for_wing) & (masked_pic < max_pixel_value_for_wing);
				num_pixels_in_wing_song_range(p_idx) = sum(logical(:));
				p_idx = p_idx + 1;
		end
		
		if range(num_pixels_in_wing_song_range) > range_pixels_for_wing_song
			courtship_stationary_frames(start_frame:end_frame) = 1;
		end

	end

	new_courtship_frame_num = sum(courtship_stationary_frames);

end
