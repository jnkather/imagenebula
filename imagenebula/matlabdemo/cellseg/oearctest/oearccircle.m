% Pick a pixel, and calculate the arc oriented energies for several 
% orientations at this pixel.

% prepare the circle image
clear
im = imread('circle15.png');
im = double(im) / 255;


loc = [236 250];
% loc = [235 350];
% loc = [239 340];
% loc = [261 262];

ntheta = 24;
nr = 10;
startr = 5;
stepr = 2;
r = (startr : stepr : startr + (nr-1) * stepr);
support = 5;
sigmax = 5;
sigmay = 1;
der = 1;
hil = 0;
f = cell(ntheta, 1);
v = zeros(ntheta, 1);
for i = 1 : ntheta
	theta = (i-1) * 2 * pi / ntheta;
	for j = 1 : nr
		f{i, j} = filteroearc([sigmax, sigmay], r(j), support, theta, der, hil);
		v(i, j) = filterapplysp(im, f{i, j}, loc);
		fprintf('construct filter kernel: %d %d\n', i, j);
	end
end


imagesc(v); hold on;
x = (1 : ntheta);
[m, y] = min(v, [], 2);
plot(y, x, 'k*');
