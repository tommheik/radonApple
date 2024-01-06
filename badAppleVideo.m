clear all
close all

% Tommi Heikkilä   2024

%% Enable visualization (slow)
showImgs = true;

%% Load video
inputName = "badApple.mp4";
outputName = "radonApple.avi";

vidObj = VideoReader(inputName);

%% Take frames
vidframes = read(vidObj, [1 Inf]);
fprintf("Video size is %i x %i, with %i frames \n", size(vidframes,1), size(vidframes,2), size(vidframes,4))

%% Crop if necessary
% T = vidObj.NumFrames;
T = 1000; % Good idea to test with a short segment
vidframes = vidframes(:,:,:,1:T);
fps = vidObj.FrameRate;

clear vidObj
%% Convert to grayscale
% Not sure if this is any faster than looping with built-in rgb2gray
% function
col2gray = reshape([0.2989, 0.5870, 0.1140],[1 1 3]);
grayframes = squeeze(sum(single(vidframes) .* col2gray, 3))/255;

%% Play frames
figure(1)

sz = size(grayframes);

% Need a square image
bigframes = zeros([sz(2), sz(2), sz(3)], 'single');
fillInd = (sz(2)-sz(1))/2 + 1 : sz(2) - (sz(2)-sz(1))/2;

for t = 1:T
    I = grayframes(:,:,t);
    bigframes(fillInd,:,t) = I;
    if showImgs
        imshow(bigframes(:,:,t));
        pause(0.01/fps)
    end
end

%% Set up radon transform
k = 10; % projection overlap
rps = 0.25; % Rotations per second
maxAngle = rps*(T/fps)*360; 
theta = linspace(0,maxAngle,k*T);

sz = size(bigframes(:,:,1));

% Sanity check on one image
sino = single(radon(bigframes(:,:,10), theta));

if showImgs
    figure(2); imagesc(sino)
end

%% Generate column of sinogram for each time step t
for t = 1:T
    % Project using k angles and add to the giant sinogram
    sino(:,k*(t-1)+1:k*t) = single(radon(bigframes(:,:,t), theta(k*(t-1)+1:k*t)));
end
if showImgs
    figure(3); imagesc(sino)
end

%% Add sound
[music, Fs] = audioread("badApple.mp4");
Lm = size(music,1);
m = Fs / fps; % Number of sound samples per image

%% Open a video writer

% This can not add sound, othersie great
% writer = VideoWriter("radonApple", 'MPEG-4');
% writer.FrameRate = fps;
% open(writer)

% This requires Computer Vision Toolbox but can add sound to .avi
writer = vision.VideoFileWriter("radonApple.avi", "AudioInputPort", true);
writer.FileFormat = 'AVI';
writer.FrameRate = fps;
writer.VideoCompressor = 'MJPEG Compressor';
disp(writer)

%% Reconstruct one projection at a time
scaling = 30; % Magic number
recon = zeros(sz, 'single');
figure(10);
decay = 0.97; % How much previous image is made dimmer
fprintf("Start reconstruction process...   ")
for t = 1:T
    % Every frame is added on top of the previous one
    recon = decay*recon + single(iradon(sino(:,k*t-(k-1):k*t), theta(k*t-(k-1):k*t),...
        'linear', 'Ram-Lak', 1, sz(1))) / scaling;
    
    if showImgs
        imshow(recon, [0, 1]);
        pause(0.005/fps);
    end
    I = uint8(255*recon(fillInd,:));
%     writeVideo(writer, I);
    % Every frame gets 'm' samples of sound
    step(writer, I, music((t-1)*m+1:t*m,:));
end

% close(writer)
release(writer)

fprintf("Done! \n")

%% Note:
% The final output is most likely huge since the compressions and file
% extension options are limited. I recommend additional compression using
% something other than Matlab.
