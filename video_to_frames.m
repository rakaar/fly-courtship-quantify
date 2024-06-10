function video_to_frames(video_path, output_folder)
    current_dir = pwd;

    % WINDOWS
    if ~strcmp(computer, 'GLNXA64')
        ffmpeg_dir = 'E:\General Softwares\FFMPEG_Folder';
    end
    

    % ffmpeg command
    output_folder = fullfile(output_folder, 'frame_%04d.png');
    % WINOWS
    if ~strcmp(computer, 'GLNXA64')
        ffmpeg_command_format = 'ffmpeg -i %s %s';
    else
        ffmpeg_command_format = 'LD_LIBRARY_PATH="" ffmpeg -i %s %s';
    end
    
    ffmpeg_command = sprintf(ffmpeg_command_format, video_path, output_folder);
    % WINDOWS
    if ~strcmp(computer, 'GLNXA64')
        cd(ffmpeg_dir)
    end
    
    [status, cmdout] = system(ffmpeg_command);
    cd(current_dir)
    if status == 0
        disp('Frames extracted successfully.');
    else
        disp(cmdout); % Display the error message
        error('Error extracting frames.');
    
    end

end