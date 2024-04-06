arena = load('ARENA1.mat').mat;
stat_frame_window_len = 5;
% Find and analyze segments of ones
all_ranges = [];
stationary_frames_1 = find(stationary_frames == 1);
first_1 = stationary_frames_1(1);

window_begin_frames = first_1:5:length(stationary_frames) - stat_frame_window_len + 1;

for w = 1:length(window_begin_frames)
	start_frame = window_begin_frames(w);
	end_frame = start_frame + stat_frame_window_len - 1;
	

	if sum(stationary_frames(start_frame:end_frame)) == stat_frame_window_len
		pic_no_index = 1;
		num_pixels = nan(stat_frame_window_len,1);

		for pic_no = start_frame:end_frame		
			filename = sprintf('/home/rka/code/fly_courtship/all_frames/frame_%04d.png', pic_no);
    
			 %Read the image file
			img = imread(filename);
			img1 = rgb2gray(img);
			masked_pic = double(arena).*double(img1);
			
			subplot(1,3,1)
			imagesc(masked_pic)
			title(['Pic no = ' num2str(pic_no)])
			
			wing_range_num = masked_pic > 150 & masked_pic < 180;
			num_pixels(pic_no_index) = sum(wing_range_num(:));
		
			 pic_no_index = pic_no_index + 1;
			
			subplot(1,3,2)
			bar(num_pixels)
		     range_num_pixels = max(num_pixels(:)) - min(num_pixels(:));
			title( [ 'Max = ' num2str(max(num_pixels(:))) ' Min = ' num2str(min(num_pixels(:))) ' range = ' num2str(range_num_pixels) ]  )

			subplot(1,3,3)
			imagesc(masked_pic.*double(wing_range_num))	
			pause
		end

			all_ranges = [all_ranges range(num_pixels) ];
	end
end


return
i = 1;
while i <= length(stationary_frames)
    if stationary_frames(i) == 1
        % Start of a potential segment
        startIdx = i;
        endIdx = i;
        
        % Extend the segment as long as we encounter ones
        while endIdx <= length(stationary_frames) && stationary_frames(endIdx) == 1
            endIdx = endIdx + 1;
        end
        
        % Adjust endIdx to point to the last 1 in the segment
        endIdx = endIdx - 1;
        
        % Now iterate through the segment in windows of stat_frame_window_len or less
        j = startIdx;
        while j <= endIdx
            windowEnd = min(j + 5, endIdx); % Ensure we don't exceed the segment
            
            % Perform your analysis on the window [j, windowEnd]
            % For example, simply display the window
            disp(['Analyzing window from ', num2str(j), ' to ', num2str(windowEnd)]);
            
            % Insert your analysis code here
            num_pixels =  -1*ones(length(j:windowEnd)); 
		    pic_no_index = 1;	
			for pic_no = j:windowEnd
				% read frame_{pic_no}.png pic_no is 4 digits - 0001,0002 to 3001 in folder "/home/rka/code/fly_courtship/all_frames"
			filename = sprintf('/home/rka/code/fly_courtship/all_frames/frame_%04d.png', pic_no);
    
			% Read the image file
			img = imread(filename);
			img1 = rgb2gray(img);
			masked_pic = double(arena).*double(img1);
			
			subplot(1,2,1)
			imagesc(masked_pic)
			title(num2str(pic_no))
			
			num_btn_100_and_150 = masked_pic > 80 & masked_pic < 150;
			num_pixels(pic_no_index) = sum(num_btn_100_and_150(:));
			pic_no_index = pic_no_index + 1;
			subplot(1,2,2)
			bar(num_pixels)
			title( num2str( max(num_pixels) - min(num_pixels) ) )



			pause

			end
	
            % Move to the next window in the segment
            j = windowEnd + 1;

        end
        
        % Move i past this segment
        i = endIdx + 1;
    else
        % If it's not a 1, just move to the next element
        i = i + 1;
    end
end
