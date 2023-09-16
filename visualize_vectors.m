clear;clc;close all;

dist_over_time = load('dist_over_time').dist_over_time;
fly_1_coords_over_time = load('fly_1_coords_over_time').fly_1_coords_over_time;
fly_2_coords_over_time = load('fly_2_coords_over_time').fly_2_coords_over_time;

images_path = '/home/rka/code/fly_courtship/all_frames/';

files = dir('all_frames/*.png');
counter = 0;

frames_to_see = load('frames_to_see').frames_to_see;
window_num = 0;

% Comment this when not Visualizing any particular type of windows
windows_with_courtship = load('windows_with_courtship').windows_with_courtship;
for file = files'
   

    if mod(counter, frames_to_see) == 0 && counter + frames_to_see < length(files)
        window_num = window_num + 1;
        % visualize only non-courtship windows
        % disp(['Window num ' num2str(window_num) ' window val ' num2str(windows_with_courtship(window_num))])
        % if windows_with_courtship(window_num) == 1
        %     continue
        % end
        

        disp(['Processing file ' file.name])
        % read image
        img = imread(strcat('all_frames/', file.name));

        
        
        % dist over time copy
        
        subplot(1,2,1)
        hold on
            plot(fly_1_coords_over_time(counter+1:counter+frames_to_see,1), fly_1_coords_over_time(counter+1:counter+frames_to_see,2), 'b')
            plot(fly_2_coords_over_time(counter+1:counter+frames_to_see,1), fly_2_coords_over_time(counter+1:counter+frames_to_see,2), 'r')

            % vectors
            % Calculate the dx and dy for both flies
            dx1 = fly_1_coords_over_time(counter+frames_to_see,1) - fly_1_coords_over_time(counter+1,1);
            dy1 = fly_1_coords_over_time(counter+frames_to_see,2) - fly_1_coords_over_time(counter+1,2);

            dx2 = fly_2_coords_over_time(counter+frames_to_see,1) - fly_2_coords_over_time(counter+1,1);
            dy2 = fly_2_coords_over_time(counter+frames_to_see,2) - fly_2_coords_over_time(counter+1,2);

            % Plotting the sum of vectors using quiver for fly 1
            quiver(fly_1_coords_over_time(counter+1,1), fly_1_coords_over_time(counter+1,2), dx1, dy1, 0, 'b', 'LineWidth', 1.5, 'MaxHeadSize', 0.5)

            % Plotting the sum of vectors using quiver for fly 2
            quiver(fly_2_coords_over_time(counter+1,1), fly_2_coords_over_time(counter+1,2), dx2, dy2, 0, 'r', 'LineWidth', 1.5, 'MaxHeadSize', 0.5)

            
            % -----------1. Angle between them is acute,  dot product is positive
            % Calculate dot product
            dotProduct = dx1 * dx2 + dy1 * dy2;

            % Calculate magnitudes
            mag1 = sqrt(dx1^2 + dy1^2);
            mag2 = sqrt(dx2^2 + dy2^2);

            % Find cosine of angle
            cosTheta = dotProduct / (mag1 * mag2); % positive for acute, negative for obtuse

            % -------------2. Intersection of 2 vectors ----------------------
            % Define the vectors and points
            P1 = [fly_1_coords_over_time(counter+1,1), fly_1_coords_over_time(counter+1,2)];
            P2 = [fly_2_coords_over_time(counter+1,1), fly_2_coords_over_time(counter+1,2)];

            v1 = [dx1, dy1];
            v2 = [dx2, dy2];

            % Determine intersection
            A = [v1', -v2'];
            b = P2 - P1;
            
            is_intersecting = 0;
            if rank(A) < 2
                disp('Lines are parallel or coincident.');
            else
                ts = A\b';
                
                % t and s are ts(1) and ts(2) respectively
                if 0 <= ts(1) && ts(1) <= 1 && 0 <= ts(2) && ts(2) <= 1
                    is_intersecting = 1;
                    % intersectionPoint = P1 + ts(1) * v1;
                    % disp(['The lines intersect at point (', num2str(intersectionPoint(1)), ', ', num2str(intersectionPoint(2)), ').']);
                end
            end


            % --- Check both above conditions---

            % Highlight the first point for each fly
            plot(fly_1_coords_over_time(counter+1,1), fly_1_coords_over_time(counter+1,2), 'bo', 'MarkerSize', 10, 'LineWidth', 2)
            plot(fly_2_coords_over_time(counter+1,1), fly_2_coords_over_time(counter+1,2), 'ro', 'MarkerSize', 10, 'LineWidth', 2)
        hold off
        title([num2str((counter+1)*0.2) ' TO ' num2str((counter+frames_to_see)*0.2) ' seconds' ' - cos theta = (' num2str(cosTheta) '), is Intersecting ' num2str(is_intersecting) ' courtship marked = ' num2str(windows_with_courtship(window_num))])

        subplot(1,2,2)
        % Display images in a loop
        
        imshow(img)
        hold on
        % Coordinates for the two flies at time counter+1
        coords_fly1 = fly_1_coords_over_time(counter+1,:);
        coords_fly2 = fly_2_coords_over_time(counter+1,:);

        % Marking the coordinates with text
        text(coords_fly1(1), coords_fly1(2), '1', 'Color', 'b', 'FontSize', 20, 'FontWeight', 'bold');
        text(coords_fly2(1), coords_fly2(2), '2', 'Color', 'r', 'FontSize', 20, 'FontWeight', 'bold');
        hold off

        title([ 'frame ' file.name])

        pause
        clf;
        
    end
    counter = counter + 1; % if one by one
    
    
end