clear;close all;clc;

% ####  Params  ####
% Algorithm parameters
defaultWindowLength = '10';
defaultWindowLimitForDistCondition = '20';
defaultStepSize = '5';
defaultToleranceLimitForNumFramesWithNoFlies = '50';

% Prompt for parameters
prompt = {'Window Length(in frames):', 'Window Limit for Dist Condition(in frames):', 'Step Size(in frames):', 'Tolerance Limit for Num Frames with No Flies(in frames):'};
dlgtitle = 'Input Parameters';
dims = [1 35];
definput = {defaultWindowLength, defaultWindowLimitForDistCondition, defaultStepSize, defaultToleranceLimitForNumFramesWithNoFlies};

answer = inputdlg(prompt, dlgtitle, dims, definput);

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

% Checkbox for asking if videos are needed
video_choice = questdlg('Do you want to process videos?', ...
    'Video Processing Selection', ...
    'YES', 'NO', 'NO');


% Output folder for frames generated using ffmpeg
if ~strcmp(computer, 'GLNXA64')
    output_folder = 'C:\Users\Diginest\Desktop\Output_Frames'; save('output_folder', 'output_folder');
else
    output_folder = '/home/rka/code/fly_courtship/all_frames'; save('output_folder', 'output_folder');
end


% SAM model weights path
if ~strcmp(computer, 'GLNXA64')
    CHECKPOINT_PATH = '/home/rka/code/sam_try\sam_vit_b_01ec64.pth';
else
    CHECKPOINT_PATH = '/home/rka/code/sam_try/sam_vit_b_01ec64.pth';
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

        % Use SAM to mark arenas
        disp('Running SAM model to segment areas. This may take a few minutes...')
        IMAGE_PATH_FOR_SAM = fullfile(output_folder, all_images(1).name);  % Set your image path
        commandStr = sprintf('python3 py_SAM_script.py %s %s', CHECKPOINT_PATH, IMAGE_PATH_FOR_SAM);
        [status, cmdout] = system(commandStr);

        if status == 0
            disp('Python script executed successfully');
            disp('Output:');
            disp(cmdout);
        else
            disp('Python script failed to run');
            disp('Error message:');
            disp(cmdout);
        end


        % find the ones that are Arenas
        find_arenas_from_SAM_segments;

        
        masks = zeros(4, size(first_img_gray,1), size(first_img_gray,2));
        masks(1,:,:) = load('ARENA1').mat;
        masks(2,:,:) = load('ARENA2').mat;
        masks(3,:,:) = load('ARENA3').mat;
        masks(4,:,:) = load('ARENA4').mat;


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
            disp('Skipping this video. Proceeding with next video...');
            continue; % Exit the script or function
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
            disp(['Courtship index for Arena number ' num2str(m) '(' circle_num_to_arena_id_map(m) ') is ' num2str(courtship_index)])
            save('mark_courtship', 'mark_courtship'); save('mark_courtship_zero_dist_max', 'mark_courtship_zero_dist_max');save('cos_theta_over_time', 'cos_theta_over_time'); save('is_intersecting_over_time', 'is_intersecting_over_time');
            
            if strcmp(video_choice, 'YES')
                make_videos(mark_courtship, mark_courtship_zero_dist_max, output_folder, video_path, m);
            end
            
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

% --- Remove all .mat files ---
matFiles = dir('*.mat');

for k = 1:length(matFiles)
    delete(matFiles(k).name);
end
