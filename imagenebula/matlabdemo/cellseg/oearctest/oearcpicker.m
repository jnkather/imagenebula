% Pick a pixel, and calculate the arc oriented energies for several 
% orientations at this pixel.

im = imread('intensityH.png');
im = double(im) / 255;

f = cell(23, 2);
for i = 1 : 23;
	theta = i * pi / 12;
	f{i, 1} = filteroearc([9, 3], 20, 5, theta, 2, 0);
	f{i, 2} = filteroearc([9, 3], 20, 5, theta, 2, 1);
end

figure(1); imshow(im);
while 1
	figure(1);
	[x, y] = ginput(1);
	v = filterapplysp(im, f, [x, y]);
	disp(v);
	figure(2); plot(v(:, 1));
	figure(3); plot(v(:, 2));
	[k, i] = max(v(:, 1));
	figure(4); imagesc(f{i, 1});
	[k, i] = min(v(:, 1));
	figure(5); imagesc(f{i, 1});
	
end