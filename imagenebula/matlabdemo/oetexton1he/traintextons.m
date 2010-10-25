% Train texton using the image 'image.png'
% The input image is H&E stained histopathological image. The task is to segment
% cell nuclei in the image.
%
% This demo calculate oriented energy filter bank outputs from 2 channels of the
% the image H & E. And the texton is trained by using the outputs of each pixel as a
% vector of features. In this demo, the outputs is not reordered, which means
% that the textons is not rotation free. Also, we calculate the OE filter bank
% outputs in the orientations in [0, pi]. 

%% Reading the RGB image
im(:, :, 1) = imread('H.png');
im(:, :, 2) = imread('E.png');
im = double(im) / 255;
im = log(1) - log(im); % comment this line to train textons on density image

%% Parameters
norients = 6;
startsigma = 0.5;
nscales = 7;
scalingstep = 1.2;
elong = 3;
ntexton = 8;

%% Calcualte the filter bank outputs
[fb, thetas, scales] = filterbankoe(norients, startsigma, nscales, ...
    scalingstep, elong);
fbo = filterapply(im, fb);
fbo = cell2matnd(fbo);

%% Train the texton image
[tmap, textons] = textonscompute(fbo, ntexton);
figure(1), imagesc(tmap);

%% Visualize the Textons
[tim, tperm] = textonsvisualize(textons, fb);

