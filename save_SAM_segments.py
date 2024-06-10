# All in one
import numpy as np
import cv2
# import torch
from segment_anything import sam_model_registry, SamAutomaticMaskGenerator, SamPredictor
from skimage.measure import perimeter
print('1/4 Imports Done')


def call_SAM(CHECKPOINT_PATH, IMAGE_PATH):
    # SAM params
    # CHECKPOINT_PATH='/home/rka/code/sam_try/sam_vit_b_01ec64.pth'
    # DEVICE = torch.device('cuda:0' if torch.cuda.is_available() else 'cpu')
    MODEL_TYPE = "vit_b"
    # sam = sam_model_registry[MODEL_TYPE](checkpoint=CHECKPOINT_PATH).to(device=DEVICE)
    sam = sam_model_registry[MODEL_TYPE](checkpoint=CHECKPOINT_PATH)
    mask_generator = SamAutomaticMaskGenerator(sam)
    print('2/4 SAM params Initialized')

    # SAM result
    # IMAGE_PATH = '/home/rka/code/fly_courtship/all_frames/frame_0001.png'
    image = cv2.imread(IMAGE_PATH)
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    # SAM
    sam_result = mask_generator.generate(image_rgb)
    print('3/4 SAM result generated')

    # Save MAT
    from scipy.io import savemat
    for i in range(len(sam_result)):
        arena_mask = sam_result[i]['segmentation']
        area = sam_result[i]['area']
        savemat(f"c{i+1}.mat", {'segment': arena_mask, 'area': area})
    print('4/4 Saved mat files')