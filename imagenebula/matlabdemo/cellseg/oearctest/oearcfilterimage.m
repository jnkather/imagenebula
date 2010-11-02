% This script calculate the arc oriented energies for several orientations and 
% scales on the whole image

clear
im = imread('intensityH.png');
%im = imread('circle15.png');
im = double(im) / 255;

ntheta = 36;
elong = 5;
sigma = 1;
radius = 10;
support = 5;
derivative = 1;
hilbert = 0;

f = cell(ntheta, 1);
for itheta = 1 : ntheta
	theta = 2 * pi / ntheta * (itheta - 1);
	f{itheta} = filteroearc(...
		[elong*sigma, sigma], radius, support, theta, derivative, hilbert);
% 	f{itheta} = filteroe(...
% 		[elong*sigma, sigma], support, theta, derivative, hilbert);

	fprintf('Construct kernel %d\n', itheta);
end

fim = filterapply(im, f);
mfim = cellmin(fim);
