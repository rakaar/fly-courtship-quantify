clear;close all;clc;

% ####  Params  ####
PARAMS;

% Algorithm parameters
defaultWindowLength = num2str(CONSTANTS.defaultWindowLength);
defaultWindowLimitForDistCondition = num2str(CONSTANTS.defaultWindowLimitForDistCondition);
defaultStepSize = num2str(CONSTANTS.defaultStepSize);
defaultToleranceLimitForNumFramesWithNoFlies = num2str(CONSTANTS.defaultToleranceLimitForNumFramesWithNoFlies);
default_thresold_pixel_distance = num2str(CONSTANTS.default_thresold_pixel_distance);
default_stationary_pixel_distance = num2str(CONSTANTS.default_stationary_pixel_distance);
default_window_len_for_stationary_parts = num2str(CONSTANTS.default_window_len_for_stationary_parts);
default_range_pixels_for_wing_song = num2str(CONSTANTS.default_range_pixels_for_wing_song);

% Prompt for parameters
prompt = {'Window Length(in frames):', 'Window Limit for Dist Condition(in frames):', 'Step Size(in frames):', 'Tolerance Limit for Num Frames with No Flies(in frames):', 'Threshold Pixel Distance:', 'Stationary Pixel Distance:', 'Window Length for analysing Stationary Parts: ', 'Min Range of Pixels for wing song detection: '};
dlgtitle = 'Algorithm Parameters';
definput = {defaultWindowLength, defaultWindowLimitForDistCondition, defaultStepSize, defaultToleranceLimitForNumFramesWithNoFlies, default_thresold_pixel_distance, default_stationary_pixel_distance, default_window_len_for_stationary_parts, default_range_pixels_for_wing_song};

answer = inputdlg(prompt, dlgtitle, 1,  definput);

% Check if the user pressed cancel
if isempty(answer)
    disp('User cancelled the operation.');
    return;
end

% Extract values from dialog box
window_length = str2double(answer{1});
window_limit_for_dist_condition = str2double(answer{2});
step_size = str2double(answer{3});
tolerance_limit_for_num_frames_with_no_flies = str2double(answer{4});
thresold_pixel_distance = str2double(answer{5});
stationary_pixel_distance = str2double(answer{6});
window_len_for_stationary_parts = str2double(answer{7});
range_pixels_for_wing_song = str2double(answer{8});

% Checkbox for asking if videos are needed
video_choice = questdlg('Do you want to process videos?', ...
    'Video Processing Selection', ...
    'YES', 'NO', 'NO');


% Output folder for frames generated using ffmpeg
if ~strcmp(computer, 'GLNXA64')
    output_folder = CONSTANTS.windows_output_folder_path; save('output_folder', 'output_folder');
else
    output_folder = CONSTANTS.linux_output_folder_path; save('output_folder', 'output_folder');
end


% SAM model weights path
if ~strcmp(computer, 'GLNXA64')
    CHECKPOINT_PATH = CONSTANTS.windows_SAN_model_weights_path;
else
    CHECKPOINT_PATH = CONSTANTS.linux_SAN_model_weights_path;
end


disp('########## Select Folder with Fly videos ###########')
folder_path = uigetdir([], 'Select Folder with Courtship Videos');
if folder_path == 0
    disp('User pressed cancel.');
    return
end

% ####  Checking if there are .avi files  ####
avi_files = dir(fullfile(folder_path, '*.avi'));
if isempty(avi_files)
    disp('No .avi files found in the selected folder.');
    return
end
num_files = length(avi_files);

