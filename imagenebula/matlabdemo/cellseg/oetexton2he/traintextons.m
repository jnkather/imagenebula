% Train texton using the image 'image.png'
% The input image is H&E stained histopathological image. The task is to segment
% cell nuclei in the image.
%
% This demo calculate oriented energy filter bank outputs from 3 channels of the
% RGB image. And the texton is trained by using the outputs of each pixel as a
% vector of features. In this demo, the outputs of the filter is sorted in
% descending order for orienations, so the texton is rotation free.

%% Reading the RGB image
im(:, :, 1) = imread('H.png');
im(:, :, 2) = imread('E.png');
im = double(im) / 255;
im = log(1) - log(im); % comment this line to train textons on density image

%% Parameters
norients = 12;
startsigma = 0.5;
nscales = 7;
scalingstep = 1.3;
elong = 3;
ntexton = 16;

%% Calcualte the filter bank outputs
[fb, thetas, scales] = filterbankoe(norients, startsigma, nscales, ...
    scalingstep, elong, [0, 2 * pi]);
fbo = filterapply(im, fb);
fbo = cell2matnd(fbo);
fbo = sort(fbo, 6, 'descend');% sort the filter output in descending order 

%% Train the texton image
[tmap, textons] = textonscompute(fbo, ntexton);
figure(1), imagesc(tmap);


