function frameNumber = extract_frame_num_from_filename(filename)
    % Extract the numeric part from the filename
    numStr = regexp(filename, '(\d+)', 'match');
    
    % Convert the numeric string to a number
    frameNumber = str2double(numStr{1});
end
