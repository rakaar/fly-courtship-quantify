clear;close all;clc;

% --- Params ---
% WINDOWS
if ~strcmp(computer, 'GLNXA64')
    output_folder = 'C:\Users\Diginest\Desktop\Output_Frames'; save('output_folder', 'output_folder');
else
    output_folder = '/home/rka/code/fly_courtship/all_frames'; save('output_folder', 'output_folder');
end
circleRadius = 130;

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
data = cell(num_files, 3); % 3 columns: filename, 0, 0

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
        first_img_gray = imread(fullfile(output_folder, all_images(1).name));
        % convery to gray scale
        % first_img_gray = rgb2gray(first_img);
        
        % TODO - for now load circles from SAM
        c1 = load('c1').mat;
        c2 = load('c2').mat;
        c3 = load('c3').mat;
        c4 = load('c4').mat;

        % masks
        c1_new = make_circle_proper(c1);
        c2_new = make_circle_proper(c2);
        c3_new = make_circle_proper(c3);
        c4_new = make_circle_proper(c4);



        masks = zeros(4, size(first_img_gray,1), size(first_img_gray,2));
        masks(1,:,:) = c1_new;
        masks(2,:,:) = c2_new;
        masks(3,:,:) = c3_new;
        masks(4,:,:) = c4_new;


        % TODO - uncomment - testing
        figure;
        sgtitle('If you want to continue with these identified arenas, type "yes"');
        for m = 1:4
            subplot(2,2,m)
            imagesc(squeeze(masks(m,:,:)).*double(first_img_gray))
            title(num2str(m))
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
            find_flies(output_folder, indiv_mask, area_indiv_mask);
        end
        return
       
        % TODO
        % 1. keep ffmpeg outside
        % 2. read_all_images_and_identify_flies is a func which takes "mask" as one of parameter
        % 3. use circle_identify_flies_in_marked_arena code to detect boundaries 
        % 4. Yes or no if circles idenitfied correctly
        disp('########### Identify flies and mark their positions###########')
        read_all_images_and_identify_flies;

        disp(' ########### Mark courtship Frames ###########')
        mark_courtship_all1algo;

        disp('########## Writing to excel sheet #############')
        video_path = load('video_path');
        video_path=video_path.video_path;

        [~, video_name, ext] = fileparts(video_path);
        courtship_frame_num = load('courtship_frame_num');
        courtship_frame_num=courtship_frame_num.courtship_frame_num;
        courtship_index = load('courtship_index');
        courtship_index=courtship_index.courtship_index;
        
        data{avi_f, 1} = video_name;
        data{avi_f, 2} = courtship_frame_num;
        data{avi_f, 3} = courtship_index;
        

        disp(' ########## Make Video ##########')
        make_video_of_courtship_and_non_courtship;

    end

    % WINDOWS
    % xlswrite('results.xlsx', data);
    writecell(data, 'results.xlsx');

