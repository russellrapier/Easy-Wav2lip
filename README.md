# Audio to video lipsyncing made easy!

Colab link: https://colab.research.google.com/github/anothermartz/Easy-Wav2Lip/blob/main/Easy-Wav2Lip_V3.ipynb

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/anothermartz/Easy-Wav2Lip/blob/main/Easy-Wav2Lip_V3.ipynb)

* Code adapted to google colab from [wav2lip-hq-updated-ESRGAN](https://github.com/GucciFlipFlops1917/wav2lip-hq-updated-ESRGAN) by [GucciFlipFlops1917](https://github.com/GucciFlipFlops1917)

* Which fixes and improves the depreciated [Wav2LipHQ](https://github.com/Markfryazino/wav2lip-hq)

* Which is based on the original [Wav2Lip](https://github.com/Rudrabha/Wav2Lip)

Other projects called on (probably more than this but here's what I'm aware of):<br>
https://github.com/sczhou/CodeFormer/blob/master/README.md<br>
https://github.com/TencentARC/GFPGAN/blob/master/README.md<br>
https://github.com/xinntao/Real-ESRGAN<br>

Not only was this built on the shoulders of giants, I'm not even very good at coding and I practically used Bing AI chat to do it all for me.

However I may offer some support in this discord:<br>
Invite link: https://discord.gg/FNZR9ETwKY<br>
Wav2Lip channel: https://discord.com/channels/667279414681272320/1076077584330280991

# The rest of this Readme is for the upcoming v4 release
v3 doesn't really need a readme so until v4 is released just look in the v3 colab for instructions - some of these options don't exist or work the same way in v3

# Best practices:
Video files:
* Must have a face in all frames or Wav2Lip will fail
* Crop or mask out faces you don't want to lipsync or it'll choose randomly.
* Use h264 .mp4 - other file types may be supported but this definitely works
* Static images should work too, at least .jpg and .png files do.
* Use a small file in every way (try <720p, <30 seconds, 30fps <b></b> etc. - Bigger files may work but are usually the reason it fails)
* Start with a really tiny clip just to get used to the process, only once you're familiar should you try bigger files to see if they work.

Audio files:
* Ideally just encode it into your video file - the best results come from lining up the speech to the actions!
* <b>OR</b>
* Select your audio file separately
* I'm not certain what filetypes are supported, at least .wav and .mp3 work.

# Advanced Tweaking:

## Upscaling:
* gfpgan works best for live action videos. I personally haven't tried Animated / game / CGI / AI generated videos, so they may get better results using codeformer or ESRGAN. Let me know!

### ESRGAN:
RealESRGAN_x4plus.pth is downloaded by default, but you can find many different models for ESRGAN [here](https://upscale.wiki/wiki/Model_Database).
Upload one of those to your Google Drive or to your colab runtime then paste the path to the file in ESRGAN_model. I've only tried a few and most didn't work. Let me know if you get somewhere.

### codeformer:
* codeformer_fidelity is a scale from detailed (0) to likeness to the original face (1)
* A lower number will recreate the face more from scratch and while each frame will look better, it will not look good in motion.
* A higher number will try to accurately make the same face as the input and so the detail won't be as good.
* I suggest 0.75.


## Padding:
* If you see hard lines on the face where the generated face meets the original, increase the padding in that direction.
* It happens most often on the chin, so increase the D value if you see that.
* Increasing these values too much can offset the mouth or cause other weird glitchyness.
* I've been told using minus values can help with certain videos but I personally haven't found a use case for that yet.

# Batch processing:
* Name your files with a number at the end, eg. Video1.mp4, Video2.mp4, etc. and put them all in the same folder.
* Files will be processed in numerical order starting from the one you select. For example, if you select Video3.mp4, it will process Video3.mp4, Video4.mp4, and so on.
* If you select numbered video files and a non-numbered audio file, it will process each video with the same audio file. Useful for making different images/videos say the same line.
* Likewise, if you select a non-numbered video file and numbered audio files, it will use the same video for each audio file. Useful for making the same image/video say different things.

# Other options:

### resolution_scale:
Lower the output resolution for quicker rendering and better hiding of artifacts, at the cost of worse overall image quality.

### fps_for_static_image:
If using a static image as an input (eg: a .jpg) then this will be the fps of the lipsynced video.

### nosmooth:
Disable face detection smoothing which may fix artifacts, I'm not aware of any downsides to this.

### output_suffix
This adds a suffix to your output files so that they don't overwite your originals. Tick include_upscaler_in_suffix if you want the upscaler written at the end of the suffix, good for when you want to compare different upscaler settings or just to remember which one you used.

### preview_input
Displays the input video/audio before processing so you can check to make sure you chose the correct file(s). It may only work with .mp4, I just know it didn't work on an .avi I tried.
Disabling this will save a few seconds of processing time for each video.
