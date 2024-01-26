% TODO - function under construction
inputVideoPath = 'C:\path\to\your\video.ext'; % Replace with your video file path

% Construct the FFprobe command
ffprobeCommand = sprintf('ffprobe -v error -select_streams v -show_entries stream=avg_frame_rate -of default=noprint_wrappers=1:nokey=1 "%s"', inputVideoPath);

% Execute the command
[status, cmdout] = system(ffprobeCommand);

% Check if the command executed successfully and process the output
if status == 0
    % Split the output at the slash
    frameRateParts = strsplit(strtrim(cmdout), '/');
    
    % Take only the first part (numerator)
    frameRate = frameRateParts{1};
    
    disp(['Frame Rate: ', frameRate, ' fps']);
else
    disp('Failed to retrieve frame rate');
    disp(cmdout);
end
