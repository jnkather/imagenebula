% This script demonstrates the usage of FILTEROEARC by displaying the filter
% kernels of different orienations or scales in a single figure.

% This is for displaying kernels of different orientations
clear

show = 'r';

norientations = 24;
elong = 3;
scale = 2;
radius = 10;
support = 5;
derivative = 2;
hilbert = 1;

nradius = 24;
startradius = 5;
f = cell(norientations, 1);
figure(1);

switch show
	case 'o'
		
		for i = 1 : norientations
			theta = 2 * pi / norientations * (i - 1);
			f{i} = filteroearccache([scale*elong, scale], radius, support, theta, ...
				derivative, hilbert);
			subplot(4, 6, i); imshow(f{i}, []);
			fprintf('Construct kernel %d\n', i);
		end

	case 'r'
		for i = 1 : nradius
			theta = 0;
			radius = startradius + i;
			f{i} = filteroearccache([scale*elong, scale], radius, support, theta, ...
				derivative, hilbert);
			subplot(4, 6, i); imshow(f{i}, []);
			fprintf('Construct kernel %d\n', i);
		end
		
end