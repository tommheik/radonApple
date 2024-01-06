# radonApple
 Bad Apple but it's reconstructed using Filtered Back-Projection

## Contents

This is the Matlab source code for generating the following video:

[![Bad Apple but it's reconstructed using Filtered Back-Projection](https://markdown-videos-api.jorgenkh.no/url?url=https%3A%2F%2Fyoutu.be%2FuKOXcam4qRs)](https://youtu.be/uKOXcam4qRs)

**Short summary**  
A sequence of grayscale images are extracted from the [original video](https://www.youtube.com/watch?v=FtutLA63Cp8). Each image is then projected into a short segment of a sinogram using `k = 10` projection angles. The projection angles `theta` are equispaced such that 360 degrees matches approximately 4 seconds of video.

The short segments are then reconstructed using classical [Filtered Back-Projection](https://en.wikipedia.org/wiki/Radon_transform#Reconstruction_approaches) (FBP) algorithm implemented in the most basic way in Matlab's `iradon`. Each reconstruction uses only `k = 10` projections so the streaking artifacts are severe. However since it is a linear operator, we can keep adding new frames which improves the quality. In order to not saturate the image too badly and see the current scene, the old image is made dimmer by a `decay = 0.97` factor every time.

Finally the original soundtrack is added back to the video using correct number of samples based on the frame rate of the video (`fps = 30`) and the sample rate of the music (`Fs = 44.1 kHz`).

The output is very large so I used [ffmpeg video compressor](https://github.com/dmitsuo/ffmpeg-video-compressor) to compress it way down.
