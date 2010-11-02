% Pick a pixel, and calculate the arc oriented energies for several 
% orientations at this pixel.

clear
im = imread('intensityH.png');
im = double(im) / 255;

f = cell(24, 2);
for i = 1 : 24;
	theta = (i-1) * 2 * pi / 24;
	f{i, 1} = filteroearc([3, 1], 10, 5, theta, 2, 0);
	f{i, 2} = filteroearc([3, 1], 10, 5, theta, 2, 1);
end

% save('f', 'f');
% load('f');

% figure(1); imshow(im);
% while 1
% 	figure(1);
% 	[x, y] = ginput(1);
% 	v = filterapplysp(im, f, [x, y]);
% 	disp(v);
% 	figure(2); plot(v(:, 1));
% 	figure(3); plot(v(:, 2));
% 	[k, i] = max(v(:, 1));
% 	figure(4); imagesc(f{i, 1});
% 	[k, i] = min(v(:, 1));
% 	figure(5); imagesc(f{i, 1});
% end

v = filterapplysp(im, f, [228 213]);
disp(v);
[k, i] = min(v(:, 1));
figure(1); imagesc(f{i, 1});
[k, i] = min(v(:, 2));
figure(2); imagesc(f{i, 2});

f = cell(30, 1); 
for i = 1 : 30
	f{
end