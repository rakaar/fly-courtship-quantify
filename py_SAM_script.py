import argparse
import save_SAM_segments  # Assuming this is your script

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run SAM model.')
    parser.add_argument('CHECKPOINT_PATH', type=str, help='Path to the checkpoint file')
    parser.add_argument('IMAGE_PATH', type=str, help='Path to the image file')

    args = parser.parse_args()

    save_SAM_segments.call_SAM(args.CHECKPOINT_PATH, args.IMAGE_PATH)
