function make_videos(mark_courtship, mark_courtship_zero_dist_max, output_folder, video_path, video_id)
    
    img_folder = output_folder;
    if strcmp(computer, 'GLNXA64')
        imgFiles = dir([output_folder '/*.png']);
    else
        imgFiles = dir([output_folder '\*.png']);
    end
    
    numImages = length(imgFiles);
    [~, video_name, ~] = fileparts(video_path);
    
    frameRate = 5; % Frames per second
    
    % ------- Yes courtship ------
    disp('Creating yes_courtship.avi');
    outputVideoFilename = [video_name '_' num2str(video_id) '_yes_courtship.avi']; % Name of the output video file
    
    % Create a VideoWriter object
    outputVideo = VideoWriter(outputVideoFilename);
    outputVideo.FrameRate = frameRate;
    open(outputVideo);
    
    for k = 1:numImages
        if mark_courtship(k) == 1
            imgFilename = fullfile(img_folder,imgFiles(k).name);
            img = imread(imgFilename);
            writeVideo(outputVideo, img);
        end
    end
    
    % Close the video file
    close(outputVideo);
    
    % -----------  No courtship ------------
    disp('Creating no_courtship.avi');
    outputVideoFilename = [video_name '_' num2str(video_id) '_no_courtship.avi']; % Name of the output video file
    
    % Create a VideoWriter object
    outputVideo = VideoWriter(outputVideoFilename);
    outputVideo.FrameRate = frameRate;
    open(outputVideo);
    
    for k = 1:numImages
        if mark_courtship(k) == 0
            imgFilename = fullfile(img_folder,imgFiles(k).name);
            img = imread(imgFilename);
            writeVideo(outputVideo, img);
        end
    end
    
    % Close the video file
    close(outputVideo);
    
    
    
    % ----------------- Yes, zero distance max ------------
    disp('Creating yes_only_close_dist_criteria.avi');
    outputVideoFilename = [video_name '_' num2str(video_id) '_yes_only_close_dist_criteria.avi']; % Name of the output video file
    
    % Create a VideoWriter object
    outputVideo = VideoWriter(outputVideoFilename);
    outputVideo.FrameRate = frameRate;
    open(outputVideo);
    
    for k = 1:numImages
        if mark_courtship_zero_dist_max(k) == 1
            imgFilename = fullfile(img_folder,imgFiles(k).name);
            img = imread(imgFilename);
            writeVideo(outputVideo, img);
        end
    end
    
    % Close the video file
    close(outputVideo);
    
    
end