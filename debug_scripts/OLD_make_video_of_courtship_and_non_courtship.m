output_folder = load('output_folder.mat');
output_folder=output_folder.output_folder;
img_folder = output_folder;
imgFiles = dir([output_folder '\*.png']);
numImages = length(imgFiles);

% load data
mark_courtship = load('mark_courtship.mat');
mark_courtship=mark_courtship.mark_courtship;
mark_courtship_zero_dist_max = load('mark_courtship_zero_dist_max');
mark_courtship_zero_dist_max=mark_courtship_zero_dist_max.mark_courtship_zero_dist_max;

% video_name
video_path = load('video_path');
video_path=video_path.video_path;
[~, video_name, ext] = fileparts(video_path);

frameRate = 5; % Frames per second

% ------- Yes courtship ------
disp('Creating yes_courtship.avi');
outputVideoFilename = [video_name '_yes_courtship.avi']; % Name of the output video file

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
outputVideoFilename = [video_name '_no_courtship.avi']; % Name of the output video file

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
outputVideoFilename = [video_name '_yes_only_close_dist_criteria.avi']; % Name of the output video file

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

