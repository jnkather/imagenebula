% This script calculate the arc oriented energies for several orientations on 
% the whole image

% for i = 1 : 23;
% 	theta = i * pi / 12;
% 	f{i, 1} = filteroearc([9, 3], 20, 5, theta, 2, 0);
% 	f{i, 2} = filteroearc([9, 3], 20, 5, theta, 2, 1);
% end

clear
im = imread('intensityH.png');
im = double(im) / 255;


f = cell(24, 1);
figure(1);
for i = 1 : 24
	theta = 2 * pi / 24 * (i - 1);
	f{i} = filteroearc([6, 1.5], 10, 5, theta, 2, 1);
	subplot(4, 6, i); imagesc(f{i});
	fprintf('Construct kernel %d\n', i);
end
fim = filterapply(im, f);
fim = cellmin(fim);

figure(2); subplot(1, 2, 1); imshow(im);
figure(2), subplot(1, 2, 2); imshow(imnormalize(fim));