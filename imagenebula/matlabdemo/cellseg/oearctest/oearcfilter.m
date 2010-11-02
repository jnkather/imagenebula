% This script calculate the arc oriented energies for several orientations and 
% scales on the whole image

% for i = 1 : 23;
% 	theta = i * pi / 12;
% 	f{i, 1} = filteroearc([9, 3], 20, 5, theta, 2, 0);
% 	f{i, 2} = filteroearc([9, 3], 20, 5, theta, 2, 1);
% end

clear
im = imread('intensityH.png');
%im = imread('circle15.png');
im = double(im) / 255;


ntheta = 72;
elong = 5;
sigma = 1;
nradius = 20;
startradius = 10;
stepradius = 1;
support = 5;
derivative = 1;
hilbert = 0;

f = cell(ntheta, nradius);
for itheta = 1 : ntheta
	for iradius = 1 : nradius
		radius = startradius + stepradius * (iradius - 1);
		theta = 2 * pi / ntheta * (itheta - 1);
		f{itheta, iradius} = filteroearc(...
			[elong*sigma, sigma], radius, support, theta, derivative, hilbert);
		fprintf('Construct kernel %d %d\n', itheta, iradius);
	end
end
save('f_72_20', 'f');
load 'f_72_20';

fim = zeros(ntheta, nradius);
for itheta = 1 : ntheta
	for iradius = 1 : nradius
		fim(itheta, iradius) = filterapplysp(im, f{itheta, iradius}, [228 213]);
		fprintf('Filter %d %d\n', itheta, iradius);
	end
end

imagesc(fim); hold on;
for i = 1 : ntheta
	[m, k] = min(fim(i, :));
	plot(k, i, 'k*');
	[m, k] = max(fim(i, :));
	plot(k, i, 'ko');	
end