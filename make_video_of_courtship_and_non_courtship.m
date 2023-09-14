clear;

% load data
mark_courtship = load('mark_courtship.mat').mark_courtship;
frameRate = 5; % Frames per second

% ------- Yes courtship ------
disp('Creating yes_courtship.avi');
outputVideoFilename = 'yes_courtship.avi'; % Name of the output video file

% Create a VideoWriter object
outputVideo = VideoWriter(outputVideoFilename);
outputVideo.FrameRate = frameRate;
open(outputVideo);

% Get list of PNG files
img_folder = 'all_frames/';
imgFiles = dir('all_frames/*.png');
numImages = length(imgFiles);

% Read each image and write it to the video

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
outputVideoFilename = 'no_courtship.avi'; % Name of the output video file

% Create a VideoWriter object
outputVideo = VideoWriter(outputVideoFilename);
outputVideo.FrameRate = frameRate;
open(outputVideo);

% Get list of PNG files
img_folder = 'all_frames/';
imgFiles = dir('all_frames/*.png');
numImages = length(imgFiles);

% Read each image and write it to the video

for k = 1:numImages
    if mark_courtship(k) == 0
        imgFilename = fullfile(img_folder,imgFiles(k).name);
        img = imread(imgFilename);
        writeVideo(outputVideo, img);
    end
end

% Close the video file
close(outputVideo);


