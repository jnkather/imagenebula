% Train texton using the image 'image.png'
% The input image is H&E stained histopathological image. The task is to segment
% cell nuclei in the image.
%
% This demo calculate oriented energy filter bank outputs from 3 channels of the
% RGB image. And the texton is trained by using the outputs of each pixel as a
% vector of features. In this demo, the outputs is not reordered, which means
% that the textons is not rotation free. Also, we calculate the OE filter bank
% outputs in the orientations in [0, pi]. 

%% Reading the RGB image
im = imread('image.png');

%% Parameters
norients = 6;
startsigma = 0.5;
nscales = 9;
scalingstep = 1.2;
elong = 3;
ntexton = 32;

%% Calcualte the filter bank outputs
fb = filterbankoe(norients, startsigma, nscales, scalingstep, elong);

[tmap,tex] = computeTextons(fbRun(fb,im),ntex);
[tim,tperm] = visTextons(tex,fb);
wt = zeros(ntex,1);
for i = 1:ntex,
  wt(i) = sum(abs(tim{i}(:))); % L1 norm of texton
end
wt = wt / max(wt(:));
tsim = zeros(ntex);
for i = 1:ntex,
  for j = 1:ntex,
    tsim(i,j) = sum(sum(abs(tim{i}-tim{j})));
  end
end
r = 10;
norient = 6;
tic; [tg,theta] = tgmo(tmap,ntex,r,norient,tsim); toc;
aa = cell(size(tg));
bb = cell(size(tg));
cc = cell(size(tg));
for i = 1:numel(tg),
  tic; [c,b,a] = fitparab(tg{i},r,theta(i)); toc;
  aa{i}=a; bb{i}=b; cc{i}=c;
end
tgs = cell(size(tg));
pb = zeros(size(tmap));
for i = 1:numel(tgs),
  tgs{i} = max(0,cc{i}) .* (aa{i}<0) .* exp(-abs(bb{i})/0.1);
  pb = max(pb,tgs{i});
end
pb2 = zeros(size(tmap));
for i = 1:numel(tgs),
  pb2 = max(pb2,(tgs{i}==pb).*nonmax(tgs{i},theta(i)));
end

figure(1); clf;
imshow(im);

figure(2); clf;
imagesc(mymontage({tim{tperm}}));
axis image; colorbar;

figure(3); clf;
imagesc(tmap);
truesize;

figure(4); clf;
imagesc(pb);
truesize;

figure(5); clf;
imagesc(pb2)
truesize;
