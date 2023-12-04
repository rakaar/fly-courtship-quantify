function find_flies(output_folder, mask, circle_area)
    fly_min_area_percent = 0.01;
    fly_max_area_percet = 2;
    thresold_for_fly_color = 80;

    if ~strcmp(computer, 'GLNXA64')
        files = dir([output_folder '\*.png']);
    else
        files = dir([output_folder '/*.png']);
    end
    counter = 1;
    for file = files'

        disp(['Processing file ' file.name])
        % read image
        % WINDOWS
        if ~strcmp(computer, 'GLNXA64')
            img = imread(strcat(output_folder,'\', file.name));
        else
            img = imread(strcat(output_folder,'/', file.name));
        end
        
        img1 = rgb2gray(img);
        imagesc(img1)
        maskedFly1 = double(img1) .* mask;

        % threshold for fly color
        flies_logical = maskedFly1 < thresold_for_fly_color;

        
        % images processing by matlab to identify blobs
        cc = bwconncomp(double(flies_logical).*mask);  % 'binaryImage' is the thresholded image
        stats = regionprops(cc, 'Area', 'Centroid', 'BoundingBox');

        % Visualize centroids on maskedFly1
        figure;
        imagesc(maskedFly1);
        hold on;
        for i = 1:length(stats)
            centroid = stats(i).Centroid;
            text(centroid(1), centroid(2), num2str(i), 'Color', 'red', 'FontSize', 12);
        end
        hold off;
        
        % get fly indices based on area of blobs
        fly_indices  = [];
        circle_area = circle_area * 1e3;
        for i = 1:length(stats)
            disp(stats(i).Area)
            if 100*(stats(i).Area/circle_area) > fly_min_area_percent && 100*(stats(i).Area/circle_area) < fly_max_area_percet && mask(round(stats(i).Centroid(2)), round(stats(i).Centroid(1))) == 1
                fly_indices = [fly_indices i];
            end
        end
        
        disp(fly_indices)
        return
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

        num_of_flies_over_time = [num_of_flies_over_time length(fly_indices)];
        if length(fly_indices) == 2

            fly_coords(1,:) = stats(fly_indices(1)).Centroid;
            fly_coords(2,:) = stats(fly_indices(2)).Centroid;

            if counter > 2
                new1_prev_1_vec = fly_coords(1,:) - fly_1_coords_over_time(counter-1,:);
                new2_prev_1_vec = fly_coords(2,:) - fly_1_coords_over_time(counter-1,:);
                
                old1_vec = fly_1_coords_over_time(counter-1,:) - fly_2_coords_over_time(counter-2,:);
                
                if dot(new1_prev_1_vec, old1_vec) > dot(new2_prev_1_vec, old1_vec)
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
            error(['No FLIES detected ' file.name ]) 
        end % if

        counter = counter + 1;
        
        return
    end % file

save('dist_over_time.mat', 'dist_over_time')
save('fly_1_coords_over_time.mat', 'fly_1_coords_over_time')
save('fly_2_coords_over_time.mat', 'fly_2_coords_over_time')
save('frames_to_see', 'frames_to_see')
save('cos_theta_over_time', 'cos_theta_over_time')
save('is_intersecting_over_time', 'is_intersecting_over_time')

disp('End of saving')






end