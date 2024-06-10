function [fly_1_coords_over_time, fly_2_coords_over_time, dist_over_time, are_flies_present, num_of_frames_with_no_flies] = find_flies_dist_based(output_folder, mask, circle_area, tolerance_limit_for_num_frames_with_no_flies)
    fly_min_area_percent = 0.01;
    fly_max_area_percent = 2;
    thresold_for_fly_color = 80;
    dist_over_time = [];
    fly_1_coords_over_time = [];
    fly_2_coords_over_time = [];
    
    
    are_flies_present = 1;
    num_of_frames_with_no_flies = 0;


    if ~strcmp(computer, 'GLNXA64')
        files = dir([output_folder '\*.png']);
    else
        files = dir([output_folder '/*.png']);
    end
    counter = 1;
    total_num_files = length(files);
    progress_bar = waitbar(0, 'Starting');

    for file = files'
        try
            % Your original code
            waitbar(counter/total_num_files, progress_bar, sprintf('Identifying Flies in each frame: %d %%', floor(counter/total_num_files*100)));
        catch ME
            % Error handling code
            fprintf('An error occurred: %s\n', ME.message);
            fprintf('Current counter value: %d\n', counter);
            fprintf('Total number of files: %d\n', total_num_files);
            % Include any other relevant information here
            % You can also perform other error handling operations here
        end
        
        % waitbar(counter/total_num_files, progress_bar, sprintf('Identifying Flies in each frame: %d %%', floor(counter/total_num_files*100)));
        
        % read image
        % WINDOWS
        if ~strcmp(computer, 'GLNXA64')
            img = imread(strcat(output_folder,'\', file.name));
        else
            img = imread(strcat(output_folder,'/', file.name));
        end
        
        if length(size(img)) == 3
            img1 = rgb2gray(img);
        else
            img1 = img;
        end

        
        maskedFly1 = double(img1) .* mask;

        % threshold for fly color
        flies_logical = maskedFly1 < thresold_for_fly_color;

        
        % images processing by matlab to identify blobs
        cc = bwconncomp(double(flies_logical).*mask);  % 'binaryImage' is the thresholded image
        stats = regionprops(cc, 'Area', 'Centroid', 'BoundingBox');

        % Visualize centroids on maskedFly1
        % figure;
        % imagesc(maskedFly1);
        % hold on;
        % for i = 1:length(stats)
        %     centroid = stats(i).Centroid;
        %     text(centroid(1), centroid(2), num2str(i), 'Color', 'red', 'FontSize', 12);
        % end
        % hold off;
        
        % get fly indices based on area of blobs
        fly_indices  = [];
        for i = 1:length(stats)
            
            if 100*(stats(i).Area/circle_area) > fly_min_area_percent && 100*(stats(i).Area/circle_area) < fly_max_area_percent 
                fly_indices = [fly_indices i];
            end
        end
        
       
        % if More than 2 flies are detected, choose the ones with biggest area, the smallest may be due to noise
        if length(fly_indices)  > 2
            max_area1 = -1;
            max_area2 = -1;
            max_area1_ind = 0;
            max_area2_ind = 0;
            for f_ind = 1:length(fly_indices)
                if stats(fly_indices(f_ind)).Area > max_area1
                    % Update max_area2 with old max_area1 before updating max_area1
                    max_area2 = max_area1;
                    max_area2_ind = max_area1_ind;

                    % Now update max_area1
                    max_area1 = stats(fly_indices(f_ind)).Area;
                    max_area1_ind = fly_indices(f_ind);
                elseif stats(fly_indices(f_ind)).Area > max_area2
                    max_area2 = stats(fly_indices(f_ind)).Area;
                    max_area2_ind = fly_indices(f_ind);
                end
            end % for
            
            fly_indices = [max_area1_ind max_area2_ind];
        end % if
        % TODO - Clean code, because now number of flies is atmost 2

        
        if length(fly_indices) == 2

            fly_coords(1,:) = stats(fly_indices(1)).Centroid;
            fly_coords(2,:) = stats(fly_indices(2)).Centroid;

            if counter > 1
                    % Distance based criteria
                    old_fly_1_coords = fly_1_coords_over_time(counter-1,:);
                    if pdist([fly_coords(1,:); old_fly_1_coords]) < pdist([fly_coords(2,:); old_fly_1_coords])
                        fly_1_coords_over_time = [fly_1_coords_over_time; fly_coords(1,:)];
                        fly_2_coords_over_time = [fly_2_coords_over_time; fly_coords(2,:)];
                    else
                        fly_1_coords_over_time = [fly_1_coords_over_time; fly_coords(2,:)];
                        fly_2_coords_over_time = [fly_2_coords_over_time; fly_coords(1,:)];
                    end
                
            else
                    fly_1_coords_over_time = [fly_1_coords_over_time; fly_coords(1,:)];
                    fly_2_coords_over_time = [fly_2_coords_over_time; fly_coords(2,:)];
            end
            
            dist = pdist(fly_coords);
            dist_over_time = [dist_over_time dist];
       
        elseif length(fly_indices) == 1
                dist_over_time = [dist_over_time 0];
                fly_1_coords_over_time = [fly_1_coords_over_time; stats(fly_indices(1)).Centroid];
                fly_2_coords_over_time = [fly_2_coords_over_time; stats(fly_indices(1)).Centroid];

        else
            disp('No flies detected')
             % Visualize centroids on maskedFly1

             if length(dist_over_time) > 1
                dist_over_time = [dist_over_time dist_over_time(end-1)];
            else
                dist_over_time = [dist_over_time nan];
             end
               
              
            if size(fly_1_coords_over_time,1) > 1
                fly_1_coords_over_time = [fly_1_coords_over_time; [fly_1_coords_over_time(end-1,1) fly_1_coords_over_time(end-1,2)]];
                fly_2_coords_over_time = [fly_2_coords_over_time; [fly_2_coords_over_time(end-1,1) fly_2_coords_over_time(end-1,2)]];
            else
                fly_1_coords_over_time = [fly_1_coords_over_time; [nan nan]];
                fly_2_coords_over_time = [fly_2_coords_over_time; [nan nan]];
            end
             
            
        
            num_of_frames_with_no_flies = num_of_frames_with_no_flies + 1;
            if num_of_frames_with_no_flies > tolerance_limit_for_num_frames_with_no_flies
                are_flies_present = 0;
                break;
            end
        end % if

        counter = counter + 1;
        
        
    end % for file
    close(progress_bar)



end