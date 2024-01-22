clear;close all;clc;

% --- Params ---
% WINDOWS
if ~strcmp(computer, 'GLNXA64')
    output_folder = 'C:\Users\Diginest\Desktop\Output_Frames'; save('output_folder', 'output_folder');
else
    output_folder = '/home/rka/code/fly_courtship/all_frames'; save('output_folder', 'output_folder');
end

window_length = 5*2;
window_limit_for_dist_condition = 2*window_length;
step_size = 5*1;
tolerance_limit_for_num_frames_with_no_flies = 50;

disp('########## Select Folder ###########')
% Prompt user to select a folder
folder_path = uigetdir;

% Check if the user pressed 'Cancel'
if folder_path == 0
    disp('User pressed cancel.');
    return
end

% Get a list of all .avi files in the selected folder
avi_files = dir(fullfile(folder_path, '*.avi'));

% Check if there are any .avi files in the folder
if isempty(avi_files)
    disp('No .avi files found in the selected folder.');
    return
end


num_files = length(avi_files);
% data = cell(num_files, 3); % 3 columns: filename, 0, 0
% Initialize a completely empty cell array
data = cell(0, 4); % video name, arena id, courtship index, num of frames with no flies
data_row_index = 1;
    % Display paths of all .avi files
    for avi_f = 1:length(avi_files)
        disp(['Video # ' num2str(avi_f) '/' num2str(length(avi_files))]);
        video_path = fullfile(folder_path, avi_files(avi_f).name);
        disp(['Input video path: ' video_path]);
        
        % convert video at 'video_path' to frames and dump in 'output_folder'
        % TODO = ONLY 4 QUICK TESTING
        % video_to_frames(video_path, output_folder)
        
        

        % load first image from output_folder
        all_images = dir(fullfile(output_folder, '*.png'));
        first_img = imread(fullfile(output_folder, all_images(1).name));
        % convery to gray scale
        if length(size(first_img)) == 3
            first_img_gray = rgb2gray(first_img);
        else
            first_img_gray = first_img;
        end
        % first_img_gray = rgb2gray(first_img);
        
        % TODO - for now load circles from SAM
        c1 = load('c1').mat;
        c2 = load('c2').mat;
        c3 = load('c3').mat;
        c4 = load('c4').mat;

        

        masks = zeros(4, size(first_img_gray,1), size(first_img_gray,2));
        % masks(1,:,:) = c1_new;
        % masks(2,:,:) = c2_new;
        % masks(3,:,:) = c3_new;
        % masks(4,:,:) = c4_new;

        masks(1,:,:) = c1;
        masks(2,:,:) = c2;
        masks(3,:,:) = c3;
        masks(4,:,:) = c4;


        % get mappings from circle Ci to Arena identity(A,B,C,D)
        
        circle_num_to_arena_id_map = get_circle_num_to_arena_id_map(masks);

        % TODO - uncomment - testing
        figure;
        sgtitle('If you want to continue with these identified arenas, type "yes"');
        for m = 1:4
            subplot(2,2,m)
            imagesc(squeeze(masks(m,:,:)).*double(first_img_gray))
            title([num2str(m) ' Arena id = ' circle_num_to_arena_id_map(m)])
        end
        
        
        % Prompt user for input
        userInput = input('Do you want to proceed? Type "yes" to continue: ', 's');

        % Convert input to lower case for case-insensitive comparison
        userInput = lower(userInput);

        % Check the user input
        if strcmp(userInput, 'yes')
            disp('Proceeding with the program...');
            close all;
        else
            disp('Aborting the program.');
            return; % Exit the script or function
        end

        
        for m = 1:4
            indiv_mask = squeeze(masks(m,:,:));
            area_indiv_mask = sum(indiv_mask(:));
            % [fly_1_coords_over_time, fly_2_coords_over_time, dist_over_time, cos_theta_over_time, is_intersecting_over_time, are_flies_present] = find_flies(output_folder, indiv_mask, area_indiv_mask);
            [fly_1_coords_over_time, fly_2_coords_over_time, dist_over_time, are_flies_present, num_of_frames_with_no_flies] = find_flies_dist_based(output_folder, indiv_mask, area_indiv_mask, tolerance_limit_for_num_frames_with_no_flies);
            
            if are_flies_present == 0
                disp(['No flies detected in Arena number ' num2str(m)])
                continue
            end
            save('fly_1_coords_over_time', 'fly_1_coords_over_time'); save('fly_2_coords_over_time', 'fly_2_coords_over_time'); save('dist_over_time', 'dist_over_time'); 
            [courtship_index, courtship_frame_num, mark_courtship, mark_courtship_zero_dist_max, is_intersecting_over_time, cos_theta_over_time] = courtship_algo(fly_1_coords_over_time, fly_2_coords_over_time, dist_over_time, output_folder, window_length, window_limit_for_dist_condition, step_size);
            disp(['Courtship index for Arena number ' num2str(m) ' is ' num2str(courtship_index)])
            save('mark_courtship', 'mark_courtship'); save('mark_courtship_zero_dist_max', 'mark_courtship_zero_dist_max');save('cos_theta_over_time', 'cos_theta_over_time'); save('is_intersecting_over_time', 'is_intersecting_over_time');
            % TODO - to save time, commented
            % make_videos(mark_courtship, mark_courtship_zero_dist_max, output_folder, video_path, m);

            [~, video_name, ~] = fileparts(video_path);
            arena_name = circle_num_to_arena_id_map(m);

            % Populate the cell array
            data{data_row_index, 1} = video_name;
            data{data_row_index, 2} = arena_name;
            data{data_row_index, 3} = courtship_index;
            data{data_row_index, 4} = num_of_frames_with_no_flies;

            data_row_index = data_row_index + 1;
        end
       
        
    end

    % Convert the cell array to a table
    dataTable = cell2table(data, 'VariableNames', {'VideoName', 'ArenaName', 'CourtshipIndex', 'NumOfFramesWithNoFlies'});

    % Write the table to an Excel file
    filename = 'output.xlsx'; % Specify your Excel file name
    writetable(dataTable, filename);

    % WINDOWS
    % xlswrite('results.xlsx', data);
    % writecell(data, 'results.xlsx');

