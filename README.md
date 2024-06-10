# Demo

![Demo GIF](https://giphy.com/embed/SmU6EKQLVUkEgeAMhs)

# Usage
1. Install MATLAB with version >= 2015
2. Install FFMPEG
3. Install the required python requirements using `pip install -r requirements.txt`
4. Install [Meta's Segment Anything Model(SAM)](https://segment-anything.com/) as mentioned in its README
5. Install model checkpoint [ViT-B SAM model](https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth)
6. In `PARAMS.m` of this codebase. Change the paths as per your case
```
% ----- Filepaths ------
% folder for storing video frames
CONSTANTS.linux_output_folder_path = '/home/rka/code/fly_courtship/all_frames';
CONSTANTS.windows_output_folder_path = 'C:\Users\Diginest\Desktop\Output_Frames';

% SAN model weights path
CONSTANTS.linux_SAN_model_weights_path = '/home/rka/code/sam_try/sam_vit_b_01ec64.pth';
CONSTANTS.windows_SAN_model_weights_path = 'C:\Users\Diginest\Desktop\CS_Software_Resources\sam_vit_b_01ec64.pth';
```
7. Run `run_this.m` and select the folder containing videos


# Algorithm
1. Using FFMPEG, frames(images *.png) are extracted from the video
2. Using SAM, we extract each segments.
3. The file `find_arenas_from_SAM_segments` is run to extract Arenas from the segments. Briefly, circlular areas with segment centroid as center of different sizes are fit to each segments. Segments which show high correlation with those circular areas are seperated. Four such segments of similar area are extracted. The algorithm is implemented in `arenas_among_segments_algo.m`
4. Once the masks for each arena are obtained using SAM and the above mentioned algo, the user is shown all the four masks and asked if s/he wants to continue.
5. Now, in each arena flies are identied using simple color thresholding.
6. Labelled identified of flies is done with the assumption that new position of the fly will be close to the old position.
```matlab
old_fly_1_coords = fly_1_coords_over_time(counter-1,:);

if pdist([fly_coords(1,:); old_fly_1_coords]) < pdist([fly_coords(2,:); old_fly_1_coords])
    fly_1_coords_over_time = [fly_1_coords_over_time; fly_coords(1,:)];
    fly_2_coords_over_time = [fly_2_coords_over_time; fly_coords(2,:)];
else
    fly_1_coords_over_time = [fly_1_coords_over_time; fly_coords(2,:)];
    fly_2_coords_over_time = [fly_2_coords_over_time; fly_coords(1,:)];
end

else
    fly_1_coords_over_time = [fly_1_coords_over_time; fly_coords(1,:)];
    fly_2_coords_over_time = [fly_2_coords_over_time; fly_coords(2,:)];
end
```
7. In A time window of frames, courtship occurs if the path vectors of both the flies is interesecting and dot product is positive.
### TODO:
8. Now the problem is what to do in frames where flies are stationary. Male displays courtship behaviour using wing songs. We tried couple of things:

i. They are stationary only for a particular duration of time(say "T"). If stationary more than "T", then those windows do not contain courtship behaviour. This method FAILED because, each fly has its own "T". Some male flies do wing song longer than others.

ii. Wings also a particular color range. So, if we in a time window, we observe that number of pixels in that color range increases drastically, then it might be courtship. This is currently experimental. We have to decide two things here: a) Color range of the wings. b) when do you say the wing is visible based on the number of certain color ranged pixels over time. 




