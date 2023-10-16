# Audio to video lipsyncing made easy!

### Please note that currently this is a Google Colab project only!
I want to adapt it to run locally but right now this version is purely designed for colab.

Colab link: [https://colab.research.google.com/github/anothermartz/Easy-Wav2Lip/blob/v7/Easy-Wav2Lip_v7.ipynb](https://colab.research.google.com/github/anothermartz/Easy-Wav2Lip/blob/v7/Easy-Wav2Lip_v7.ipynb)

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/anothermartz/Easy-Wav2Lip/blob/v7/EZWav2Lip_v7.ipynb)

* Code adapted to google colab from [cog-Wav2Lip](https://github.com/devxpy/cog-Wav2Lip) by [devxpy](https://github.com/devxpy)

* Which is significantly faster than the original [Wav2Lip](https://github.com/Rudrabha/Wav2Lip) while ALSO giving better looking results!

Upscaling done with GFPGAN:<br>
https://github.com/TencentARC/GFPGAN/blob/master/README.md<br>
Though I'm not happy with its current results.

# Support
I may offer some support in this discord:<br>
Invite link: https://discord.gg/FNZR9ETwKY<br>
Wav2Lip channel: https://discord.com/channels/667279414681272320/1076077584330280991

# Best practices:
* The best results come from lining up the speech to the actions and expressions of the speaker before you send it through wav2lip!

Video files:
* Must have a face in all frames or Wav2Lip will fail
* Crop or mask out faces you don't want to lipsync or it'll choose randomly.
* Use h264 .mp4 - other file types may be supported but this is what it outputs as
* Static images should work too, at least .jpg and .png files do.
* Use a small file in every way (try <720p, <30 seconds, 30fps <b></b> etc. - Bigger files may work but are usually the reason it fails)
* Start with a really tiny clip just to get used to the process, only once you're familiar should you try bigger files to see if they work.

Audio files:
* Save as .wav and the same length as your input video.
* NOTE: I've noticed that about 80ms gets cut from the processed video/audio and I'm not sure how to fix this, so make sure you have a little extra than what you actually need!
* You can just encode it into your video file and leave vocal_path blank, but this will add a couple of seconds to the processing time as it splits the audio from the video
* <b>OR</b>
* Select your audio file separately
* I'm not certain what filetypes are supported, at least .wav and .mp3 work.

# Advanced Tweaking:
## wav2lip_version:
* Wav2Lip produces more accurate lipsync but can produce a missing teeth
* Wav2Lip_GAN doesn't seem as accurate to the words being spoken but can look nicer
* I suggest trying Wav2Lip first and switching to the GAN version if you experience an effect where it looks like the speaker has big gaps in their teeth.

### nosmooth:
* Disable face detection smoothing - enable by default and disable if there is lots of movement and the lips position appear to stutter.
* Definitely enable if there are any hard cuts in the video

## Padding:
* If you see hard lines on the face where the generated face meets the original, increase the padding in that direction.
* It happens most often on the chin, so increase the D value if you see that.
* Increasing these values too much can offset the mouth or cause other weird glitchyness.
* If the mouth is too far to the left, put L padding in the minus and R padding in the plus, start high then go down. Apply padding accordingly for any other directions.
* v7 will simplify padding to become mouth size and offset as that's basically what the result is.

## Mask (new!):
* For Improved and Enhanced quality options, the mask reduces the size of the processed videos to an area around the mouth.
* size will increase the size of the area that the mask covers and feathering determins the amount of blending between the centre of the mask and the edges.
* debug_mask will render the background in grayscale and the mask in colour so that you can easily see where the mask is in the frame.

# Other options:

# Batch processing:
* Name your files with a number at the end, eg. Video1.mp4, Video2.mp4, etc. and put them all in the same folder.
* Files will be processed in numerical order starting from the one you select. For example, if you select Video3.mp4, it will process Video3.mp4, Video4.mp4, and so on.
* If you select numbered video files and a non-numbered audio file, it will process each video with the same audio file. Useful for making different images/videos say the same line.
* Likewise, if you select a non-numbered video file and numbered audio files, it will use the same video for each audio file. Useful for making the same image/video say different things.

### output_suffix:
This adds a suffix to your output files so that they don't overwite your originals.

### include_settings_in_suffix:
Adds what settings were used - good for comparing different settings as you will know what you used for each render.
Will add: Qualty_resolution_nosmooth_pads-UDLR
EG: _Enhanced_720_nosmooth1_pads-U15D10L-15R30
pads_UDLR will not be included if they are set to 0.
resolution will not be included if it output_height is set to full resolution

### preview_input
Displays the input video/audio before processing so you can check to make sure you chose the correct file(s). It may only work with .mp4, I just know it didn't work on an .avi I tried.
Disabling this will save a few seconds of processing time for each video.

### preview_settings (new!)
This will render only 1 frame of your video and display it at full size, this is so you can tweak the settings without having to render the entire video each time.
frame_to_preview is for selecting a particular frame you want to check out.
