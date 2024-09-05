import os
import torch
import numpy as np
import cv2
import subprocess
import pickle
from tqdm import tqdm
from PIL import Image
from functools import partial
from models import Wav2Lip
from batch_face import RetinaFace
from enhance import upscale, load_sr
from easy_functions import load_model
import argparse

device = 'cuda'
parser = argparse.ArgumentParser(description='Lip-sync video with Wav2Lip')

parser.add_argument('--checkpoint_path', type=str, required=True)
parser.add_argument('--face', type=str, required=True)
parser.add_argument('--audio', type=str, required=True)
parser.add_argument('--outfile', type=str, default='results/result_voice.mp4')
parser.add_argument('--static', type=bool, default=False)
parser.add_argument('--fps', type=float, default=25., required=False)
parser.add_argument('--pads', nargs='+', type=int, default=[0, 10, 0, 0])
parser.add_argument('--wav2lip_batch_size', type=int, default=1)
parser.add_argument('--crop', nargs='+', type=int, default=[0, -1, 0, -1])
parser.add_argument('--rotate', default=False, action='store_true')
parser.add_argument('--no_sr', default=False, action='store_true')
parser.add_argument('--sr_model', type=str, default='gfpgan', required=False)

with open(os.path.join('checkpoints', 'predictor.pkl'), 'rb') as f:
    predictor = pickle.load(f)
with open(os.path.join('checkpoints', 'mouth_detector.pkl'), 'rb') as f:
    mouth_detector = pickle.load(f)

def load_wav2lip(checkpoint_path):
    if device == 'cuda':
        checkpoint = torch.load(checkpoint_path)
    else:
        checkpoint = torch.load(checkpoint_path, map_location='cpu')
    return checkpoint

def face_detect(images):
    results = []
    pady1, pady2, padx1, padx2 = args.pads
    for image, rect in zip(images, face_rect(images)):
        if rect:
            y1, y2 = max(0, rect[1] - pady1), min(image.shape[0], rect[3] + pady2)
            x1, x2 = max(0, rect[0] - padx1), min(image.shape[1], rect[2] + padx2)
            results.append([x1, y1, x2, y2])
    return np.array(results)

def datagen(frames, mels):
    face_det_results = face_detect(frames if not args.static else [frames[0]])
    for i, m in enumerate(mels):
        idx = 0 if args.static else i % len(frames)
        face, coords = face_det_results[idx]
        img_batch = np.asarray([cv2.resize(frames[idx], (args.img_size, args.img_size))])
        mel_batch = np.reshape(m, [1, m.shape[1], m.shape[2], 1])
        yield img_batch / 255., mel_batch, [frames[idx]], [coords]

def main():
    args.img_size = 96
    full_frames = [cv2.imread(args.face)] if args.static else extract_frames(args.face)
    fps = args.fps if args.static else get_fps(args.face)
    
    audio_path = convert_audio(args.audio)
    wav = load_wav(audio_path)
    mel = audio.melspectrogram(wav)
    mel_chunks = [mel[:, i:i + mel_step_size] for i in range(0, len(mel[0]), mel_step_size)]
    full_frames = full_frames[:len(mel_chunks)]
    
    gen = datagen(full_frames, mel_chunks)
    out_video(fps, full_frames[0], args.outfile, gen)

def extract_frames(video_path):
    frames = []
    video_stream = cv2.VideoCapture(video_path)
    while True:
        still_reading, frame = video_stream.read()
        if not still_reading:
            break
        frames.append(frame)
    return frames

def get_fps(video_path):
    video_stream = cv2.VideoCapture(video_path)
    return video_stream.get(cv2.CAP_PROP_FPS)

def convert_audio(audio_path):
    if not audio_path.endswith('.wav'):
        subprocess.check_call(['ffmpeg', '-y', '-loglevel', 'error', '-i', audio_path, 'temp/temp.wav'])
        return 'temp/temp.wav'
    return audio_path

def out_video(fps, first_frame, output_path, gen):
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter('temp/result.mp4', fourcc, fps, (first_frame.shape[1], first_frame.shape[0]))
    for img_batch, mel_batch, frames, coords in tqdm(gen, total=len(frames)):
        pred = model(mel_batch, torch.FloatTensor(np.transpose(img_batch, (0, 3, 1, 2))).to(device)).cpu().numpy()
        for p, f, c in zip(pred, frames, coords):
            p = cv2.resize(p.astype(np.uint8), (c[2] - c[0], c[1] - c[3]))
            f[c[1]:c[3], c[0]:c[2]] = p
            out.write(f)
    out.release()

if __name__ == '__main__':
    args = parser.parse_args()
    model = load_model(args.checkpoint_path)
    main()
