clear;close all;clc;

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
        input_video_path = fullfile(avi_files(avi_f).folder, avi_files(avi_f).name);
        disp(['Input video path: ' input_video_path]);
        % TODO
        % 1. keep ffmpeg outside
        % 2. read_all_images_and_identify_flies is a func which takes "mask" as one of parameter
        % 3. use circle_identify_flies_in_marked_arena code to detect boundaries 
        disp('########### Identify flies and mark their positions###########')
        read_all_images_and_identify_flies;

        disp(' ########### Mark courtship Frames ###########')
        mark_courtship_all1algo;

        disp('########## Writing to excel sheet #############')
        video_path = load('video_path').video_path;

        [~, video_name, ext] = fileparts(video_path);
        courtship_frame_num = load('courtship_frame_num').courtship_frame_num;
        courtship_index = load('courtship_index').courtship_index;
        
        data{avi_f, 1} = video_name;
        data{avi_f, 2} = courtship_frame_num;
        data{avi_f, 3} = courtship_index;
        

        disp(' ########## Make Video ##########')
        make_video_of_courtship_and_non_courtship;

    end

    writecell(data, 'results.xlsx');