% ####  Data  ####
data = cell(0, 4); % 1-video name, 2-arena id, 3-courtship index, 4-num of frames with no flies
data_row_index = 1;
    % Display paths of all .avi files
    for avi_f = 1:length(avi_files)
        disp(['Video # ' num2str(avi_f) '/' num2str(length(avi_files))]);
        video_path = fullfile(folder_path, avi_files(avi_f).name);
        disp(['Input video path: ' video_path]);
        
        % TODO      
        % convert video at 'video_path' to frames and dump in 'output_folder'
        disp('FFMPEG: Converting video to frames. This may take few seconds...')
        video_to_frames(video_path, output_folder) 
        
        
        % load first image from output_folder
        all_images = dir(fullfile(output_folder, '*.png'));
        first_img = imread(fullfile(output_folder, all_images(1).name));

        % convery to gray scale
        if length(size(first_img)) == 3
            first_img_gray = rgb2gray(first_img);
        else
            first_img_gray = first_img;
        end
        
        
        % remove c*.mat files to avoid confusion
        matFiles = dir('c*.mat');
        for k = 1:length(matFiles)
            delete(matFiles(k).name);
        end

        % TODO
        % Use SAM to mark arenas
        disp('Running SAM model to segment areas. This may take a few minutes...')
         IMAGE_PATH_FOR_SAM = fullfile(output_folder, all_images(1).name);  % Set your image path
         commandStr = sprintf('python3 py_SAM_script.py %s %s', CHECKPOINT_PATH, IMAGE_PATH_FOR_SAM);
         [status, cmdout] = system(commandStr);

        % TODO
         if status == 0
             disp('Python script executed successfully');
             disp('Output:');
             disp(cmdout);
         else
             disp('Python script failed to run');
             disp('Error message:');
             disp(cmdout);
         end

        % TODO
        % find the ones that are Arenas
         find_arenas_from_SAM_segments;

        
        masks = zeros(4, size(first_img_gray,1), size(first_img_gray,2));
        ARENA1 = load('ARENA1'); ARENA2 = load('ARENA2'); ARENA3 = load('ARENA3'); ARENA4 = load('ARENA4');
        masks(1,:,:) = ARENA1.mat;
        masks(2,:,:) = ARENA2.mat;
        masks(3,:,:) = ARENA3.mat;
        masks(4,:,:) = ARENA4.mat;


        % get mappings from circle Ci to Arena identity(A,B,C,D)
        circle_num_to_arena_id_map = get_circle_num_to_arena_id_map(masks);

        % TODO - uncomment - testing
        figure;
        annotation('textbox', [0.5, 0.98, 0, 0], 'String', 'If you want to continue with these identified arenas, type "yes"', 'HorizontalAlignment', 'center', 'EdgeColor', 'none');
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
            disp('Skipping this video. Proceeding with next video...');
            continue; % Exit the script or function
        end

        % TODO
        for m = 1:4
            indiv_mask = squeeze(masks(m,:,:));
            area_indiv_mask = sum(indiv_mask(:));
            % [fly_1_coords_over_time, fly_2_coords_over_time, dist_over_time, cos_theta_over_time, is_intersecting_over_time, are_flies_present] = find_flies(output_folder, indiv_mask, area_indiv_mask);
            [fly_1_coords_over_time, fly_2_coords_over_time, dist_over_time, are_flies_present, num_of_frames_with_no_flies] = find_flies_dist_based(output_folder, indiv_mask, area_indiv_mask, tolerance_limit_for_num_frames_with_no_flies);

	    [~, video_name, ~] = fileparts(video_path);
            arena_name = circle_num_to_arena_id_map(m);
	    
            if are_flies_present == 0
                disp(['No flies detected in Arena number ' num2str(m)])
                data{data_row_index, 1} = video_name;
                data{data_row_index, 2} = arena_name;
                data{data_row_index, 3} = 'NO FLIES';
                data{data_row_index, 4} = num_of_frames_with_no_flies;

                data_row_index = data_row_index + 1;
                continue
            end
            save('fly_1_coords_over_time', 'fly_1_coords_over_time'); save('fly_2_coords_over_time', 'fly_2_coords_over_time'); save('dist_over_time', 'dist_over_time'); 
            [courtship_index, courtship_frame_num, mark_courtship, mark_courtship_zero_dist_max, is_intersecting_over_time, cos_theta_over_time, stationary_frames] = courtship_algo_TRIAL(fly_1_coords_over_time, fly_2_coords_over_time, dist_over_time, output_folder, window_length, window_limit_for_dist_condition, step_size, thresold_pixel_distance, stationary_pixel_distance);

			% process stationary frames
			[courtship_stationary_frames, new_courtship_frame_num] = calc_num_of_courtship_frames_from_stationary_frames(stationary_frames, output_folder, indiv_mask, window_len_for_stationary_parts, range_pixels_for_wing_song);

			courtship_index = (str2double(courtship_frame_num) + new_courtship_frame_num)/length(courtship_stationary_frames);
			
            disp(['Courtship index for Arena number ' num2str(m) '(' circle_num_to_arena_id_map(m) ') is ' num2str(courtship_index)])
            save('mark_courtship', 'mark_courtship'); save('mark_courtship_zero_dist_max', 'mark_courtship_zero_dist_max');save('cos_theta_over_time', 'cos_theta_over_time'); save('is_intersecting_over_time', 'is_intersecting_over_time');
            
            if strcmp(video_choice, 'YES')
                make_videos(mark_courtship, courtship_stationary_frames, output_folder, video_path, m, circle_num_to_arena_id_map, stationary_frames);
            end
            

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

% --- Remove all .mat files ---
matFiles = dir('*.mat'); 

% TODO
 for k = 1:length(matFiles)
     delete(matFiles(k).name);
 end