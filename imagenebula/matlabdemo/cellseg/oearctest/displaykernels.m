% This script demonstrates the usage of FILTEROEARC by displaying the filter
% kernels of different orienations or scales in a single figure.

% This is for displaying kernels of different orientations
clear
norientations = 24;
elong = 5;
scale = 1;
radius = 10;
support = 5;
derivative = 2;
hilbert = 1;

f = cell(norientations, 1);
figure(1);
for i = 1 : norientations
	theta = 2 * pi / norientations * (i - 1);
	f{i} = filteroearc([scale*elong, scale], radius, support, theta, ...
		derivative, hilbert);
	subplot(4, 6, i); imshow(f{i}, []);
	fprintf('Construct kernel %d\n', i);
end