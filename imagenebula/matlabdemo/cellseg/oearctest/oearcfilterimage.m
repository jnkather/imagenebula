% This script calculate the arc oriented energies for several orientations and 
% scales on the whole image

clear
%im = imread('H.png');
im = imread('circle15.png');
im = double(im) / 255;

ntheta = 36;
elong = 5;
sigma = 1;
startr = 5;
nr = 20;
support = 5;
derivative = 2;
hilbert = 1;

f = cell(ntheta, nr);
fim = cell(ntheta, nr);
for itheta = 1 : ntheta
	theta = 2 * pi / ntheta * (itheta - 1);
	for ir = 1 : nr
		radius = startr + ir;
		f{itheta, ir} = -filteroearccache(...
			[elong*sigma, sigma], radius, support, theta, derivative, hilbert);
% 		f{itheta} = filteroe(...
% 			[elong*sigma, sigma], support, theta, derivative, hilbert);
		fim{itheta, ir} = filterapply(im, f{itheta, ir});
		fprintf('Construct kernel %d %d\n', itheta, ir);
	end
end

% thetas and angles
thetas = (0:ntheta-1) * 2 * pi / ntheta;
angles = thetas * 180 / pi;
angles2 = angles;
angles2(angles2 > 180) = angles2(angles2 > 180) - 180;

% radius 
radius = (startr+1 : startr+nr);

% max and min 
[maxfim, imaxfim] = cellmax(fim);
[imaxangle, imaxradius] = ind2sub(size(fim), imaxfim);
maxthetas = thetas(imaxangle);
maxangles = angles(imaxangle);
maxangles2 = angles2(imaxangle);
maxradius = radius(imaxradius);

[minfim, iminfim] = cellmin(fim);
[iminangle, iminradius] = ind2sub(size(fim), iminfim);
minthetas = thetas(iminangle);
minangles = angles(iminangle);
minangles2 = angles2(iminangle);
minradius = radius(iminradius);
