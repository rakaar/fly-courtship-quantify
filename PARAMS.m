CONSTANTS = struct;

% ----- ALGO PARAMS -------
CONSTANTS.defaultWindowLength = 10;
CONSTANTS.defaultWindowLimitForDistCondition = 20;
CONSTANTS.defaultStepSize = 2;
CONSTANTS.defaultToleranceLimitForNumFramesWithNoFlies = 50;

CONSTANTS.default_thresold_pixel_distance = 50;
CONSTANTS.default_stationary_pixel_distance = 10;

CONSTANTS.default_window_len_for_stationary_parts = 10;
CONSTANTS.default_range_pixels_for_wing_song = 150;

% ---- GUI params -----
CONSTANTS.GUI_dims = [1 35];

% ----- Filepaths ------
% folder for storing video frames
CONSTANTS.linux_output_folder_path = '/home/rka/code/fly_courtship/all_frames';
CONSTANTS.windows_output_folder_path = 'C:\Users\Diginest\Desktop\Output_Frames';

% SAN model weights path
CONSTANTS.linux_SAN_model_weights_path = '/home/rka/code/sam_try/sam_vit_b_01ec64.pth';
CONSTANTS.windows_SAN_model_weights_path = 'C:\Users\Diginest\Desktop\CS_Software_Resources\sam_vit_b_01ec64.pth';


