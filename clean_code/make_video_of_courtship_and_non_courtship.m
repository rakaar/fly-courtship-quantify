clear;

output_folder = load('output_folder.mat').output_folder;
img_folder = output_folder;
imgFiles = dir([output_folder '/*.png']);
numImages = length(imgFiles);

% load data
mark_courtship = load('mark_courtship.mat').mark_courtship;
mark_courtship_zero_dist_max = load('mark_courtship_zero_dist_max').mark_courtship_zero_dist_max;

frameRate = 5; % Frames per second

% ------- Yes courtship ------
disp('Creating yes_courtship.avi');
outputVideoFilename = 'yes_courtship.avi'; % Name of the output video file

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
outputVideoFilename = 'no_courtship.avi'; % Name of the output video file

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
disp('Creating yes_zero_max_courtship.avi');
outputVideoFilename = 'yes_zero_max_courtship.avi'; % Name of the output video file

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

