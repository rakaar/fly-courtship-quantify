% Set the path to the video file
video_path = 'sample.avi';

% Create the output directory if it doesn't exist
output_dir = 'all_frames';
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Read the video file
video = VideoReader(video_path);

% Loop through each frame of the video
frame_num = 1;
while hasFrame(video)
    % Read the current frame
    frame = readFrame(video);
    
    % Write the frame to a file in the output directory
    output_path = fullfile(output_dir, sprintf('frame_%04d.png', frame_num));
    imwrite(frame, output_path);
    disp(['Wrote frame ' num2str(frame_num)])
    
    % Increment the frame number
    frame_num = frame_num + 1;
end
